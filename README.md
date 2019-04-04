# Sterownik podlewania (Logic plant watering)
system of automatic watering of plants based on ESP8266 (Lua) as RESTFul API. All documnetantion is prepared in polish language that will be changed in the nearest future.

# Cel projektu
Przedstawione rozwiązanie jest nadal rozwijane i modyfikowane. Przygotowana dystrybucja ma celu uporządkowanie dokumentacji w celu dalszego rozwoju w zależności od możliwości zastosowanych układów elektronicznych.

## Sterownik ESP8266-12E
Sterownik podlewania jest systemem składającym się z modułu ESP8266 zaprogramowanego w języku LUA sterującego dwoma pompkami wodnymi umożliwijacymi podlewania kwiatków balkonowych lub ogrodowych (katalog ESPSterownikRESTFull). sterownik samodzielnie podejmuje decyzję o podlewaniu najwyzej dwa razy dziennie na podstawie danych pogodowych ściąganych z serwisu Airly.eu oraz jest przygotowany do pobierania danych z AccuWeather (choć ta funkcjoaność została wyłączona). Decyzje zostają zapisane w logach z uruchamiania pompek lub alertów w przypadku braku uruchomienia. Dodatkowo wysyłany jest mejl informaujacy o uruchomieniu pompek lub przypomnieniach o konieczności uzupełnienia wody w zbiorniku (na chwilę obecną czujka poziomu wody została zablokowana).

## GUI - Angular/CLI (v.7)
Dodatkowo sterownik jest zaopatrzony we własne GUI (katalog ESPSterownikRESTFullAngular), które zostało napisane w Angular/CLI (v. 7), które umożliwia podgląd danych ze sterownika, odczytywanie logów uruchamiania pompek oraz alertów, które wyjaśniają powód braku podlewania.
Można również podejrzeć, kiedy sterownik zaktualizuje warunki pogodowe oraz kiedy będzie próbował ocenić możliwość podlewania.

## Uzupełnienie
Projekt na obecną chwilę nie obejmuje szczegółów związanych z rozwiązaniem elektronicznym. Schematy płytek, zasilania, możliwości ręcznego uruchomienia pompek bez udziału sterownika nie leżą w zakresie opublikowanego materiału.

Ze względów wydajnościowych, możliwość wysyłania SMS'ów zamiast mejla jest obecnie zablokowana.
