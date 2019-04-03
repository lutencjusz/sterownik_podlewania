import { Component, OnInit } from '@angular/core';
import { ESPAlert } from '../app.component';
import { AlertyService } from '../services/alerty.service';
import { Observable, interval } from 'rxjs';
import { debounce } from 'rxjs/operators';
import { MessageService } from 'primeng/primeng';

@Component({
  selector: 'app-wykres-alert',
  templateUrl: './wykres-alert.component.html',
  styleUrls: ['./wykres-alert.component.css']
})
export class WykresAlertComponent implements OnInit {

  data: any;
  ObserwatorWykresAlerty$: Observable<Array<ESPAlert>>;
  wartosci: Array<number> = [0, 0, 0];
  EAlerty: ESPAlert[] = [];

  constructor(private RService: AlertyService, private messageService: MessageService) {
    this.ObserwatorWykresAlerty$ = this.RService.obserwatorWykresuAlertowESPData$;
    const wynik = this.ObserwatorWykresAlerty$.pipe(debounce (() => interval(10))); // reaguje na zmianę w obserwable
    wynik.subscribe(x => {
      this.EAlerty = x;
      this.odswierzWykresAlerty(); // na bazie obsługi tego co zwaraca observable updateuje dane wna wykresie
    });
  }

  ngOnInit() {
  }

  usunWszystkieAlerty() {
    this.RService.usunWszystkieAlerty();
  }

  getWszystkieAlertyESPData() {
    this.RService.getWszystkieAlertyESPData();
  }

  private podajSeverity(p: number): string {
    if (p === 1) { return 'error'; }
    if (p === 2) { return 'warn'; }
    return 'info';
  }

  komunikat(i: number) {
    this.messageService.add({key: 'tp', severity: this.podajSeverity(this.EAlerty[i].prior),
      summary: this.EAlerty[i].dataAlertu + '  ' + this.EAlerty[i].naglowek, life: 20000, detail: this.EAlerty[i].opis});
  }

  odswierzWykresAlerty() {
    this.wartosci = [0, 0, 0];
    // this.RService.getWszystkieAlertyESPData();
    this.EAlerty.forEach ((e, i) => {
      this.wartosci[e.prior - 1] = this.wartosci[e.prior - 1] + 1; // ładowanie danych do wykresu
      this.komunikat(i); // wyświetlenie komunikatów
    });

    console.log('Wartosci alertu: ' + this.wartosci);

    this.data = {
      labels: ['Priorytet 1', 'Priorytet 2', 'Priorytet 3'],
      datasets: [
          {
              data: this.wartosci,
              backgroundColor: [
                  'red', // '#FF6384'
                  '#FFCE56',
                  '#36A2EB'
              ],
              hoverBackgroundColor: [
                  'red',
                  '#FFCE56',
                  '#36A2EB'
              ]
          }]
      };
  }

}
