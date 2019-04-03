import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { ESPParametry } from '../app.component';
import { BehaviorSubject } from 'rxjs';

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
}
