import { Injectable } from '@angular/core';
import { Prognoza } from '../app.component';
import { Observable, BehaviorSubject } from 'rxjs';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class PrognozaService {

  private obserwatorPrognozy = new BehaviorSubject<Array<Prognoza>>([]);
  obserwatorPrognozy$ = this.obserwatorPrognozy.asObservable();

  constructor(private http: HttpClient) {
    this.getPrognozy();
  }

  getPrognozy() {
    this.http.get<Array<Prognoza>>('http://localhost:3000').subscribe(list => {
      this.obserwatorPrognozy.next(list);
    });
  }
}
