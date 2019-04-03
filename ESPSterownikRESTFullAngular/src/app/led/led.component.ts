import { Component, OnInit } from '@angular/core';
import { EsprestfullService } from '../services/esprestfull.service';

@Component({
  selector: 'app-led',
  templateUrl: './led.component.html',
  styleUrls: ['./led.component.css']
})
export class LedComponent implements OnInit {

  constructor(private RService: EsprestfullService) { } // wstrzyknełem service (private RService: EsprestfullServiceService)

  led0: boolean;
  led4: boolean;

  ngOnInit() {
  }

  ustawLED(e: any, nrLED: string) {
    if (e.checked) {
      this.RService.ustawLED ('LED' + nrLED + '=ON').subscribe(odpowiedz => {
       console.log('LED' + nrLED + '=ON: ' + odpowiedz);
      });
    } else {
      this.RService.ustawLED ('LED' + nrLED + '=OFF').subscribe(odpowiedz => {
       console.log('LED' + nrLED + '=OFF' + odpowiedz);
    });
  }
  }

}
