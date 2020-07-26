# Logical plant irrigation [(->PL)](READMEpl.md)
System for automatic irrigation of plants based on ESP8266 (Lua) as RESTFul API. All documentation is written in Polish and English.

# The aim of the project
The presented solution is still being developed and modified. The prepared distribution aims to organize the documentation for further development depending on the capabilities of the electronic systems used.

# The ESP8266-12E Irrigation Controller
Irrigation control is a system consisting of an ESP8266 module programmed in LUA language that controls two water pumps that allow watering of balcony or garden flowers (RESTFull API folder). The controller makes the decision to water twice a day, independently based on the weather data downloaded from Airly.eu and is ready to download data from AccuWeather (although this function has been disabled). The decisions are stored in the logs of the start pumps or the warning messages in case of a false start. In addition, the controller sends an email informing about the activation of push-ups or reminding about the need to refill the water in the tank (at the moment the water level sensor is blocked).

# GUI - Angular / CLI (v.7)
In addition, the controller has its own GUI (folder ESPSterownikRESTFullAngular) written in Angular / (v CLI. 7) that allows you to view data from the controller, read pump start logs and warnings that explain the reason for not watering. You can also see when the controller is updating information about weather conditions and when it is attempting to assess the possibility of watering as well as irrigation. The weather forecast is based on [Camunda engine and node.js scripts](https://github.com/lutencjusz/Prognoza_Podlewania).

# Supplement
At the moment the project does not contain any details regarding the electronic solution. Circuit diagrams, power supply, the possibility of manual operation of pumps without the use of the irrigation controller are not included in the published material.

For performance reasons, the ability to send SMS instead of email is currently blocked.
