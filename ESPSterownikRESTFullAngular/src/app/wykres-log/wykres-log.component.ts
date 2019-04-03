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
            borderColor: '#565656'
          },
          {
            label: 'Temp. powietrza',
            data: this.WykresEData.map((d) => d.temp),
            fill: false,
            borderColor: '#565656'
          },
          {
            label: 'Wilgotonosc',
            data: this.WykresEData.map((d) => d.humidity),
            fill: false,
            borderColor: '#565656'
          },
          {
            label: 'PM1',
            data: this.WykresEData.map((d) => d.pm1),
            fill: false,
            borderColor: '#565656'
          },
          {
            label: 'PM10',
            data: this.WykresEData.map((d) => d.pm10),
            fill: false,
            borderColor: '#565656'
          },
          {
            label: 'PM25',
            data: this.WykresEData.map((d) => d.pm25),
            fill: false,
            borderColor: '#565656'
          }
      ]
    };
    console.log(this.WykresEData.map((d) => d.Vc));
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

  usun(){
    this.RService.usunWszystko();
    // this.RService.getObservableESPData().subscribe(eData => this.WykresEData = eData);
    // this.odwierz();
  }
}
