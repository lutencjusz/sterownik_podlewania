# Sterownik podlewania (Logic plant watering)
system of logic plant watering based on ESP8266 (Lua) as RESTFul API. All documnetantion is prepared in polish language that will be changed in the future.

# Podsumowanie rozwiązania
Sterownik podlewania jest systemem składającym się z modułu ESP8266 zaprogramowanego w języku LUA sterującego dwoma pompkami wodnymi umożliwijacymi podlewania kwiatków balkonowych lub ogrodowych, sterownik samodzielnie podejmuje decyzję o podlewaniu najwyzej dwa razy dziennie na podstawie danych pogodowych ściąganych z serwisu Airly.eu oraz jest przygotowany do pobierania danych z AccuWeather (choć ta funkcjoaność została wyłączona). Decyzje zostają zapisane w logach z uruchamiania pompek lub alertów w przypadku braku uruchomienia. 

Dodatkowo sterownik jest zaopatrzony we własne GUI, które zostało napisane w Angular/CLI (v. 7), które umożliwia podgląd danych ze sterownika, odczytywanie logów uruchamiania pompek oraz alertów, które zablokowały uruchomienie sterownika.
Można również podejrzeć, kiedy sterownik zaktualizuje warunki pogodowe oraz kiedy będzie próbował ocenić możliwość podlewania.

Dodatkowo moduł powiadamia mejlowo o koniecznosći uzupełnienie wody w zbiorniku godzinę przed planowanym podlewaniem oraz o tym, że podlał rośliny. 

Możliwość wysyłania SMS zamiast mejla jest obecnie zablokowana.

# Rozwój sterownika
W następnej wersji planuję wprowadzić możliwość procentowego określenia prawdopodobieństwa podlania roślin w przyszłości przez sterownik, co wiąże się z koniecznością zapewnienia wody w zbiorniku.

Rozważam również możliwość przejścia na platformę ESP32 (język MicroPython), ze względu na ograniczenia pamięci modułu ESP8266 szczególnie podczas pobierania informacji pogodowych z zewnętrznych serwisów (RESTFul API).

Planuję rozwinąć panel Grafana wpółdziałający z InfluxDB, w celu wykonania bardziej złożónych statystyk, które mogą ulepszyć logikę modułu.

# Budowa sterownika

## Moduły sterownika
Sternik składa się z następujących modułów:
- init.lua - mikro moduł startujący, proces bootowania
- bootowanie.lua - moduł bootowania oraz utrzymania sterownika
- _init.lua - moduł uruchamiający pozostałe moduły
- httpServer.lua - biblioteka do mini servera HTTP stworzona przez @yulincoder i @wangzexi https://github.com/wangzexi/NodeMCU-HTTP-Server
- InfluxDB.lua - moduł zapisujący dane ze sterownika w bazie czasu rzeczywistego.
- kalendarz.lua - moduł obsługujący daty i czasy oraz ich porównywania
- logika.lua - moduł zwierający logikę sterownika
- parametyZewnętrzne.lua - moduł pobierający dane pogodowe z serwisu airly.eu.
- pliki.lua - moduł obsługujący pliki zewnętrzne podczas pracy modułu (JSON)
- ServerWWW.lua - moduł obsługujący RESTFul API sterownika
- Vc.lua - moduł inicjujący i pobierający napięcie zasialania sterownika
- WiFi.lua - moduł podłączający sterownik do lokalnej sieci WiFi
- wyslijMejl.lua - moduł wykonujacy sekwencję wysyłania poczty do serwera pocztowego.

