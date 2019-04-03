import { Component, OnInit } from '@angular/core';
import { Observable, interval, timer } from 'rxjs';
import { debounce } from 'rxjs/operators';
import { EsprestfullService } from '../services/esprestfull.service';
import { ESPSatusSprawdzenia, ESPAlert } from '../app.component';

@Component({
  selector: 'app-odliczanie',
  templateUrl: './odliczanie.component.html',
  styleUrls: ['./odliczanie.component.css']
})
export class OdliczanieComponent implements OnInit {

  obserwatorESPKiedyNastSpraw$: Observable<ESPSatusSprawdzenia>;
  kiedySpr: ESPSatusSprawdzenia;
  min = 0;
  godz = 1;
  sek = 0;
  czasKalendarz1Godz = 0;
  czasKalendarz1Min = 0;
  czasKalendarz2Godz = 0;
  czasKalendarz2Min = 0;
  mozliwyCzasNaPodlewanie = 0;
  zaIleUruchPompki = 0;
  dataUruchPompek = '';
  counter: Observable<number>;
  daneKalendarza: any;
  data: any;
  chartOptions: any;

  constructor(private RService: EsprestfullService) {
    this.obserwatorESPKiedyNastSpraw$ = RService.obserwatorESPKiedyNastSpraw$;
    // podłaczenie obserwable serwisu do observable komponentu
    this.odswierzKiedyNastSprawdzenie();
    this.odswierzWykresKalendarza();
   }

   odejmijSek() {
     this.sek = this.sek - 1;
     if (this.sek < 0) { this.min = --this.min; this.sek = 59; }
     if (this.min < 0) { this.godz = --this.godz; this.min = 59; }
     if (this.godz < 0) { this.godz = 0; this.odswierzKiedyNastSprawdzenie(); }
   }

  ngOnInit() {
    const secondsCounter = interval(1000);
    secondsCounter.subscribe(n =>
      this.odejmijSek());
  }

  odswierzKiedyNastSprawdzenie() {
    this.RService.kiedyNastepneSprawdzenie();
    const kns = this.obserwatorESPKiedyNastSpraw$.pipe(debounce(() => interval(3000)));
    kns.subscribe (s => {
      this.kiedySpr = s;
      this.min = this.kiedySpr.min;
      this.godz = this.kiedySpr.godz;
      this.sek = 0;
      this.czasKalendarz1Godz = this.kiedySpr.czasKalendarz1Godz;
      this.czasKalendarz1Min = this.kiedySpr.czasKalendarz1Min;
      this.czasKalendarz2Godz = this.kiedySpr.czasKalendarz2Godz;
      this.czasKalendarz2Min = this.kiedySpr.czasKalendarz2Min;
      this.mozliwyCzasNaPodlewanie = this.kiedySpr.mozliwyCzasNaPodlewanie; // w godzinach
      this.zaIleUruchPompki = this.kiedySpr.zaIleUruchPompki;
      this.dataUruchPompek = this.kiedySpr.dataUruchPompek;
      this.odswierzWykresKalendarza();
    });
  }

  private normalizacjaStr(x: number): string {
    if (x < 10) {
      return '0' + x;
    }
    return x + '';
  }

  odswierzWykresKalendarza() {
    this.daneKalendarza = [this.czasKalendarz1Godz, this.mozliwyCzasNaPodlewanie,
      (this.czasKalendarz2Godz - this.mozliwyCzasNaPodlewanie - this.czasKalendarz1Godz) , this.mozliwyCzasNaPodlewanie,
    (24 - this.czasKalendarz2Godz)];
    console.log('Dane z kalendarza: ' + this.daneKalendarza);
    // this.RService.getWszystkieAlertyESPData();

    this.chartOptions = {
      legend: {display: false}
    }

    this.data = {
      labels: ['Przerwa', this.czasKalendarz1Godz + ':' + this.normalizacjaStr(this.czasKalendarz1Min), 'Przerwa',
       this.czasKalendarz2Godz + ':' + this.normalizacjaStr(this.czasKalendarz2Min), 'Przerwa'],
      datasets: [
          {
              data: this.daneKalendarza,
              backgroundColor: [
                  'red',
                  'green',
                  'red',
                  'green',
                  'red'
              ],
              hoverBackgroundColor: [
                  'red',
                  'green',
                  'red',
                  'green',
                  'red'
              ]
          }]
      };
  }
}
