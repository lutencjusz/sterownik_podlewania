import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { ESPData, ESPSatusSprawdzenia, ESPAlert } from '../app.component';
import { Observable, BehaviorSubject, timer } from 'rxjs';
import { ParametryService } from './parametry.service';
import { PomiaryZewnService } from './pomiary-zewn.service';

@Injectable({
  providedIn: 'root'
})
export class EsprestfullService {

  private obserwatorListyESPData = new BehaviorSubject<Array<ESPData>>([]);
  private obserwatorWykresuESPData = new BehaviorSubject<Array<ESPData>>([]);
  private obserwatorESPData = new BehaviorSubject<ESPData>(null);
  private obserwatorESPKiedyNastSpraw = new BehaviorSubject<ESPSatusSprawdzenia>(null);
  private obserwatorESPAktualnyStatus = new BehaviorSubject<ESPAlert>(null);
  obserwatorWykresuESPData$ = this.obserwatorWykresuESPData.asObservable();
  obserwatorListyESPData$ = this.obserwatorListyESPData.asObservable();
  obserwatorESPData$ = this.obserwatorESPData.asObservable();
  obserwatorESPKiedyNastSpraw$ = this.obserwatorESPKiedyNastSpraw.asObservable();
  obserwatorESPAktualnyStatus$ = this.obserwatorESPAktualnyStatus.asObservable();

  constructor(private http: HttpClient, private PService: ParametryService, private PZService: PomiaryZewnService) {
    // this.getWszystkoESPData();
    const source = timer(20000, 60000); // po 20 sekundach uruchamia timer co 1 minute wywyłuje update
    const subscribe = source.subscribe(val => {
      this.http.get<Array<ESPData>>('http://192.168.0.15/wszystko').subscribe(list => {
        if (list.length !== this.obserwatorWykresuESPData.getValue().length) {
          // console.log('list.length: ' + list.length + 'ob.length: ' + this.obserwatorListyESPData.getValue().length)
          this.getAktualneESPData();
          this.getWszystkoESPData();
        }
      });
    });
    this.kiedyNastepneSprawdzenie();
    this.getAktualnyStatusESPData();
   }

  getWszystkoESPData(): Observable <Array<ESPData>> {
    this.http.get<Array<ESPData>>('http://192.168.0.15/wszystko').subscribe(list => {
        this.obserwatorListyESPData.next(list);
        this.obserwatorWykresuESPData.next(list);
    });
    return this.obserwatorListyESPData.asObservable();
  }

  getObservableESPData(): Observable <Array<ESPData>> {
    return this.obserwatorWykresuESPData.asObservable();
  }

  getAktualneESPData(): Observable <Array<ESPData>> {
    this.http.get<Array<ESPData>>('http://192.168.0.15/aktualne').subscribe(list => {
      this.obserwatorListyESPData.next(list);
      this.PZService.getRestFul();
      this.obserwatorESPData.next(list[0]); // pobiera dane aktualne
      this.PService.getParametry();
    });
    return this.obserwatorListyESPData.asObservable();
  }

  ustawLED(parametr: string): Observable<string> { // musi być obserwable
    // console.log ('Odpalam LED0');
    return this.http.get<string>('http://192.168.0.15/' + parametr);
  }

  dodajAktualne(): Observable <Array<ESPData>> {
    this.http.get<Array<ESPData>>('http://192.168.0.15/dodajAktualne').subscribe(list => {
      this.obserwatorListyESPData.next(list);
      this.PZService.getRestFul();
      this.obserwatorESPData.next(list[0]); // pobiera dane aktualne
      this.PService.getParametry();
    });
    return this.obserwatorListyESPData.asObservable();
  }
  usunWszystko(): Observable <Array<ESPData>> {
    this.http.get<Array<ESPData>>('http://192.168.0.15/usunLog').subscribe(list => {
      this.obserwatorWykresuESPData.next(list);
      this.obserwatorListyESPData.next(list);
    });
    return this.obserwatorListyESPData.asObservable();
  }

  uruchomPompki() {
    return this.http.get<Array<ESPData>>('http://192.168.0.15/uruchomPompki').subscribe(list => {
    });
  }

  kiedyNastepneSprawdzenie() {
    this.http.get<ESPSatusSprawdzenia>(('http://192.168.0.15/kiedyNastepneSprawdzenie'))
    .subscribe (data => {
      this.obserwatorESPKiedyNastSpraw.next(data);
    });
  }

  getAktualnyStatusESPData() {
    this.http.get<ESPAlert>(('http://192.168.0.15/aktualnyStatus'))
    .subscribe (data => {
      this.obserwatorESPAktualnyStatus.next(data);
    });
  }
}
