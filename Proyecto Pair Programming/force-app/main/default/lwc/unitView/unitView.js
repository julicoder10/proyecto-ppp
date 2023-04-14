import { LightningElement, wire, api, track } from 'lwc';
import getUnitWrapper from '@salesforce/apex/LwcController.getUnitWrapper';


export default class UnitView extends LightningElement {
    
    recordId;

    unit;
    unitName;
    unitDescription;
    unitEstimatedTime;
    unitTotalPoints;

    @track
    selectedOption = {};

    questions = [];

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

    @wire(getUnitWrapper, { unitId: '$recordId' })
    unitWrapper({ error, data }) {
        if (data) {
            this.unitName = data.unit.Name;
            this.unitEstimatedTime = data.unit.Time__c;
            this.unitTotalPoints = data.unit.Points__c;
            this.unitDescription= data.unit.Content__c;
            this.questions = data.questions;
            console.log(data.unit);
            console.log(data);
        } else if (error) {
            // Manejar errores si es necesario
            console.error('Error obteniendo el wrapper de Unit:', error);
        }
    }


    handleRadioChange(event){
        const question = event.target.value;
        const answer = event.target.value2;
        this.selectedOption[question] = answer;
        console.log(JSON.parse(JSON.stringify(this.selectedOption)));
    }
}
