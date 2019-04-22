import { Component, OnInit } from '@angular/core';
import { PrognozaService } from '../services/prognoza.service';
import { Observable, interval, timer } from 'rxjs';
import { ESPAlert, Prognoza, ESPParametry } from '../app.component';
import { debounce } from 'rxjs/operators';
import { MessageService } from 'primeng/primeng';
import { element } from 'protractor';
import { CamundaRestService } from '../services/camunda-rest.service';

@Component({
  selector: 'app-prognoza',
  templateUrl: './prognoza.component.html',
  styleUrls: ['./prognoza.component.css']
})

export class PrognozaComponent implements OnInit {

  ObserwatorPrognozy$: Observable<Array<Prognoza>>;
  ObserwatorParametry$: Observable<ESPParametry>;
  PAlerty: Prognoza[] = [];
  dataPrognozy: any;
  parametry: ESPParametry;
  CzyLadujePrognoze = true;
  komentarz1 = '';
  komentarz2 = '';
  proces: any;
  taski: any;

  constructor(private PService: PrognozaService, private CService: CamundaRestService,  private messageService: MessageService) {
    this.ObserwatorPrognozy$ = this.PService.obserwatorPrognozy$;
    this.ObserwatorParametry$ = this.PService.obserwatorParametry$;

    const wynikPrognozy = this.ObserwatorPrognozy$.pipe(debounce (() => interval(10)));
    // reaguje na zmianę w obserwable
    wynikPrognozy.subscribe(x => {
      this.PAlerty = x;
      this.odswierzPrognozyAlertow(); // na bazie obsługi tego co zwaraca observable updateuje dane wna wykresie
    });

    const wynikParametry = this.ObserwatorParametry$.pipe(debounce (() => interval(10)));
    // reaguje na zmianę w obserwable
    wynikParametry.subscribe(x => {
      this.parametry = x;
    });
  }

  ngOnInit() {

  }

  ladowaniePognozy() {
    let licznik = 0;
    this.komentarz1 = 'Uruchamiam proces Camunda: Prognoza Pogody...';
    this.CService.postProcessInstance('PrognozaPodlewania').subscribe(t => {
      this.proces = t;
      this.komentarz2 = 'Uruchomiłem proces id: ' + this.proces.id;
    });
    const timerPobierP = timer(1000, 1000); // po 20 sekundach uruchamia timer co 1 minute wywyłuje update
    const subscribe = timerPobierP.subscribe(val => {
      this.komentarz1 = 'Czekam na micro: ';
      licznik += 1;
      this.CService.getProcessExternalTasks('PrognozaPodlewania', this.proces.id).subscribe(t => {
        this.taski = t;
      });
      if (this.taski) {
        this.taski.forEach(t => {
          this.komentarz1 += t.topicName + '; ';
        });
      }
      if (licznik > 0 && this.taski && this.taski.length === 0) {
        subscribe.unsubscribe(); // wyłacza timer
        this.komentarz1 = '';
        this.komentarz2 = 'Proces ukończony. id: ' + this.proces.id;
        const wynikPrognozy = this.ObserwatorPrognozy$.pipe(debounce (() => interval(100)));
        // reaguje na zmianę w obserwable
        wynikPrognozy.subscribe(x => {
          this.PAlerty = x;
          if (this.PAlerty.length > 0) {
            this.odswierzPrognozyAlertow(); // na bazie obsługi tego co zwaraca observable updateuje dane wna wykresie
            this.komentarz2 = '';
          }
        });

      }
    });

  }

  odswierzPrognozyAlertow() {
    // tslint:disable-next-line:no-shadowed-variable
    this.PAlerty.forEach((element, i) => { // uzupełnienie o parametry alertu
      // console.log(element.data);
      let szansaNaPodlewanie = 0;
      if (element.data.length > 13) {
        this.PAlerty[i].data = element.data.substring(8, 10) + '/' + element.data.substring(5, 7) + ' ' + element.data.substring(11, 16);
      }
      if (element.status) {
        szansaNaPodlewanie += 40;
      }
      if (element.poraPodlewania) {
        szansaNaPodlewanie += 60;
      }
      this.PAlerty[i].wynik = szansaNaPodlewanie;
    });

    this.dataPrognozy = {
      labels: this.PAlerty.map((s) => s.data),
      datasets: [
        {
          label: 'Podlewanie',
          data: this.PAlerty.map((d) => d.wynik),
          // fill: false,
          borderColor: '#4bc0c0',
          backgroundColor: '#1bbb06'
        },
        {
          label: 'Temperatura',
          data: this.PAlerty.map((d) => d.temp),
          // fill: false,
          borderColor: '#00790a',
          backgroundColor: '#00790a6c'
        },
        {
          label: 'Wilgotność',
          data: this.PAlerty.map((d) => d.wilgotnosc),
          // fill: false,
          borderColor: '#73bcf7',
          backgroundColor: '#2a6799'
        }
      ]
    };
  }

  selectData(event) {
    // console.log(event.element._index);
    // console.log(this.PAlerty[event.element._index].naglowek);
    let textPoryPodlewania = ';\nTo nie jest pora podlewania';
    if (this.PAlerty[event.element._index].poraPodlewania) {
      textPoryPodlewania = ';\nPora podlewania';
    }
    this.messageService.add({key: 'pr', severity: 'info',
    summary: this.PAlerty[event.element._index].data + ' ' + this.PAlerty[event.element._index].naglowek,
     life: 20000,
    detail: this.PAlerty[event.element._index].opis + '\nPrognozowane dane:\nTemperatura: '
    + this.PAlerty[event.element._index].temp
    + ' <' + this.parametry.temp_min
    + ';' + this.parametry.temp_max + '>\nWilgotność: '
    + this.PAlerty[event.element._index].wilgotnosc
    + ' <' + this.parametry.humidityMin
    + ';' + this.parametry.humidityOpt
    + ';' + this.parametry.humidityMax + '>;\nZachmurzenie: '
    + this.PAlerty[event.element._index].zachmurzenie
    + ';\nWiatr: ' + this.PAlerty[event.element._index].wiatr
    + ';\nOpis: ' + this.PAlerty[event.element._index].dsk
    + textPoryPodlewania
    });
  }
}
