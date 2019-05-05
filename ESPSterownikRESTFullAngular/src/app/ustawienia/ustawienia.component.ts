import { Component, OnInit, ViewChild } from '@angular/core';
import { NgForm } from '@angular/forms';
import { ParametryService } from '../services/parametry.service';
import { ESPParametry, ESPSatusSprawdzenia, ESPUstawienia } from '../app.component';
import { Observable, interval } from 'rxjs';
import { debounce, concatAll } from 'rxjs/operators';
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
  obserwatorUstawienia$: Observable<ESPUstawienia>;
  obserwatorESPKiedyNastSpraw$: Observable<ESPSatusSprawdzenia>;
  obserwatorKomentarze$: Observable<Array<any>>;
  parametry: ESPParametry;
  ustawienia: ESPUstawienia;
  kiedySpr: ESPSatusSprawdzenia;
  komentarze: any[];
  czyPrzyklady = false;
  t1P = 'Przykład';

// tslint:disable-next-line: no-use-before-declare
  m: FormulUstawienia;

  constructor(private PService: ParametryService, private RService: EsprestfullService) {
    this.obserwatorParametry$ = PService.obserwatorESPParametry$; // podłacza do obserwable parametrów
    this.obserwatorUstawienia$ = PService.obserwatorESPUstawienia$;
    this.obserwatorESPKiedyNastSpraw$ = RService.obserwatorESPKiedyNastSpraw$;
    this.obserwatorKomentarze$ = PService.obserwatorESPKomentarze$;
    this.odswierz();
  }

  ngOnInit() {
  }

  widocznoscPrzykladow() {
    this.czyPrzyklady = !this.czyPrzyklady;
  }

  odswierz() {
    this.RService.kiedyNastepneSprawdzenie();
    const wynikR = this.obserwatorESPKiedyNastSpraw$.pipe(debounce (() => interval(500))); // reaguje na zmianę w obserwable
    wynikR.subscribe(x => {
      this.kiedySpr = x; // wczytuje parametry z observable do parametrow
      console.log('KiedySpr: ' + this.kiedySpr.dataUruchPompek);
    });

    this.PService.getParametry();
    const wynikP = this.obserwatorParametry$.pipe(debounce (() => interval(800))); // reaguje na zmianę w obserwable
    wynikP.subscribe(x => {
      this.parametry = x; // wczytuje parametry z observable do parametrow
      console.log('Parametry: ' + this.parametry.humidityOpt);
    });

    this.PService.getKomentarze();
    const wynikK = this.obserwatorKomentarze$.pipe(debounce (() => interval(900))); // reaguje na zmianę w obserwable
    wynikK.subscribe(x => {
      this.komentarze = x; // wczytuje parametry z observable do parametrow
      console.log('Komentarze: ' + this.komentarze);
    });

    this.PService.getUstawienia();
    const wynikU = this.obserwatorUstawienia$.pipe(debounce (() => interval(1000))); // reaguje na zmianę w obserwable
    wynikU.subscribe(xU => {
      this.ustawienia = xU; // wczytuje parametry z observable do parametrow
      console.log('Ustawienia: ' + this.ustawienia.email);
      // tslint:disable-next-line: no-use-before-declare
      this.m = new FormulUstawienia (this.parametry, this.kiedySpr, this.ustawienia, this.komentarze);
    });
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
    const wU: ESPUstawienia = {};

    wP.VcMax = this.m.zakresVc[1];
    wP.VcMin = this.m.zakresVc[0];
    wP.VpMax = 16;
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

    wU.ip = this.PService.IP;
    wU.ssid = this.m.wifi;
    wU.pass = this.m.wifiHaslo;
    wU.email = this.m.email;
    wU.emailPass = this.m.emailHaslo;
    wU.LED_ON = 0;
    wU.LED_OFF = 1;
    wU.pin = 0;
    wU.maxIloscWierszyLog = this.m.zakresWL[1];
    wU.minIloscWierszyLog = this.m.zakresWL[0];
    wU.czasDoOdswierzeniaMax = this.m.zakresO[1];
    wU.czasDoOdswierzeniaMin = this.m.zakresO[0];
    wU.maxIloscWierszyAlert = this.m.zakresWA[1];
    wU.minIloscWierszyAlert = this.m.zakresWA[0];
    wU.ileCzasuDoWyslaniaMejla = this.m.ileCzasuDoWyslaniaMejla;
    wU.mozliwyCzasNaPodlewanie = this.m.mozliwyCzasNaPodlewanie;
    wU.offsetCzasLetni = this.m.offsetCzasLetni;
    this.PService.setUstawienia(wU);
    console.log ('wU', this.m.k);
    this.PService.setKomentarze(this.m.k);

  }

  onResetetowanie() {
  // tslint:disable-next-line: no-use-before-declare
    this.m = new FormulUstawienia(this.parametry, this.kiedySpr, this.ustawienia, this.komentarze);
    this.uf.resetForm(this.m);
  }

  zakresWChange(e) {
    if (e.values[1] < this.m.humidityOpt) {
      this.m.humidityOpt = e.values[1];
    }
  }

  zakresWOptChange(e) {
    if (e.value > this.m.zakresW[1]) {
      this.m.zakresW[1] = e.value;
    }
  }

}

class FormulUstawienia {
  constructor(
    p: ESPParametry,
    s: ESPSatusSprawdzenia,
    u: ESPUstawienia,
    public k: any[],
    /* jeżeli znaki zapytania to nie trzeba inicjalizować */
    public zakresTemp: number[] = [p.temp_min, p.temp_max],
    public zakresVc: number[] = [p.VcMin, p.VcMax],
    public zakresW: number[] = [p.humidityMin, p.humidityMax],
    public zakresWL: number[] = [u.minIloscWierszyLog, u.maxIloscWierszyLog],
    public zakresWA: number[] = [u.minIloscWierszyAlert, u.maxIloscWierszyAlert],
    public zakresO: number[] = [u.czasDoOdswierzeniaMin, u.czasDoOdswierzeniaMax],
    public humidityOpt: number = p.humidityOpt,
    public mozliwyCzasNaPodlewanie: number = u.mozliwyCzasNaPodlewanie,
    public email: string = u.email,
    public emailHaslo: string = u.emailPass,
    public wifi: string = u.ssid,
    public wifiHaslo: string = u.pass,
    public ileCzasuDoWyslaniaMejla: number = u.ileCzasuDoWyslaniaMejla,
    public offsetCzasLetni: number = u.offsetCzasLetni,
    public czasK1: Date = new Date(0, 0, 0, s.czasKalendarz1Godz, s.czasKalendarz1Min, 0, 0),
    public czasK2: Date = new Date(0, 0, 0, s.czasKalendarz2Godz, s.czasKalendarz2Min, 0, 0),
  ) {
  }
}
