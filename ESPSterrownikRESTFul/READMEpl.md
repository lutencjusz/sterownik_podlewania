# Instalacja sterownika [(->EN)](https://github.com/lutencjusz/sterownik_podlewania/edit/master/ESPSterrownikRESTFul/README.md)
## Wstępne przygotowanie ESP8266
1. Do przygotowania odpowiedniego firmware wykorzystałem stronę [NodeMCU custom builds](https://nodemcu-build.com/). Dla chętnych można samemu przygotować odpowieni firmware, niemniej powinien on się składać z następujących modułów (lista modułów jest dostępna w pliku moduły_kompilacji.txt):

```
adc,crypto,encoder,file,gdbstub,gpio,http,net,node,ow,rtcfifo,rtcmem,rtctime,sjson,sntp,tmr,uart,websocket,wifi,tls
```
- koniecznie należy zaznaczyć opcję `LFS options (for master & dev branches)` i wybrać wartości zależne od stosowanego układu (np. dla ESP-12E - wszystkie maksymalne). Ze względu na ograniczoną wielkość pamięci RAM układu, konieczne jest trzymanie wszystkich możliwych modułów i funkcji w pamięci LFS w postaci pliku binarnego i stamtąd ich uruchamianie.
- dodatkowo należy wybrać `ssl = true`, co umożliwi dodanie modułu `tls`. 

2. Przygotowane wersje firmware zostaną przysłane mejlem, jednak wykorzystana może być tylko wersja obsługująca zmienne integer np.
```
nodemcu-master-18-modules-2017-02-19-13-15-55-integer.bin - tylko ta jest do wykorzystania
nodemcu-master-18-modules-2017-02-19-13-15-55-float.bin
```
ponieważ wersja `...float.bin` nie umożliwia wprowadzenia wygenerowanego obrazu `ESPCzujnikiRESTFul.img` do pamięci LFS.

## Przygotowanie własnych wersji obrazów binarnych
Ponieważ projekt jest nadal rozwijany, możliwe jest niedostosowanie wersji obrazów developerskich do dystrybucyjnych. W takim przypadku możliwe jest wygenerowanie własnych obrazów składających się z załączonych w plików '.lua' z wyjątkiem init.lua. W tym celu należy:
1. skompresować pliki `.lua` (z wyjątkiem `init.lua`) do postaci `obraz.zip'
2. uruchomić narzędzie z blogu Terry Ellison's [A Lua Cross-Compile Web Service](https://blog.ellisons.org.uk/article/nodemcu/a-lua-cross-compile-web-service/) i wczytać plik `obraz.zip` do narzędzia poprzez przycisk *Wybierz plik*. 
3. Wybrać opcję `REMOTE LUAC.CROSS.INIT (MASTER)`, co spowoduje wygenerowanie i zapisanie pliku `obraz.img`
4. Za pomocą ESPlorer przycisku *Uload* należy wgrać na sterownik plik będący obrazem binarnym modułów `obraz.img`
5. W linii poleceń sterownika należy wykonać komendę 
```
node.flashreload("obraz.img")
```
Po czym sterownik powinien się zrestartować, co kończy wgrywanie obrazu. Wiele błędów jest spowodowanych tym, że w pamięci sterownika znajdują się zbędne pliki i programy, dlatego najlepiej jest wgrywać obraz do sterownika bez pliku `init.lua` i jego restarcie.
Na pewno jest możliwość wygenerowania własnych obrazów, umożliwiających nawet obsługę firmware'ów float, jednak całe rozwiązanie jest dostosowane do pracy na zmiennych integer, nawet dla liczb wymagających części ułamkowych.

## Wgranie oprogramowania
Instalacja sterownika odbywa się za pomocą [ESPlorer](https://esp8266.ru/esplorer/) i wymaga zastosowania urządzenia klasy ESP8266 z co najmniej 40 KB pamięci RAM przeznaczonej na instrukcję i dodatkowej niewielkiej przestrzeni na pliki operacyjne i konfiguracyjne.
1. Całość katalogu [ESPSterrownikRESTFul](https://github.com/lutencjusz/sterownik_podlewania/edit/master/ESPSterrownikRESTFul/) należy rozpakować w osobnym katalogu (np. C:\programy\sterownikPodlewania\).
2. Za pomocą ESPlorer przycisku *Uload* należy wgrać na sterownik plik będący obrazem binarnym modułów `ESPCzujnikiRESTFul.img`
3. W linii poleceń sterownika należy wykonać komendę 
```
node.flashreload("ESPCzujnikiRESTFul.img")
```
Po czym sterownik powinien się zrestartować, co kończy wgrywanie obrazu. Wiele błedów jest spowodowanych tym, że w pamięci sterownika znajdują się zbędne pliki i programy, dlatego najlepiej jest wgrywać obraz do sterownika bez pliku `init.lua` i jego restarcie.

4. Do sterownika należy wgrać następujące pliki:
- ustawieniaZ.json
- parametryCz.json
- log.json
- kalendarz.json
- init.lua

5. Po restarcie ESP8266 jest gotowy do rozpoczęcia pracy i włożenia do układu docelowego. Należy pamiętać, że obudowa powinna być wodoodporna. Układ praktycznie się nie grzeje, więc nie wymaga dodatkowego chłodzenia. Nie testowałem układu w warunkach zimowych...

# Rozwój sterownika
W następnej wersji planuję wprowadzić możliwość procentowego określenia prawdopodobieństwa podlania roślin w przyszłości przez sterownik, co wiąże się z koniecznością zaplanowania uzupełnienia wody w zbiorniku, w przypadku urlopów lub dłuższych wyjazdów.

Rozważam również możliwość przejścia na platformę ESP32 (język MicroPython), ze względu na ograniczenia pamięci modułu ESP8266 podczas pobierania informacji pogodowych z zewnętrznych serwisów (RESTFul API).

Planuję rozwinąć panel Grafana wpółpracujący z InfluxDB, w celu wykonania bardziej złożonych statystyk, które mogą ulepszyć logikę modułu.

# Moduły sterownika
Sternik składa się z następujących modułów:
-   `init.lua` - mikro moduł startujący, proces bootowania
-   `bootowanie.lua` - moduł bootowania oraz utrzymania sterownika
-	`_init.lua` - moduł uruchamiający pozostałe moduły
-	`httpServer.lua` - biblioteka do mini servera HTTP stworzona przez @yulincoder i @wangzexi https://github.com/wangzexi/NodeMCU-HTTP-Server
-	`InfluxDB.lua` - moduł zapisujący dane ze sterownika w bazie czasu rzeczywistego.
-	`kalendarz.lua` - moduł obsługujący daty i czasy oraz ich porównywania
-	`logika.lua` - moduł zwierający logikę sterownika
-	`parametyZewnętrzne.lua` - moduł pobierający dane pogodowe z serwisu airly.eu.
-	`pliki.lua` - moduł obsługujący pliki zewnętrzne podczas pracy modułu (JSON)
-	`ServerWWW.lua` - moduł obsługujący RESTFul API sterownika
-	`Vc.lua` - moduł inicjujący i pobierający napięcie zasilania sterownika
-	`WiFi.lua` - moduł podłączający sterownik do lokalnej sieci WiFi
-	`wyslijMejl.lua` - moduł wykonujący sekwencję wysyłania poczty do serwera pocztowego.

## `init.lua`
Moduł wydzieliłem, żeby uprościć nieco development. jest to jedyny moduł znajdujący się bezpośrednio w pamięci RAM. Zarządza ustawieniami dwóch zmiennych:
- `debugowanie` *(true/false)* - true oznacza, że podczas uruchamiania i pracy modułu na konsoli pojawią się dodatkowe informacje w poszczególnych modułach.
- `zapisDoInfluxDB` *(true/false)* - true oznacza, że w module InfluxDB wysyłanie do bazy (uruchomienie timera w funkcji zapiszPTestoweInfluxDB()) będzie zablokowane.
Uruchamia moduł bootowanie znajdujący się w pamięci LFS poprzez polecenie:
`pcall(function()node.flashindex("bootowanie")()end)`
i oddaje mu kontrolę.

## `botowanie.lua`
Najpierw moduł czyści zbędne pliki z końcówką `.lua`, z wyjątkiem `init.lua`, w celu usunięcia zbędnych plików powstałych podczas ich edycji i zapisu.
```
l = file.list();
for k,v in pairs(l) do
    if string.find(k, ".lua")~=nil and string.find(k, "init.lua")==nil then 
        if file.exists(k) then
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

## `logika.lua`
Moduł zapewnia dostarczenie logiki do podejmowania decyzji o podlewaniu na podstawie dostępnych parametrów pogodowych. W skład modułu wchodzą następujące komórki decyzyjne, które zwracają zmodyfikowany obiekt alertu `ob` oraz ustawiają zmienne globalne:

### czyAlertPozZasVc (ob)
Komórka sprawdza, czy napięcie zasilania pompek `PTestowe.Vp` mieści się w wyznaczonym przedziale określonym przez parametry sterownika `pCz.VcMax` oraz `pCz.VcMin`, blokując jednocześnie uruchomienie pompek w przypadku nieprawidłowości.

### czyAlertPozZasVp (ob)
Komórka robi to samo co poprzednik, tylko dla napięcia układu określonego przez `PTestowe.Vc`. Przedział określa `pCz.VpMax` oraz `pCz.VpMin`.

### czyAlerthumidity (ob)
Komórka sprawdza wilgotność powietrza `pTestowe.humidity` ograniczoną przez `pCz.humidityMin` oraz `pCz.humidityMax` blokująco uruchomienie pompek. 
Dodatkowo ustawia zmienną globalną `czyUruchomicPompkiKalendarz1` w przypadku, gdy wilgotność jest wyższa niż optymalna `pCz.humidityOpt`. Zmienna ta, jeżeli jest ustwiona na *false* blokuje poranne uruchomienie pompek.

### czyAlertTempPow (ob)
Komórka sprawdza temperaturę powetrza `pTestowe.temp/_u`, czy mieści się w przedziale określonym `pCz.temp_min` oraz `pCz.temp_max`. Jeżeli wykracza za przedział, komórka blokuje uruchomienie pompek.

### czyAlertKalenadza (ob)
Komórka określa aktualny czas w stosunku do czasów wyznaczonych w kalendarzu oraz daty ostatniego podlewania i sprawdza, czy podlewania miało już miejsce, czy jeszcze nie. Blokuje uruchomienie pompek, jeżeli podlewanie o tej porze miało już miejsce.

### czyAlertPoziomuWody (ob)
komórka sprawdza, czy jest wystarczająca ilość wody do polewania i jeżeli nie ma, blokuje uruchomienie podlewania. Obecnie komórka jest zablokowana i zawsze dopuszcza do podlewania.

### czyAlertPrzedzialuCzasowego (ob)
Komórka określa na podstawie aktualnego czasu, czy jest to ten moment na podlewanie, który mieści się w wyznaczonym przedziale czasu. Ten przedział mieści się między datą początku podlewania zapisaną w pliku 'kalendarz.json', a czasem wyznaczonym przez zmienną globalną `mozliwyCzasNaPodlewanie` (wyrażoną w godzinach). Komórka nie rozróżnia, czy ma do czynienia z podlewaniem porannym, czy wieczornym.
Komórka do oceny wykorzystuje funkcję `czyMiesciSiePrzedzialeCzasowym ()` w `module kalendarz.lua`

### ustawienieAlertowLogiki (ob)
Funkcja łączy z sobą poszczególne komórki decyzyjne i zwraca wynik analizy w formie obiektu alertu `ob`.




