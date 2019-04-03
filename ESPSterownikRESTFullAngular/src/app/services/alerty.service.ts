import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, timer } from 'rxjs';
import { ESPAlert } from '../app.component';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class AlertyService {

  private obserwatorWykresuAlertowESPData = new BehaviorSubject<Array<ESPAlert>>([]);
  obserwatorWykresuAlertowESPData$ = this.obserwatorWykresuAlertowESPData.asObservable();

  constructor(private http: HttpClient) {
    this.getWszystkieAlertyESPData();
    const source = timer(20000, 300000); // po 20 sekundach uruchamia timer co 5 min wywyłuje update
    const subscribe = source.subscribe(val => {
      this.http.get<Array<ESPAlert>>('http://192.168.0.15/wszystkieAlerty').subscribe(list =>{
        if (list.length !== this.obserwatorWykresuAlertowESPData.getValue().length) {
          // console.log('list.length: ' + list.length + 'ob.length: ' + this.obserwatorListyESPData.getValue().length)
          this.getWszystkieAlertyESPData();
        }
      });
    });
  }

  getWszystkieAlertyESPData() {
    return this.http.get<Array<ESPAlert>>('http://192.168.0.15/wszystkieAlerty').subscribe(list =>{
      this.obserwatorWykresuAlertowESPData.next(list);
    });
  }

  usunWszystkieAlerty() {
    return this.http.get<Array<ESPAlert>>('http://192.168.0.15/usunAlerty').subscribe(list => {
      this.obserwatorWykresuAlertowESPData.next(list);
    });
  }
}
