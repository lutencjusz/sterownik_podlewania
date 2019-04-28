import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})
export class AppComponent {
  title = 'ESPRESTFull';

  constructor() {}

}

export interface ESPData {
  Vp?: number;
  pm1?: number;
  pm1_u?: number;
  pm10?: number;
  pm10_u?: number;
  pm25?: number;
  pm25_u?: number;
  temp?: number;
  temp_u?: number;
  humidity?: number;
  humidity_u?: number;
  pressure?: number;
  pressure_u?: number;
  poziomWody?: boolean;
  Vc?: number;
  Vc_u?: number;
  dataPomiaru?: string;
  dataOdczytu?: string;
}

export interface ESPAlert {
  naglowek?: string;
  opis?: string;
  dataAlertu?: string;
  prior?: number;
  klucz?: string;
}

export interface ESPParametry {
  VpMin?: number;
  VpMax?: number;
  VcMin?: number;
  VcMax?: number;
  humidityMin?: number;
  humidityMax?: number;
  humidityOpt?: number;
  temp_max?: number;
  temp_min?: number;
  mozliwyCzasNaPodlewanie?: number;
}

export interface ESPUstawienia {
  ssid?: string;
  pass?: string;
  email?: string;
  emailPass?: string;
  LED_ON?: number;
  LED_OFF?: number;
  pin?: number;
  maxIloscWierszyLog?: number;
  minIloscWierszyLog?: number;
  czasDoOdswierzeniaMax?: number;
  czasDoOdswierzeniaMin?: number;
  maxIloscWierszyAlert?: number;
  minIloscWierszyAlert?: number;
  ileCzasuDoWyslaniaMejla?: number;
  mozliwyCzasNaPodlewanie?: number;
  offsetCzasLetni?: number;
}

export interface ESPSatusSprawdzenia {
  status?: string;
  godz?: number;
  min?: number;
  czasKalendarz1Godz?: number;
  czasKalendarz1Min?: number;
  czasKalendarz2Godz?: number;
  czasKalendarz2Min?: number;
  mozliwyCzasNaPodlewanie?: number;
  zaIleUruchPompki?: number;
  dataUruchPompek?: string;
}

export interface Prognoza {
  naglowek?: string;
  opis?: string;
  status?: boolean;
  klucz?: string;
  data?: string;
  wynik?: number;
  temp?: number;
  wilgotnosc?: number;
  czyUruchomicK1: boolean;
  zachmurzenie?: number;
  wiatr?: number;
  dsk?: string;
  poraPodlewania?: boolean;
}

export class ProcessDefinition {
  id: string;
  name: string;
  key: string;
}

export interface Task {
  id?: string;
  topicName?: string;
  key?: string;
}

export class MyProcessData {

  constructor(
    public firstName: string,
    public lastName: string,
    public approved: boolean
  ) {  }

}
