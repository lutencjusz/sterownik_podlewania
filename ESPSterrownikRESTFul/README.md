# Installation of watering controller
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
### Loading modules and setting pre-values ​​of variables

Then it reads the settings file `ustawieniaZ.json`, writes to the object` u` and assigns the object to variables.
Another function `do_next` is responsible for the course of the boot process and is divided into three major groups:
1. Loading of modules:
    - Vc,
    - pliki,
    - WiFi - the module expects to synchronize the clock and the variable setting `czyZsynchonizowano = true`

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
