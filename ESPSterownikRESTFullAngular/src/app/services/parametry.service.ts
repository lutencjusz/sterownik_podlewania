import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { ESPParametry, ESPUstawienia } from '../app.component';
import { BehaviorSubject } from 'rxjs';

const httpOptions = {
  headers: new HttpHeaders({
    'Access-Control-Allow-Origin': 'http://localhost:4200',
    'Access-Control-Allow-Methods': 'GET,HEAD,OPTIONS,POST,PUT',
    'Access-Control-Allow-Headers':
    'Origin, X-Requested-With, Content-Type, Accept, x-client-key, x-client-token, x-client-secret, Authorization',
   'Content-Type': 'application/json'})
};

@Injectable({
  providedIn: 'root'
})
export class ParametryService {

  private obserwatorESPParametry = new BehaviorSubject<ESPParametry> (null);
  private obserwatorESPUstawienia = new BehaviorSubject<ESPUstawienia> (null);
  private obserwatorESPKomentarze = new BehaviorSubject<Array<any>> (null);
  obserwatorESPParametry$ = this.obserwatorESPParametry.asObservable();
  obserwatorESPUstawienia$ = this.obserwatorESPUstawienia.asObservable();
  obserwatorESPKomentarze$ = this.obserwatorESPKomentarze.asObservable();
  // IP = '192.168.43.176';
  IP = '192.168.0.15';

  constructor(private http: HttpClient) {
    this.getParametry();
    this.getUstawienia();
    this.getKomentarze();
  }

  getParametry() {
    return this.http.get<ESPParametry>('http://' + this.IP + '/parametry').subscribe(list => {
      this.obserwatorESPParametry.next(list);
    });
  }

  getUstawienia() {
    return this.http.get<ESPUstawienia>('http://' + this.IP + '/ustawienia').subscribe(u => {
      this.obserwatorESPUstawienia.next(u);
    });
  }

  getKomentarze() {
    return this.http.get<any>('http://' + this.IP + '/komentarze').subscribe(k => {
      const t = Object.keys(k).map( kl => ({klucz: kl, wartosc: k[kl]})); // zmainia obiekt na tablice
      this.obserwatorESPKomentarze.next(t);
      console.log(t);
    });
  }

  setParametry(p: ESPParametry) {
    console.log('serwis setParametry', p);
    this.http.post<ESPParametry>('http://localhost:3000/zmianaParametrow', p, httpOptions).subscribe(w => {
      console.log(w);
    });
  }

  setUstawienia(u: ESPUstawienia) {
    console.log('serwis setustawienia', u);
    this.http.post<ESPUstawienia>('http://localhost:3000/zmianaUstawienia', u, httpOptions).subscribe(w => {
      console.log(w);
    });
  }

  setKalendarz(k: Array<string>) {
    this.http.post<Array<string>>('http://localhost:3000/zmianaKalendarza', k, httpOptions).subscribe(w => {
      console.log(w);
    });
  }

  setKomentarze(k) {
    const newObj = {};
    k.forEach(element => {
      newObj[element.klucz] = element.wartosc;
    });
    console.log('newObj', newObj);
    this.http.post<any>('http://localhost:3000/zmianaKomentarze', newObj, httpOptions).subscribe(w => {
      console.log(w);
    });
  }
}


