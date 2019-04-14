import { Injectable } from '@angular/core';
import { Prognoza, ESPParametry } from '../app.component';
import { Observable, BehaviorSubject } from 'rxjs';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class PrognozaService {

  private obserwatorPrognozy = new BehaviorSubject<Array<Prognoza>>([]);
  private obserwatorParametry = new BehaviorSubject<ESPParametry>(null);
  obserwatorPrognozy$ = this.obserwatorPrognozy.asObservable();
  obserwatorParametry$ = this.obserwatorParametry.asObservable();

  constructor(private http: HttpClient) {
    this.getPrognozy();
    this.getParametry();
  }

  getPrognozy() {
    this.http.get<Array<Prognoza>>('http://localhost:3000').subscribe(list => {
      this.obserwatorPrognozy.next(list);
    });
  }

  getParametry() {
    this.http.get<ESPParametry>('http://localhost:3000/parametry').subscribe(list => {
      this.obserwatorParametry.next(list);
    });
  }
}
