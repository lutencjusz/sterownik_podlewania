# Installation of watering controller [(->PL)](https://github.com/lutencjusz/sterownik_podlewania/blob/master/ESPSterrownikRESTFul/READMEpl.md)
## Preliminary preparation of ESP8266
1. to prepare firmware I used the [NodeMCU custom builds](https://nodemcu-build.com/). For the willing, you can prepare the right firmware yourself, but it should consist of the following modules (the list of modules is available in the moduly_kompilacji.txt):
```
adc,crypto,encoder,file,gdbstub,gpio,http,net,node,ow,rtcfifo,rtcmem,rtctime,sjson,sntp,tmr,uart,websocket,wifi,tls
```
- it is abslolutly necessary to select the option `LFS options (for master & dev branches)` and select the values depending on the used chip (eg for ESP-12E - all maximum). Due to the limited size of the system's RAM memory, it is necessary to keep all possible modules and functions in the LFS memory as a binary file and from there run them.
- additionally, you must select `ssl = true`, which allows you to add the `tls` module.

2. Prepared versions of the firmware will be sent by e-mail, however, only the version supporting the variable integer can be used, e.g.
```
nodemcu-master-18-modules-2017-02-19-13-15-55-integer.bin - tylko ta jest do wykorzystania
nodemcu-master-18-modules-2017-02-19-13-15-55-float.bin
```
because the `... float.bin` version does not allow you to enter the generated` ESPCSensorRetFul.img` image into the LFS memory.

## Software installation
The installation of software is done using [ESPlorer] (https://esp8266.ru/esplorer/) and requires the use of the ESP8266 class device with at least 40 KB of RAM allocated for the instruction and an additional small space for operating and configuration files.
1. The entire catalog [ESPProviderRESTFul](https://github.com/lutencjusz/sterownik_podlewania/edit/master/ESPSterownikRESTFul/) should be unpacked in a separate directory (eg C:\programs\watering\).
2. Using button *Uload* you should upload the file which is a binary image of the lua modules `ESPSterownikRESTFul.img`
3. In the command line of the ESPlorer you must run
```
node.flashreload("ESPSterownikRESTFul.img")
```
After that the ESP8266 will be restarted, which completes the uploading of the image. Many errors are caused by the fact that there are unnecessary files and programs in the controller's memory, so it is best to delete 'init.lua' file and restart controller before upload the image to its memory.
It is certainly possible to generate your own images that even support float firmware, but the software is adapted to work on variable integers, even for numbers requiring fractional parts.

## Preparation of own versions of binary images by using A Lua Cross-Compile Web Service
As the project is still being developed, it is possible that the version of the development and distribution images will not be adjusted. In this case, it is possible to generate your own image consisting of attached files `.lua':
1. compress `.lua` files (except` init.lua`) to the form 'image.zip'
2. run the tool from Terry Ellison's blog [A Lua Cross-Compile Web Service] (https://blog.ellisons.org.uk/article/nodemcu/a-lua-cross-compile-web-service/) and load the file `image.zip` to the tool via the button *Select file*. 
3. Select the option `REMOTE LUAC.CROSS.INIT (MASTER)`, which will generate file `image.img` and save it.
4. Using the button *Uload* you need to upload the file which is a binary image of the lua modules `image.img` to the watering controller.
5. In the command line of the ESPlorer you must run
```
node.flashreload("image.img")
```
After that the ESP8266 will be restarted, which completes the uploading of the image.

4. Additionally, the following files must be loaded to the driver:
- ustawieniaZ.json
- parametryCz.json
- log.json
- kalendarz.json
- init.lua

5. After reboot, ESP8266 is ready to insert into the target electronic board. Please note that the housing of the controller should be waterproof. The system practically does not heat, so it does not require additional cooling. I have not tested the system in winter conditions...

# Watering controller development
In the next version I intend to introduce the possibility of determining the probability of watering the plants in the future by the controller, which involves the need to plan water replenishment in the tank, in the case of holidays or longer absence.

I am also considering the possibility of changing to the ESP32 platform (MicroPython language) due to memory constraints of the ESP8266 module when downloading weather information from external websites (RESTFul API).

I plan to create a Grafan panel that works with InfluxDB to perform more complex statistics that can improve the logic of the module.

# Modules of controller
The software of watering controller consists of the following modules:
-   `init.lua` - starter module, that iniciate boot process,
-   `bootowanie.lua` - module for booting and maintaining the controller,
-	`_init.lua` - module for loading other modules,
-	`httpServer.lua` - library for mini server HTTP created by @yulincoder i @wangzexi https://github.com/wangzexi/NodeMCU-HTTP-Server,
-	`InfluxDB.lua` - module that records data from the controller in the real-time database,
-	`kalendarz.lua` - module supporting dates and times and their comparison
-	`logika.lua` - module of the controller's logic,
-	`parametyZewnętrzne.lua` - module that downloads weather data from the web service airly.eu.
-	`pliki.lua` - module supporting operations on external files (JSON),
-	`ServerWWW.lua` - module supporting the RESTFul API service of controller,
-	`Vc.lua` - module support metering of supply voltage,
-	`WiFi.lua` - module connecting the controller to the local WiFi network,
-	`wyslijMejl.lua` - module executing the sequence of sending mail

## `init.lua`
I have separated the module to simplify development. it is the only module directly in RAM. Manages the settings of two variables:
- `debugowanie` *(true/false)* - true means that during the module startup and operation the log console will display additional information from modules,
- `zapisDoInfluxDB` *(true/false)* - 
true means that the InfluxDB module will send parameters to the real-time database (use the timer function `zapiszPTestoweInfluxDB()`).
Runs the `bootowanie` module in LFS memory by command:
```
pcall(function()node.flashindex("bootowanie")()end)
```
and gives him control.

## `botowanie.lua`
First, the module cleans out unnecessary files with the `.lua` end, with the exception of` init.lua`, in order to delete unnecessary files created during developing.
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
### Loading modules and setting pre-values of variables

Then it reads the settings file `ustawieniaZ.json`, writes to the object` u` and assigns the object to variables.
Another function `do_next` is responsible for the course of the boot process and is divided into three major groups:
1. Loading of modules:
    - Vc,
    - pliki,
    - WiFi - the module expects to synchronize the clock and the variable setting `czyZsynchonizowano = true`

2. reads the `parametryZewn` module and retrieves weather data by `pobierzDanePowietrza()` and sets the global variable `dataOstatniegoZapisu` giving the current time as a string in the format 'day/month/year hour:minute:second'.
It tries to download data from the external service three times and if it fails, it reboots the controller.

3. loading the `_init.lua` module that loads additional modules:
    - `httpServer.lua`
    - `kalendarz.lua`
    - `logika.lua`
    - `wyslijMail.lua`
    - `InfluxDB.lua` - conditionally, if the variable `zapisDoInfluxDB` is *true*, which is set in 'init.lua'
    - `ServerWWW.lua` - which runs the RESTFul API
Then it loads the values from the service through the function `odswierzZakresyCzujnikow()`. Finally, he runs the function `obslugaModulu()`, which is the main loop of the controller.

### main loop of the controller

Main loop of the controller is carried out by the function `obslugaModulu()`, which is divided into three commands groups:
1. This block of instructions checks data of last loading weather data that is in variable `dataOstatniegoZapisu` 
if it's been longer than minutes in variable`czasDoOdswierzeniaMax` (eg. 60 min.). Then the weather data from the service airly.eu `pobierzDanePowietrza()` for max. 20 seconds.
If the data has been sukcesfully downloaded, the `wynikPZ` object is refreshed, which is the object of the current weather data used by other modules.

2. In this block the appropriate objects are loaded from JSON files through 'initKalendarza()', which is to prepare the environment to check the possibility of starting the pumps: 
- `tLog` - stores information about pump start-ups 
- `tAlarm` - stores information about alarms related to trial run
- `tKalendarz` - stores information about the beginning of periods in which plants can be watered
Then it attempts to write to the InfluxDB database by `zapiszPTestoweInfluxDB()`, if the variable `zapisDoInfluxDB()` is set.

3. The block starts checking the possibility of watering by activating functionality the decision cell `czyAlerthumidity()`, which sets the global variable `czyUruchomicPompkiKalendarz1`, depending on the humidity.
Next is checking the ability to start the pumps by function `uruchomPompki()` and to load new values of objects from files by `initKalendar ()`, to update the data loaded in block nr 2. To correctly calculate the time until the next runing watering, is taken six attempts to read the log "log.json" are carried out to run the controller and if no data is loaded controller is restarting.

4. The block calculates time to start next check of watering in the command
```
tmr.interval(5, d * 60 * 1000) -- d jest w min.
```
To do this, the `zaIleUruchomicPompkiKalendarz()` function is run, corrected by the time it takes to send a reminder e-mail to fill up the water in the tank that is in varable `ileCzasuDoWyslaniaMejla`.
Then it is checked whether the time has been calculated on earlier then now (<0), if yes, it is corrected by varaible `ileCzasuDoWyslaniaMejla`.
If calculated time is still too early then now or is bigger then posbilities of the ESP8266 (over 113 minutes). Calculated time is set to maximum time and write to global variable `dataNastepnegoSprawdzenia` based on `kiedyNastepneSprawdzenie()` function.

Finally, whole porcess of booting is started by command:
```
tmr.alarm(3,1000,1,do_next)
```

## `logika.lua`
The module provides logic for making watering decisions based on available weather parameters. The module consists of the following decision cells that return the modified `ob` object and set the global variable `czyUruchomicPompkiKalendarz1` by `czyAlerthumidity (ob)`:

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
