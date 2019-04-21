import { Component, OnInit} from '@angular/core';
import { CamundaRestService } from '../services/camunda-rest.service';
import { Task } from '../app.component';
import { Observable, interval } from 'rxjs';

@Component({
  selector: 'app-camunda-engine',
  templateUrl: './camunda-engine.component.html',
  styleUrls: ['./camunda-engine.component.css']
})
export class CamundaEngineComponent implements OnInit {

  obserwatorTaski$: Observable<Task[]>;
  obserwatorStart$: Observable<any>;
  taski: any;
  s: any;
  id: string;

  constructor(private CService: CamundaRestService) {
    this.CService.getTasks();
    this.CService.postProcessInstance('PrognozaPodlewania');
   }

  ngOnInit() {
  }

  Camunda1() {
    this.CService.postProcessInstance('PrognozaPodlewania').subscribe(t => {
      this.s = t;
      this.id = this.s.id;
      console.log(this.s.id);
    });
  }

  Camunda2() {
    this.CService.getProcessExternalTasks('PrognozaPodlewania', this.id).subscribe(t => {
      this.taski = t;
      console.log(this.taski);
    });
    this.taski.forEach(t =>{
      console.log(t.topicName);
    });
  }

  Camunda3() {
    this.CService.getVariablesExternalTasks(this.id).subscribe(t => {
      this.s = t;
      console.log(this.s);
    });

  }

  Camunda4() {
    //this.CService.getProcessTasks('PrognozaPodlewania').subscribe(t => {
    //  this.taski = t;
    //  console.log(this.taski);
    //});

    this.CService.getProcessExternalTasks('PrognozaPodlewania', this.id).subscribe(t => {
      this.taski = t;
      console.log(this.taski);
    });
    this.taski.forEach(t =>{
      console.log(t.topicName);
    });
  }
}



