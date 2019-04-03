import { Component, OnInit } from '@angular/core';
import { ParametryService } from '../services/parametry.service';
import { Observable, interval } from 'rxjs';
import { ESPParametry, ESPData} from '../app.component';
import { debounce } from 'rxjs/operators';
import { EsprestfullService } from '../services/esprestfull.service';
import { PomiaryZewnService } from '../services/pomiary-zewn.service';
import { HttpResponse } from '@angular/common/http';
import { isNull } from '@angular/compiler/src/output/output_ast';

@Component({
  selector: 'app-parametry',
  templateUrl: './parametry.component.html',
  styleUrls: ['./parametry.component.css']
})
export class ParametryComponent implements OnInit {

  obserwatorParametry$: Observable<ESPParametry>;
  obserwatorESPAktualne$: Observable<ESPData>;
  obserwatorParametryZewn$: Observable<HttpResponse<Response>>;
  parametry: ESPParametry;
  aDane: ESPData;
  wynikJSON: any;
  pressure_max = 1050;
  pressure_min = 950;
  PM_min = 0;
  PM_max = 100;
  PM1_max = 25;


  constructor(private PService: ParametryService, private RService: EsprestfullService) {
    this.obserwatorParametry$ = PService.obserwatorESPParametry$; // podłacza do obserwable parametrów
    this.obserwatorESPAktualne$ = RService.obserwatorESPData$; // podłącza do observable aktualnych danych


    RService.getAktualneESPData();
    const wynikA = this.obserwatorESPAktualne$.pipe(debounce (() => interval(1000))); // reaguje na zmianę w obserwable
    wynikA.subscribe(x => {
      this.aDane = x; // wczytuje parametry z observable do aktualnych
      // console.log('aDane: ' + this.aDane.dataPomiaru);
    });

    PService.getParametry();
    const wynikP = this.obserwatorParametry$.pipe(debounce (() => interval(1000))); // reaguje na zmianę w obserwable
    wynikP.subscribe(x => {
      this.parametry = x; // wczytuje parametry z observable do parametrow
      console.log('Parametry: ' + this.parametry);
    });
   }

  ngOnInit() {
  }

  private KelninNaC(num: number, decimals: number) {
    return Math.round((num - 273.15) * Math.pow(10, decimals)) / Math.pow(10, decimals);
  }

  private zlaczLiczbe(c: number, u: number) {
    return c + (u / 100);
  }

  private zaokrag(n: number, k: number) {
    const factor = Math.pow(10, k);
    return Math.round(n * factor) / factor;
  }
}
