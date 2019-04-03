# Sterownik podlewania (Logic plant watering)
system of logic plant watering based on ESP8266 (Lua) as RESTFul API. All documnetantion is prepared in polish language that will be changed in the future.

# Opis rozwiązania
Sterownik podlewania jest systemem składającym się z modułu ESP8266 zaprogramowanego w języku LUA sterującego dwoma pompkami wodnymi umożliwijacymi podlewania kwiatków balkonowych lub ogrodowych, sterownik samodzielnie podejmuje decyzję o podlewaniu najwyzej dwa razy dziennie na podstawie danych pogodowych ściąganych z serwisu Airly.eu oraz jest przygotowany do pobierania danych z AccuWeather (choć ta funkcjoaność została wyłączona). Decyzje zostają zapisane w logach z uruchamiania pompek lub alertów w przypadku braku uruchomienia. 

Dodatkowo sterownik jest zaopatrzony we własne GUI, które zostało napisane w Angular/CLI (v. 7), które umożliwia podgląd danych ze sterownika, odczytywanie logów uruchamiania pompek oraz alertów, które zablokowały uruchomienie sterownika.
Można również podejrzeć, kiedy sterownik zaktualizuje warunki pogodowe oraz kiedy będzie próbował ocenić możliwość podlewania.

Dodatkowo moduł powiadamia mejlowo o koniecznosći uzupełnienie wody w zbiorniku godzinę przed planowanym podlewaniem oraz o tym, że podlał rośliny. 

Możliwość wysyłania SMS zamiast mejla jest obecnie zablokowana.


