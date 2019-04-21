import { Observable, BehaviorSubject } from 'rxjs';
import { of } from 'rxjs';
import { catchError, map, tap } from 'rxjs/operators';
import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { ProcessDefinition } from '../app.component';
import { Task } from '../app.component';

const httpOptions = {
  headers: new HttpHeaders({ 'Content-Type': 'application/json' })
};

@Injectable()
export class CamundaRestService {
  private engineRestUrl = 'http://localhost:8080/engine-rest/';
  private obserwatorTaski = new BehaviorSubject<Array<Task>>([]);
  private obserwatorStart = new BehaviorSubject<any>(null);
  obserwatorTaski$ = this.obserwatorTaski.asObservable();
  obserwatorStart$ = this.obserwatorStart.asObservable();

  constructor(private http: HttpClient) {

  }

  getTasks(): Observable<Array<Task>> {
    const endpoint = `${this.engineRestUrl}task?sortBy=created&sortOrder=desc&maxResults=20`;
    return this.http.get<Array<Task>>(endpoint);
  }

  postProcessInstance(processDefinitionKey): Observable<Array<Task>> {
    const endpoint = `${this.engineRestUrl}process-definition/key/${processDefinitionKey}/start`;
    return this.http.post<Array<Task>>(endpoint, '{}', httpOptions);
  }

  getProcessDefinitionTaskKey(processDefinitionKey): Observable<any> {
    const endpoint = `${this.engineRestUrl}process-definition/key/${processDefinitionKey}/startForm`;
    return this.http.get<any>(endpoint);
  }

  getProcessExternalTasks(processDefinitionKey, processInstanceId): Observable<Array<Task>> {
// localhost:8080/engine-rest/external-task?processDefinitionKey=PrognozaPodlewania&processInstanceId=09fa1806-62ad-11e9-9441-1eb57dc23ace
    const endpoint = `${this.engineRestUrl}external-task?processDefinitionKey=${processDefinitionKey}
    &processInstanceId=${processInstanceId}`;
    return this.http.get<Array<Task>>(endpoint);
  }


  getVariablesExternalTasks(processInstanceId): Observable<any> {
  // http://localhost:8080/engine-rest/engine/default/variable-instance?deserializeValues=false&processInstanceIdIn=
      const endpoint = `${this.engineRestUrl}engine/default/variable-instance?deserializeValues=false&processInstanceIdIn=${processInstanceId}`;
      return this.http.get<any>(endpoint);
    }

  getProcessTasksId(iD): Observable<Array<Task>> {
    const endpoint = `${this.engineRestUrl}task?id=${iD}`;
    return this.http.get<Array<Task>>(endpoint);
  }


// --------------------------------

  getTaskFormKey(taskId: string): Observable<any> {
    const endpoint = `${this.engineRestUrl}task/${taskId}/form`;
    return this.http.get<any>(endpoint).pipe(
      tap(form => this.log(`fetched taskform`)),
      catchError(this.handleError('getTaskFormKey', []))
    );
  }

  getVariablesForTask(taskId: string, variableNames: string): Observable<any> {
    const endpoint = `${this.engineRestUrl}task/${taskId}/form-variables?variableNames=${variableNames}`;
    return this.http.get<any>(endpoint).pipe(
      tap(form => this.log(`fetched variables`)),
      catchError(this.handleError('getVariablesForTask', []))
    );
  }

  postCompleteTask(taskId: string, variables: object): Observable<any> {
    const endpoint = `${this.engineRestUrl}task/${taskId}/complete`;
    return this.http.post<any>(endpoint, variables).pipe(
      tap(tasks => this.log(`posted complete task`)),
      catchError(this.handleError('postCompleteTask', []))
    );
  }

  getProcessDefinitions(): Observable<ProcessDefinition[]> {
    return this.http.get<ProcessDefinition[]>(this.engineRestUrl + 'process-definition?latestVersion=true').pipe(
      tap(processDefinitions => this.log(`fetched processDefinitions`)),
      catchError(this.handleError('getProcessDefinitions', []))
    );
  }

  postProcessInstance2(processDefinitionKey, variables): Observable<any> {
    const endpoint = `${this.engineRestUrl}process-definition/key/${processDefinitionKey}/start`;
    return this.http.post<any>(endpoint, variables).pipe(
      tap(processDefinitions => this.log(`posted process instance`)),
      catchError(this.handleError('postProcessInstance', []))
    );
  }

  deployProcess(fileToUpload: File): Observable<any> {
    const endpoint = `${this.engineRestUrl}deployment/create`;
    const formData = new FormData();

    formData.append('fileKey', fileToUpload, fileToUpload.name);

    return this.http.post(endpoint, formData);
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {

      // TODO: send the error to remote logging infrastructure
      console.error(error); // log to console instead

      // TODO: better job of transforming error for user consumption
      this.log(`${operation} failed: ${error.message}`);

      // Let the app keep running by returning an empty result.
      return of(result as T);
    };
  }

  /** Log a HeroService message with the MessageService */
  private log(message: string) {
    console.log(message);
  }
}
