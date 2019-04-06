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
  EDataN: ESPData[];

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

   private zlaczLiczbe(c: number, u: number) {
    const w = (c + (u / 100));
    return w;
  }

  private zaokrag(n: number, k: number) {
    const factor = Math.pow(10, k);
    return Math.round(n * factor) / factor;
  }
  getWszystkoESPData(): Observable <Array<ESPData>> {
    this.http.get<Array<ESPData>>('http://192.168.0.15/wszystko').subscribe(list => {
        this.EDataN = [];
        list.forEach((d, i) => {
          const data = {} as ESPData;
          data.humidity = this.zlaczLiczbe(d.humidity, d.humidity_u);
          data.temp = this.zlaczLiczbe(d.temp, d.temp_u);
          data.pm10 = this.zlaczLiczbe(d.pm10, d.pm10_u);
          data.pm25 = this.zlaczLiczbe(d.pm25, d.pm25_u);
          data.pm1 = this.zlaczLiczbe(d.pm1 , d.pm1_u);
          data.Vc = this.zlaczLiczbe(d.Vc, d.Vc_u);
          data.pressure = this.zlaczLiczbe(d.pressure, d.pressure_u);
          data.Vp = d.Vp;
          data.dataPomiaru = d.dataPomiaru;
          data.poziomWody = d.poziomWody;
          this.EDataN.push(data);
        });
        console.log(this.EDataN);
        this.obserwatorListyESPData.next(this.EDataN);
        this.obserwatorWykresuESPData.next(this.EDataN);
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
