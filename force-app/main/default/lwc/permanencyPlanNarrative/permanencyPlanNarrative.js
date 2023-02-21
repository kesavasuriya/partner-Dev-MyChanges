import { LightningElement, track, api, wire } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Permanency_Plan__c.Adoption_Plan_Begin_Date__c', 'Permanency_Plan__c.Adoption_Planning_Stage__c'];

export default class PermanencyPlanNarrative extends UtilityBaseElement {

    readOnly = false;
    @api permanencyRecId;
    permanencyRecord = {};
    disabledButton = false;
    @track nextStage = false;
    Adoption_Plan_Begin_Date__c;

    @wire(getRecord, { recordId: '$permanencyRecId', fields: FIELDS })
    permanencyPlanRec({ error, data }) {

        if (data) {

            this.Adoption_Plan_Begin_Date__c = data.fields.Adoption_Plan_Begin_Date__c.value;
            if (data.fields.Adoption_Planning_Stage__c.value > 4) {

                this.disabledButton = true;
            } else {

                this.disabledButton = false;
            }
        }
    }


    handleSaveNext() {

        this.nextStage = true;

    }

    handleSuccess(event) {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record Updated Successfully';
        this.fireToastMsg();
        const adoptionStageEvent = new CustomEvent('adoptionstage');
        this.dispatchEvent(adoptionStageEvent);
        this.nextStage = false;

    }

    handleError(event) {

        this.title = "Error!";
        this.type = "error";
        this.message = event.detail.detail;
        this.fireToastMsg();
    }

    handleChange(event) {

        this.permanencyRecord[event.target.name] = event.target.value;

    }

    handleSubmit(event) {

        event.preventDefault();
        const fields = event.detail.fields;
        fields.Adoption_Plan_Begin_Date__c = this.permanencyRecord.Adoption_Plan_Begin_Date__c;
        if (this.nextStage) {

            fields.Adoption_Planning_Stage__c = '4';
        }
        this.template
            .querySelector('lightning-record-edit-form').submit(fields);

    }
}