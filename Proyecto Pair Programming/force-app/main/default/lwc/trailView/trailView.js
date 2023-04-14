import { NavigationMixin } from 'lightning/navigation'; // Importa el mixin de navegación
import { LightningElement, wire, api } from 'lwc';
import { getCurrentPageReference } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Trail__c from '@salesforce/schema/Trail__c';
import getTrailWrapper from '@salesforce/apex/LwcController.getTrailWrapper'


export default class MyComponent extends NavigationMixin(LightningElement) {
    // Propiedades para almacenar los datos del trail
    wrapper;
    trailName;
    trailDescription;
    trailEstimatedTime;
    trailTotalPoints;

    unitId;

    modules = []

    
    get recordId() {
        return this.currentPageReference && this.currentPageReference.state.recordId;
    }
    
    set recordId(value) {
        //sets boatId attribute
        this.setAttribute('unitId', value);        
        //sets boatId assignment
        this.unitId = value;
    }

    @api
    get recordId() {
        return this.unitId;
        // returns the trailId
    }

    totalTrailTime;
    totalTrailPoints;

    /*@wire(getTrailWrapper, { trailId: '$recordId' }) // Pasar el recordId como parámetro al método
    trailWrapper({ error, data }) {
        if (data) {
         //Extraer los valores del wrapper de Trail y asignarlos a las propiedades del componente
            this.wrapper = data;
            this.trailName = data.trail.Name;
            this.trailDescription = data.trail.Description__c;
            this.trailEstimatedTime = data.trail.Time__c;
            this.trailTotalPoints = data.trail.Points__c;
            this.modules = data.modules;
            console.log(data);
        } else if (error) {
            // Manejar errores si es necesario
            console.error('Error obteniendo el wrapper de Trail:', error);
        }
    }*/
    @wire(getTrailWrapper, { trailId: '$recordId' })
    trailWrapper({ error, data }) {
        if (data) {
            this.wrapper = data;
            this.trailName = data.trail.Name;
            this.trailDescription = data.trail.Description__c;
            this.modules = data.modules;

            // Calcular el tiempo total del trail sumando el tiempo de los módulos
            this.totalTrailTime = 0;
            this.modules.forEach(module => {
                if (module.TotalTime__c) {
                    this.totalTrailTime += module.TotalTime__c;
                }
            });

            // Calcular los puntos totales del trail sumando los puntos de los módulos
            this.totalTrailPoints = 0;
            this.modules.forEach(module => {
                if (module.Points__c) {
                    this.totalTrailPoints += module.Points__c;
                }
            });

            console.log(data);
        } else if (error) {
            console.error('Error obteniendo el wrapper de Trail:', error);
        }
    }

    // Método para manejar el clic en la unidad
    handleUnitClick(event) {
        const unitId = event.currentTarget.dataset.unitId; // Obtén el ID de la unidad desde el evento

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: unitId,
                objectApiName: 'Unit__c', // Reemplaza con el nombre del objeto de las unidades
                actionName: 'view'
            }
        });
    }

    

}


