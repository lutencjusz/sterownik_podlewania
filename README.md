# Sterownik podlewania (Logic plant watering)[(->PL)](READMEpl.md)
system of automatic watering of plants based on ESP8266 (Lua) as RESTFul API. All documnetantion is prepared in polish and english language.

# The goal of the project
The presented solution is still developed and modified. Prepared distribution is aimed at organizing documentation for further development depending on the capabilities of the electronic systems used.

## The ESP8266-12E watering controller
The watering controller is a system consisting of an ESP8266 module programmed in the LUA language that controls two water pumps that allow watering balcony or garden flowers (RESTFull API folder). The controller independently makes the decision of watering twice a day on the basis of weather data downloaded from Airly.eu and is prepared to download data from AccuWeather (although this functionality has been disabled). Decisions are saved in the logs of starting pumps or alerts in the event of a failure to start. In addition, the controller send an e-mail informing about the activation of push-ups or reminding about the need to top up the water in the tank (at the moment the water level sensor has been blocked).

## GUI - Angular / CLI (v.7)
In addition, the controller is provided with its own GUI (ESPSterownikRESTFullAngular folder), which was written in Angular / CLI (v. 7), which allows you to view data from the controller, read pump startup logs and alerts that explain the reason for the lack of watering. You can also see when the controller will update information about weather conditions and when he will try to assess the possibility of watering as well as watering.

# Supplement
At the moment, the project does not include details related to the electronic solution. Circuit diagrams, power supply, the possibility of manual actuation of pumps without the use of the watering controller are not within the scope of the published material.

For performance reasons, the ability to send SMS instead of email is currently blocked.
