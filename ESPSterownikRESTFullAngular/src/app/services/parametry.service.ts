import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { ESPParametry } from '../app.component';
import { BehaviorSubject, Observable } from 'rxjs';

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
  obserwatorESPParametry$ = this.obserwatorESPParametry.asObservable();

  constructor(private http: HttpClient) {
    this.getParametry();
  }

  getParametry() {
    return this.http.get<ESPParametry>('http://192.168.0.15/parametry').subscribe(list => {
      this.obserwatorESPParametry.next(list);
    });
  }

  setParametry(p: ESPParametry) {
    console.log('serwis setParametry', p);
    this.http.post<ESPParametry>('http://localhost:3000/zmianaParametrow', p, httpOptions).subscribe(w => {
      console.log(w);
    });
  }

  setKalendarz(k: Array<string>) {
    console.log('serwis setKalendarz', k);
    this.http.post<Array<string>>('http://localhost:3000/zmianaKalendarza', k, httpOptions).subscribe(w => {
      console.log(w);
    });
  }
}
