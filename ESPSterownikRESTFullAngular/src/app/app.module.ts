import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { AccordionModule, MultiSelectModule, MessageService, FieldsetModule } from 'primeng/primeng';
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
    OdliczanieComponent
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
    FieldsetModule
  ],
  providers: [EsprestfullService, MessageService, AlertyService, PomiaryZewnService],
  bootstrap: [AppComponent]
})
export class AppModule { }
