import { Component, OnInit, Input } from '@angular/core';

@Component({
  selector: 'app-stan-parametru',
  templateUrl: './stan-parametru.component.html',
  styleUrls: ['./stan-parametru.component.css']
})
export class StanParametruComponent implements OnInit {

  @Input()
  nazwa: string;

  @Input()
  min: number;

  @Input()
  max: number;

  @Input()
  jednostka: string;

  @Input()
  stan: number;

  constructor() { }

  ngOnInit() {
  }

}
