import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { AccordionModule, MultiSelectModule, MessageService, FieldsetModule, PasswordModule, DialogModule } from 'primeng/primeng';
import { PanelModule } from 'primeng/primeng';
import { ButtonModule } from 'primeng/primeng';
import { RadioButtonModule } from 'primeng/primeng';
import { TableModule} from 'primeng/table';

import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { FormsModule } from '@angular/forms';

import { AppComponent } from './app.component';
import { HttpClientModule } from '@angular/common/http';
import { EsprestfullService } from './services/esprestfull.service';
import { InputSwitchModule } from 'primeng/inputswitch';
import { LogComponent } from './log/log.component';
import { LedComponent } from './led/led.component';
import { PrzyciskiComponent } from './przyciski/przyciski.component';
import { ChartModule } from 'primeng/chart';
import { WykresLogComponent } from './wykres-log/wykres-log.component';
import { WykresAlertComponent } from './wykres-alert/wykres-alert.component';
import { SliderModule } from 'primeng/slider';
import { AlertyService } from './services/alerty.service';
import { ToastModule } from 'primeng/toast';
import { ParametryComponent } from './parametry/parametry.component';
import { StanParametruComponent } from './parametry/stan-parametru/stan-parametru.component';
import { PomiaryZewnService } from './services/pomiary-zewn.service';
import { OdliczanieComponent } from './odliczanie/odliczanie.component';
import { TabViewModule } from 'primeng/tabview';
import { PrognozaComponent } from './prognoza/prognoza.component';
import { PrognozaService } from './services/prognoza.service';
import { CamundaEngineComponent } from './camunda-engine/camunda-engine.component';
import { CamundaRestService } from './services/camunda-rest.service';
import { UstawieniaComponent } from './ustawienia/ustawienia.component';

@NgModule({
  declarations: [
    AppComponent,
    LogComponent,
    LedComponent,
    PrzyciskiComponent,
    WykresLogComponent,
    WykresAlertComponent,
    ParametryComponent,
    StanParametruComponent,
    OdliczanieComponent,
    PrognozaComponent,
    CamundaEngineComponent,
    UstawieniaComponent
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    BrowserAnimationsModule,
    FormsModule,
    AccordionModule,
    PanelModule,
    ButtonModule,
    RadioButtonModule,
    TableModule,
    MultiSelectModule,
    InputSwitchModule,
    ChartModule,
    SliderModule,
    ToastModule,
    HttpClientModule,
    FieldsetModule,
    TabViewModule,
    PasswordModule,
    DialogModule
  ],
  providers: [EsprestfullService, MessageService, AlertyService,
    PomiaryZewnService, PrognozaService, CamundaRestService],
  bootstrap: [AppComponent]
})
export class AppModule { }
