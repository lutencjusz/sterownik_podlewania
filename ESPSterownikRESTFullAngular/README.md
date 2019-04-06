# GUI Angular

GUI do obsługi sterownika zostało napisane we frameworku [Angular CLI](https://github.com/angular/angular-cli) version 7.3.3 i służy do szybkiej i kompleksowej prezentacji danych zgromadzonych w sterowniku podlewania w formie graficznej. 
Aplikacja nie posiada funkcjonalności związanej z zabezpieczeniem dostępu przez osoby niepowołane. Być może z czasem pojawi się potrzeba jej wprowadzenia.

## Funkcjonalności
Aplikacja realizuje następujące funkcjonalności:
- przeglądanie alertów pobranych ze sterownika
- przeglądanie logów uruchomieniowych ze sterownika
- prezentacja planowanego czasu uruchomienia i następnej kontroli.
- niezależnie od logiki uruchomienie pompek, każdej z osobna

w celach testowych (funkcjonalności zablokowane):
- wprowadzenie przykładowego logu uruchomieniowego
- wprowadzenie przykładowego alarmu
- restart sterownika

## instalacja aplikacji
Aby zainstalować aplikację należy:
1. Rozpakować katalog [
ESPSterownikRESTFullAngular](https://github.com/lutencjusz/sterownik_podlewania/blob/master/ESPSterownikRESTFullAngular/) w dowolnym miejscu na komputerze *(np. c:\programy\)*
2. Ponieważ w archiwum nie ma modułów angularowych `node_module`, trzeba je zainstalować poprzez polecenie z katalogu rozpakowanej aplikacji:
```
ng install
```
3. Następnie należy uruchomić aplikację poprzez 
```
ng serve
```
Aplikacja będzie dostępna w `http://localhost:4200/` i powinna od razu połączyć się ze sterownikiem, pod warunkiem, że serwis RESTFul API sterownika jest dostępny domyślnie pod adresem 192.168.0.15...
Dalsze budowanie wersji produkcyjnej aplikacji oraz umieszczenie jej na publicznym repozytorium (np. Firebase) nie leży w zakresie tego materiału.

