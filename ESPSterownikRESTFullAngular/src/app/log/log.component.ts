import { Component, OnInit } from '@angular/core';
import { EsprestfullService } from '../services/esprestfull.service';
import { ESPData } from '../app.component';


@Component({
  selector: 'app-log',
  templateUrl: './log.component.html',
  styleUrls: ['./log.component.css']
})
export class LogComponent implements OnInit {

  constructor(private RService: EsprestfullService) { }

  EData: ESPData[];
  cols: any[];
  selectedColumns: any[];

  ngOnInit() {
    this.RService.getWszystkoESPData().subscribe(eData => this.EData = eData);

    this.cols = [
        { field: 'dataPomiaru', header: 'Data Pomiaru' },
        { field: 'temp', header: 'Temp. powietza' },
        { field: 'pm1', header: 'PM 1' },
        { field: 'pm25', header: 'PM 2,5' },
        { field: 'pm10', header: 'PM 10' },
        { field: 'humidity', header: 'Wilgotność' },
        { field: 'pressure', header: 'Ciśnienie' },
        { field: 'Vc', header: 'Napięcie układu' },
        { field: 'Vp', header: 'Napięcie pompek' }
    ];

    this.selectedColumns = this.cols;
  }

}

