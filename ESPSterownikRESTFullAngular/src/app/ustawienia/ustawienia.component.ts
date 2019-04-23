import { Component, OnInit, ViewChild } from '@angular/core';
import { NgForm } from '@angular/forms';
import { ParametryService } from '../services/parametry.service';
import { ESPParametry, ESPSatusSprawdzenia } from '../app.component';
import { Observable, interval } from 'rxjs';
import { debounce } from 'rxjs/operators';
import { EsprestfullService } from '../services/esprestfull.service';

@Component({
  selector: 'app-ustawienia',
  templateUrl: './ustawienia.component.html',
  styleUrls: ['./ustawienia.component.css']
})

export class UstawieniaComponent implements OnInit {
  @ViewChild('uf') /* przekazywanie referencji z formularza */
  uf: NgForm;
  obserwatorParametry$: Observable<ESPParametry>;
  parametry: ESPParametry;
  obserwatorESPKiedyNastSpraw$: Observable<ESPSatusSprawdzenia>;
  kiedySpr: ESPSatusSprawdzenia;

// tslint:disable-next-line: no-use-before-declare
  m: FormulUstawienia;

  constructor(private PService: ParametryService, private RService: EsprestfullService) {
    this.obserwatorParametry$ = PService.obserwatorESPParametry$; // podłacza do obserwable parametrów
    this.obserwatorESPKiedyNastSpraw$ = RService.obserwatorESPKiedyNastSpraw$;

    RService.kiedyNastepneSprawdzenie();
    const wynikR = this.obserwatorESPKiedyNastSpraw$.pipe(debounce (() => interval(500))); // reaguje na zmianę w obserwable
    wynikR.subscribe(x => {
      this.kiedySpr = x; // wczytuje parametry z observable do parametrow
      console.log('KiedySpr: ' + this.kiedySpr);
    });

    PService.getParametry();
    const wynikP = this.obserwatorParametry$.pipe(debounce (() => interval(1000))); // reaguje na zmianę w obserwable
    wynikP.subscribe(x => {
      this.parametry = x; // wczytuje parametry z observable do parametrow
      console.log('Parametry: ' + this.parametry);
      // tslint:disable-next-line: no-use-before-declare
      this.m = new FormulUstawienia (this.parametry, this.kiedySpr);
    });

  }

  ngOnInit() {
  }

  zamienLiczbeNaStr2(n: number): string {
    if (n < 10) {
      return '0' + n;
    } else {
      return n + '';
    }
  }

  onSubmit(controlForm) {
    console.log(controlForm);
    // console.log(this.m);
    const wP: ESPParametry = {};
    wP.VcMax = this.m.zakresVc[1];
    wP.VcMin = this.m.zakresVc[0];
    wP.VpMax = 11;
    wP.VpMin = 9;
    wP.humidityMax = this.m.zakresW[1];
    wP.humidityMin = this.m.zakresW[0];
    wP.humidityOpt = this.m.humidityOpt;
    wP.temp_min = this.m.zakresTemp[0];
    wP.temp_max = this.m.zakresTemp[1];
    wP.mozliwyCzasNaPodlewanie = this.m.mozliwyCzasNaPodlewanie;
    // console.log(wP);
    this.PService.setParametry(wP);
    const k: string[] = [];
    k[0] = this.zamienLiczbeNaStr2(this.m.czasK1.getHours()) + ':' + this.zamienLiczbeNaStr2(this.m.czasK1.getMinutes());
    k[1] = this.zamienLiczbeNaStr2(this.m.czasK2.getHours()) + ':' + this.zamienLiczbeNaStr2(this.m.czasK2.getMinutes());
    // console.log(k);
    this.PService.setKalendarz(k);
  }

  onResetetowanie() {
  // tslint:disable-next-line: no-use-before-declare
    this.m = new FormulUstawienia(this.parametry, this.kiedySpr);
    this.uf.resetForm(this.m);
  }

}

class FormulUstawienia {
  constructor(
    p: ESPParametry,
    s: ESPSatusSprawdzenia,
    /* jeżeli znaki zapytania to nie trzeba inicjalizować */
    public zakresTemp: number[] = [p.temp_min, p.temp_max],
    public zakresVc: number[] = [p.VcMin, p.VcMax],
    public zakresW: number[] = [p.humidityMin, p.humidityMax],
    public VpMin?: number,
    public VpMax?: number,
    public VcMin?: number,
    public VcMax?: number,
    public humidityMin?: number,
    public humidityMax?: number,
    public humidityOpt: number = p.humidityOpt,
    public tempMax?: number,
    public tempMin?: number,
    public czasKalendarz1Godz?: number,
    public czasKalendarz1Min?: number,
    public czasKalendarz2Godz?: number,
    public czasKalendarz2Min?: number,
    public mozliwyCzasNaPodlewanie: number = 2,
    public email: string = 'lutencjusz@gmial.com',
    public emailHaslo: string = 'dupadupa',
    public wifi: string = 'Tech_D0044603',
    public wifiHaslo: string = 'dupadupa',
    public czasK1: Date = new Date(0, 0, 0, s.czasKalendarz1Godz, s.czasKalendarz1Min, 0, 0),
    public czasK2: Date = new Date(0, 0, 0, s.czasKalendarz2Godz, s.czasKalendarz2Min, 0, 0)
  ) {
  }
}

// VpMin?: number;
// VpMax?: number;
// VcMin?: number;
// VcMax?: number;
// humidityMin?: number;
// humidityMax?: number;
// humidityOpt?: number;
// temp_max?: number;
// temp_min?: number;
// czasKalendarz1Godz?: number;
// czasKalendarz1Min?: number;
// czasKalendarz2Godz?: number;
// czasKalendarz2Min?: number;
// mozliwyCzasNaPodlewanie?: number;
