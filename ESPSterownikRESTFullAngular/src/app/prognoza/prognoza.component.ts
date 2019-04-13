import { Component, OnInit } from '@angular/core';
import { PrognozaService } from '../services/prognoza.service';
import { Observable, interval } from 'rxjs';
import { ESPAlert, Prognoza } from '../app.component';
import { debounce } from 'rxjs/operators';
import { MessageService } from 'primeng/primeng';

@Component({
  selector: 'app-prognoza',
  templateUrl: './prognoza.component.html',
  styleUrls: ['./prognoza.component.css']
})

export class PrognozaComponent implements OnInit {

  ObserwatorPrognozy$: Observable<Array<ESPAlert>>;
  PAlerty: Prognoza[] = [];
  dataPrognozy: any;

  constructor(private PService: PrognozaService, private messageService: MessageService) {
    this.ObserwatorPrognozy$ = this.PService.obserwatorPrognozy$;
    const wynik = this.ObserwatorPrognozy$.pipe(debounce (() => interval(10)));
    // reaguje na zmianę w obserwable
    wynik.subscribe(x => {
      this.PAlerty = x;
      this.odswierzPrognozyAlertow(); // na bazie obsługi tego co zwaraca observable updateuje dane wna wykresie
    });
  }

  ngOnInit() {
  }

  odswierzPrognozyAlertow() {

    this.PAlerty.forEach((element, i) => { // uzupełnienie o status alertu
      this.PAlerty[i].data = element.data.substring(8, 10) + '/' + element.data.substring(5, 7) + ' ' + element.data.substring(11, 16);
      if (element.status) {
        this.PAlerty[i].wynik = 1;
      } else {
        this.PAlerty[i].wynik = 0;
      }
    });

    this.dataPrognozy = {
      labels: this.PAlerty.map((s) => s.data),
      datasets: [
        {
          label: 'Podlewanie',
          data: this.PAlerty.map((d) => d.wynik),
          // fill: false,
          borderColor: '#73bcf7',
          backgroundColor: '#2a6799'
        }
      ]
    };
  }

  selectData(event) {
    console.log(event.element._index);
    console.log(this.PAlerty[event.element._index].naglowek);
    this.messageService.add({key: 'pr', severity: 'info',
    summary: this.PAlerty[event.element._index].data + '  Prognozowane dane:',
     life: 20000, detail: this.PAlerty[event.element._index].opis});
  }
}
