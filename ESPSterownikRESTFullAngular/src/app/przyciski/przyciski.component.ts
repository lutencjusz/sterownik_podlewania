import { Component, OnInit } from '@angular/core';
import { EsprestfullService } from '../services/esprestfull.service';
import { ESPData, ESPAlert } from '../app.component';
import { AlertyService } from '../services/alerty.service';
import { Observable, interval } from 'rxjs';
import { debounce } from 'rxjs/operators';
import { MessageService } from 'primeng/primeng';

@Component({
  selector: 'app-przyciski',
  templateUrl: './przyciski.component.html',
  styleUrls: ['./przyciski.component.css']
})
export class PrzyciskiComponent implements OnInit {

  obserwatorESPAktualnyStatus$: Observable<ESPAlert>;
  aktualnyStatus: ESPAlert;
  naglowek = '';
  opis = '';
  klucz = '';
  dataAlertu = '';
  prior = 3;

  constructor(private RService: EsprestfullService, private messageService: MessageService) {
    this.obserwatorESPAktualnyStatus$ = RService.obserwatorESPAktualnyStatus$;
    this.odswierzAktualnyStatusESPData();
    this.pokazaAktualnyStatus();
   }

  ngOnInit() {
  }

  uruchomPompki() {
    this.RService.uruchomPompki();
    this.RService.getWszystkoESPData();
    this.RService.kiedyNastepneSprawdzenie();
    this.odswierzAktualnyStatusESPData();
    this.pokazaAktualnyStatus();
    // this.AService.getWszystkieAlertyESPData();
  }

  pokazaAktualnyStatus() {
    if (this.naglowek !== '') {
      this.messageService.add({key: 'tc', severity: this.prior + '',
      summary: this.dataAlertu + '  ' + this.naglowek, life: 20000, detail: this.opis});
    }
  }

  odswierzAktualnyStatusESPData() {
    this.RService.getAktualnyStatusESPData();
    const aS = this.obserwatorESPAktualnyStatus$.pipe(debounce(() => interval(2500)));
    aS.subscribe (s => {
      this.aktualnyStatus = s;
      this.naglowek = this.aktualnyStatus.naglowek;
      this.opis = this.aktualnyStatus.opis;
      this.klucz = this.aktualnyStatus.klucz;
      this.prior = this.aktualnyStatus.prior;
      this.dataAlertu = this.aktualnyStatus.dataAlertu;
    });
  }
}
