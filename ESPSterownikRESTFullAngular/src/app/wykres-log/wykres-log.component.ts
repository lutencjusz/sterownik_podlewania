import { Component, OnInit } from '@angular/core';
import { EsprestfullService } from '../services/esprestfull.service';
import { ESPData } from '../app.component';
import { MessageService } from 'primeng/primeng';
import { Observable, interval } from 'rxjs';
import { debounce } from 'rxjs/operators';

@Component({
  selector: 'app-wykres-log',
  templateUrl: './wykres-log.component.html',
  styleUrls: ['./wykres-log.component.css']
})
export class WykresLogComponent implements OnInit {

  changedData: any;
  data: any;
  dataPM: any;
  dataW: any;
  dataT: any;
  EData: ESPData[];
  WykresEData: ESPData[] = [];
  ObserwatorWykresLog$: Observable<Array<ESPData>>;

  constructor(private RService: EsprestfullService, private messageService: MessageService) {
    this.ObserwatorWykresLog$ = RService.obserwatorWykresuESPData$; // podłacza n do obserwable
    const wynik = this.ObserwatorWykresLog$.pipe(debounce (() => interval(10))); // reaguje na zmianę w obserwable
    wynik.subscribe(x => {
      this.WykresEData = x;
      this.odwierz(); // na bazie obsługi tego co zwaraca observable updateuje dane wna wykresie
    });
   }

  ngOnInit() {
    this.RService.getWszystkoESPData().subscribe(eData => this.WykresEData = eData);
    // console.log(this.WykresEData);
  }

  odwierz() {

    this.WykresEData.forEach((element, i) => { // skrócenie zapisu labelek
      element.dataPomiaru = element.dataPomiaru.substring(0, 5) + ' ' + element.dataPomiaru.substring(11, 16);
    });

    this.data = {
      labels: this.WykresEData.map((s) => s.dataPomiaru),
      datasets: [
          {
            label: 'Vc',
            data: this.WykresEData.map((d) => d.Vc),
            fill: false,
            borderColor: '#4bc0c0'
          },
          {
            label: 'Vp',
            data: this.WykresEData.map((d) => d.Vp),
            fill: false,
            borderColor: '#4ef35cf6'
          }
      ]
    };
    this.dataPM = {
      labels: this.WykresEData.map((s) => s.dataPomiaru),
      datasets: [
          {
            label: 'PM1',
            data: this.WykresEData.map((d) => d.pm1),
            // fill: false,
            borderColor: '#a3a2a2',
            backgroundColor: '#a3a2a2'
          },
          {
            label: 'PM10',
            data: this.WykresEData.map((d) => d.pm10),
            // fill: false,
            borderColor: '#757575',
            backgroundColor: '#757575'
          },
          {
            label: 'PM25',
            data: this.WykresEData.map((d) => d.pm25),
            // fill: false,
            borderColor: '#494948',
            backgroundColor: '#494948'
          }
      ]
    };
    this.dataW = {
      labels: this.WykresEData.map((s) => s.dataPomiaru),
      datasets: [
        {
          label: 'Wilgotonosc',
          data: this.WykresEData.map((d) => d.humidity),
          // fill: false,
          borderColor: '#73bcf7',
          backgroundColor: '#2a6799'
        }
      ]
    };
    this.dataT = {
      labels: this.WykresEData.map((s) => s.dataPomiaru),
      datasets: [
        {
          label: 'Temp. powietrza',
          data: this.WykresEData.map((d) => d.temp),
          // fill: false,
          borderColor: '#00790a',
          backgroundColor: '#00790a6c'
        }
      ]
    };
    // console.log(this.WykresEData.map((d) => d.temp));
  }

  selectData(event) {
    // tslint:disable-next-line:max-line-length
    this.messageService.add({severity: 'info', summary: 'Data Selected', detail: this.data.datasets[event.element._datasetIndex].data[event.element._index]});
  }

  getWszystkoESPData() {
    this.RService.getWszystkoESPData();
    // this.RService.getObservableESPData().subscribe(eData => this.WykresEData = eData);
  }

  getAktualneESPData() {
     this.RService.getAktualneESPData();
     // this.odwierz();
  }

  dodajAktualne() {
     this.RService.dodajAktualne();
     // this.RService.getObservableESPData().subscribe(eData => this.WykresEData = eData);
     // this.odwierz();
  }

  usun() {
    this.RService.usunWszystko();
    // this.RService.getObservableESPData().subscribe(eData => this.WykresEData = eData);
    // this.odwierz();
  }
}
