import { Component, OnInit, ViewChild } from '@angular/core';
import { NgForm } from '@angular/forms';
import { ParametryService } from '../services/parametry.service';
import { ESPParametry } from '../app.component';
import { Observable, interval } from 'rxjs';
import { debounce } from 'rxjs/operators';

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

// tslint:disable-next-line: no-use-before-declare
  m: FormulUstawienia;

  constructor(private PService: ParametryService) {
    this.obserwatorParametry$ = PService.obserwatorESPParametry$; // podłacza do obserwable parametrów
    PService.getParametry();
    const wynikP = this.obserwatorParametry$.pipe(debounce (() => interval(1000))); // reaguje na zmianę w obserwable
    wynikP.subscribe(x => {
      this.parametry = x; // wczytuje parametry z observable do parametrow
      console.log('Parametry: ' + this.parametry);
      // tslint:disable-next-line: no-use-before-declare
      this.m = new FormulUstawienia (this.parametry);
    });

  }

  ngOnInit() {
  }

  onSubmit(controlForm) {
    console.log(controlForm);
    console.log(this.m);
  }

  onResetetowanie() {
  // tslint:disable-next-line: no-use-before-declare
    this.m = new FormulUstawienia(this.parametry);
    this.uf.resetForm(this.m);
  }

}

class FormulUstawienia {
  constructor(
    p: ESPParametry,
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
    public wifiHaslo: string = 'dupadupa'
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
