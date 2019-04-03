import { Injectable } from '@angular/core';
import { Observable, BehaviorSubject } from 'rxjs';
import { HttpResponse, HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class PomiaryZewnService {

  constructor(private http: HttpClient) { }

  private obserwatorParametryZewn = new BehaviorSubject<HttpResponse<Response>>(null);
  obserwatorParametryZewn$ = this.obserwatorParametryZewn.asObservable();

  readonly urlDane = 'https://api.openweathermap.org/data/2.5/weather?q=Warsaw,pl&APPID=6e4f748efd51cdf7bdc15e6c9710fda8';
  // http://api.openweathermap.org/data/2.5/weather?q=Warsaw,pl&APPID=6e4f748efd51cdf7bdc15e6c9710fda8

  getRestFul() {
    this.http.get<Response>(this.urlDane, { observe: 'response' }).subscribe (x => {
      this.obserwatorParametryZewn.next(x);
    });
  }
}
