import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-komentarze',
  templateUrl: './komentarze.component.html',
  styleUrls: ['./komentarze.component.css']
})
export class KomentarzeComponent implements OnInit {

  klucz = 't1';
  komentarz = 'Ala ma kota';
  constructor() { }

  ngOnInit() {
  }

}
