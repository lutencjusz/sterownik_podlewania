# Sterownik podlewania (Logic plant watering)[(->PL)](READMEpl.md)
system of automatic watering of plants based on ESP8266 (Lua) as RESTFul API. All documnetantion is prepared in polish language that will be changed in the nearest future.

# The goal of the project
The presented solution is still developed and modified. Prepared distribution is aimed at organizing documentation for further development depending on the capabilities of the electronic systems used.

# The ESP8266-12E watering controller
The watering controller is a system consisting of an ESP8266 module programmed in the LUA language that controls two water pumps that allow watering balcony or garden flowers (RESTFull API folder). The controller independently makes the decision of watering twice a day on the basis of weather data downloaded from Airly.eu and is prepared to download data from AccuWeather (although this functionality has been disabled). Decisions are saved in the logs of starting pumps or alerts in the event of a failure to start. In addition, the controller send an e-mail informing about the activation of push-ups or reminding about the need to top up the water in the tank (at the moment the water level sensor has been blocked).

## GUI - Angular/CLI (v.7)
Dodatkowo sterownik jest zaopatrzony we własne GUI (katalog ESPSterownikRESTFullAngular), które zostało napisane w Angular/CLI (v. 7), które umożliwia podgląd danych ze sterownika, odczytywanie logów uruchamiania pompek oraz alertów, które wyjaśniają powód braku podlewania.
Można również podejrzeć, kiedy sterownik zaktualizuje warunki pogodowe oraz kiedy będzie próbował ocenić możliwość podlewania.

## Uzupełnienie
Projekt na obecną chwilę nie obejmuje szczegółów związanych z rozwiązaniem elektronicznym. Schematy płytek, zasilania, możliwości ręcznego uruchomienia pompek bez udziału sterownika nie leżą w zakresie opublikowanego materiału.

Ze względów wydajnościowych, możliwość wysyłania SMS'ów zamiast mejla jest obecnie zablokowana.
