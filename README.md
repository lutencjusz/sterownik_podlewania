# Budowa sterownika


# Rozwój sterownika
W następnej wersji planuję wprowadzić możliwość procentowego określenia prawdopodobieństwa podlania roślin w przyszłości przez sterownik, co wiąże się z koniecznością zapewnienia wody w zbiorniku.

Rozważam również możliwość przejścia na platformę ESP32 (język MicroPython), ze względu na ograniczenia pamięci modułu ESP8266 szczególnie podczas pobierania informacji pogodowych z zewnętrznych serwisów (RESTFul API).

Planuję rozwinąć panel Grafana wpółpracujący z InfluxDB, w celu wykonania bardziej złożonych statystyk, które mogą ulepszyć logikę modułu.

## Moduły sterownika
Sternik składa się z następujących modułów:
-   init - mikro moduł startujący, proces bootowania
-   bootowanie - moduł bootowania oraz utrzymania sterownika
-	_init - moduł uruchamiający pozostałe moduły
-	httpServer - biblioteka do mini servera HTTP stworzona przez @yulincoder i @wangzexi https://github.com/wangzexi/NodeMCU-HTTP-Server
-	InfluxDB - moduł zapisujący dane ze sterownika w bazie czasu rzeczywistego.
-	kalendarz - moduł obsługujący daty i czasy oraz ich porównywania
-	logika - moduł zwierający logikę sterownika
-	parametyZewnętrzne - moduł pobierający dane pogodowe z serwisu airly.eu.
-	pliki - moduł obsługujący pliki zewnętrzne podczas pracy modułu (JSON)
-	ServerWWW - moduł obsługujący RESTFul API sterownika
-	Vc - moduł inicjujący i pobierający napięcie zasilania sterownika
-	WiFi - moduł podłączający sterownik do lokalnej sieci WiFi
-	wyslijMejl - moduł wykonujący sekwencję wysyłania poczty do serwera pocztowego.

### init.lua
Moduł wydzieliłem, żeby uprościć nieco development. jest to jedyny moduł znajdujący się bezpośrednio w pamięci RAM. Zarządza ustawieniami dwóch zmiennych:
- `debugowanie` *(true/false)* - true oznacza, że podczas uruchamiania i pracy modułu na konsoli pojawią się dodatkowe informacje w poszczególnych modułach.
- zapisDoInfluxDB *(true/false)* - true oznacza, że w module InfluxDB wysyłanie do bazy (uruchomienie timera w funkcji zapiszPTestoweInfluxDB()) będzie zablokowane.
Uruchamia moduł bootowanie znajdujący się w pamięci LFS poprzez polecenie:
`pcall(function()node.flashindex("bootowanie")()end)`
i oddaje mu kontrolę.

### botowanie
Najpierw moduł czyści zbędne pliki z końcówką `.lua`, z wyjątkiem `init.lua`, w celu usunięcia zbędnych plików powstałych podczas ich edycji i zapisu.
```
l = file.list();
for k,v in pairs(l) do
    if string.find(k, ".lua")~=nil and string.find(k, "init.lua")==nil then 
        if file.exists(k) then -- czy trzeba kompilować moduł
            file.remove(k)
            print("  usunieto " .. k .. " ...")
        end
    end
end
l=nil; k=nil; v=nil; s=nil
collectgarbage() 
```
### ładowanie modułów i ustawianie wstępnych wartości zmiennych

Następnie wczytuje plik ustawień ustawieniaZ.json i zapisuje do obiektu `u` po czym przypisuje obiekt do zmiennych.
Kolejna funkcja `do_next` odpowiada za przebieg procesu bootowania i dzieli się na trzy grupy:
1. Ładowanie modułów:
    - Vc,
    - pliki,
    - WiFi - w tym ostatnim oczekuję na zsynchronizowanie zegara oczekując na ustawienie zmiennej ''czyZsynchonizowano = true''

2. wczytuje moduł parametryZewn i pobiera dane pogodowe poprzez `pobierzDanePowietrza()` i ustawia zmienną `dataOstatniegoZapisu` podając aktualny czas jako string w formacie "dzień/miesiąc/rok godzina:minuta:sekunda".
Próbuje pobrać dane z serwisu zewnętrznego trzy razy i jeżeli się nie uda, restartuje sterownik.

3. wczytuje moduł _init, który ładuje:
    - httpServer
    - kalendarz
    - logika
    - wyslijMail
    - InfluxDB
    - ServerWWW, ktory uruchamia RESTFul API
Następnie ładuje wartości czujników poprzez funkcję `odswierzZakresyCzujnikow()`. Po czym uruchamia funkcję `obslugaModulu()`, która jest pętlą główną sterownika.

### obsługa sterownika

Obsługa sterownika dzieli się na trzy grupy poleceń:
1. Ten blok instrukcji sprawdza, czy od ostaniego wczytania danych powietrza `dataOstatniegoZapisu` nineło więcej niż `czasDoOdswierzeniaMin` (np. 10 min.) wtedy są ładowane dane pogodowe z serwisu airly.eu `pobierzDanePowietrza()` przez 20 sek. 
Jeżeli dane zostały pobrane, to wtedy odświeżany jest obiekt `wynikPZ`, który jest obiektem aktualnych danych pogodowych wykorzystywanym przez inne moduły.

2. W tym bloku ładowane są z plików JSON odpowiednie obiekty poprzez '`initKalendarza()`, co ma na celu przygotowanie środowiska do sprawdzenia możliwości uruchomienia pompek: 
- tLog - przechowuje informacje uruchomieniach pompek 
- tAlarm - przechowuje informacje o alarmach związanych z próbnymi uruchomieniami
- tKalendarz - przechowuje informaje o początkach okresów, w których można podlewać rośliny
Następnie podejmuje próbę zapisy do bazy InfluxDB poprzez `zapiszPTestoweInfluxDB()`, jeżeli zmienna `zapisDoInfluxDB()` jest ustawiona.

3. Blok uruchamia sprawdzenie możliwości podlewania poprzez uruchomienie komórki decyzyjnej `czyAlerthumidity()`, która ustawia zmienną globalną czyUruchomicPompkiKalendarz1 w zależności od wilgotności.
Następne jest sprawdzena możliwość uruchomienia pompek poprzez `uruchomPompki()` oraz wczytania obiektów z plików poprzez `initKalendarza()`, w celu zaktualizowania danych ładowanych w bloku 2. Aby móc prawidłowo wyliczyć czas do następnego uruchomienia procedury obsługi sterownika, następuje 6 prób wczytania logu uruchomienia sterownika "log.json" i w przypadku braku wczytania danych...

4. W bloku wyliczany jest czas uruchomienia timera w poleceniu `tmr.interval(5, d * 60 * 1000)` (d jest w min.)
W tym celu uruchamiana jest funkcja `zaIleUruchomicPompkiKalendarz()` skorygowana o czas potrzebny do wysłania mejla przypominającego o uzupełnieniu wody w zbiorniku `ileCzasuDoWyslaniaMejla`.
Następnie sprawdzane jest, czy nie został wyliczony czas późniejszy (<0), to zostaje skorygowany o `ileCzasuDoWyslaniaMejla`. 
Jeżeli nadal wychodzi czas późniejszy (<0) lub za duży niż możliwości układu ESP8266 (powyżej 113 minut) następuje ustawienie maksymalnej wartości czasu.
Ustawiana jest czas następnego uruchomienia oraz zapisywana `dataNastepnegoSprawdzenia` na podstawie funkcji `kiedyNastepneSprawdzenie()`.

Na koniec następuje uruchomienie bootowania poprzez
`tmr.alarm(3,1000,1,do_next)`
