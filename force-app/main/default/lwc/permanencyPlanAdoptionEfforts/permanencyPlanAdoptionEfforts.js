import { LightningElement, track, api, wire } from 'lwc';
import getRecords from '@salesforce/apex/RelatedListController.getRecords';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';


const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];

const fields = ['Id', 'Effort_Date__c', 'Type_of_Effort__c', 'Notes__c'];

const columns = [
    { label: 'Effort Date', fieldName: 'Effort_Date__c', type: 'date', wrapText: true, type: 'date', typeAttributes: { month: 'numeric', day: 'numeric', year: 'numeric', timeZone: 'UTC' } },
    { label: 'Type of Effort', fieldName: 'Type_of_Effort__c', type: 'text', wrapText: true },
    { label: 'Notes', fieldName: 'Notes__c', type: 'text', wrapText: true },
    { type: 'action', typeAttributes: { rowActions: actions } }

];

const FIELDS = ['Permanency_Plan__c.Date_Exception_granted_child_interests__c', 'Permanency_Plan__c.Adoption_Planning_Stage__c'];

const queryDetail = {
    fieldValue: fields,
    filterValue: 'Permanency_Plan__c =',
    objectApiName: 'Adoption_Efforts__c'

}
export default class PermanencyPlanAdoptionEfforts extends UtilityBaseElement {

    @api permanencyRecId;
    columns = columns;
    @track showModal = false;
    @track effortRecords = [];
    @track refreshdata = [];
    effortRecord = {};
    efforRecId = '';
    @track permanencyRec = {};
    @track nextStage = false;
    disabledButton = false;


    queryDetail = JSON.stringify(queryDetail);

    @wire(getRecords, { recordId: '$permanencyRecId', queryDetails: '$queryDetail' })
    relateRecords(response) {

        this.refreshdata = response;
        if (response.data) {

            this.effortRecords = this.checkNamespaceApplicable(response.data, false);

        } else if (response.error) {

            this.title = "Error!";
            this.type = "error";
            this.message = response.error;
            this.fireToastMsg();
        }
    }


    @wire(getRecord, { recordId: '$permanencyRecId', fields: FIELDS })
    permanencyPlanRec({ error, data }) {

        if (data) {

            this.permanencyRec.Date_Exception_granted_child_interests__c = data.fields.Date_Exception_granted_child_interests__c.value;
            if (data.fields.Adoption_Planning_Stage__c.value > 1) {

                this.disabledButton = true;
            } else {

                this.disabledButton = false;
            }
        }
    }

    handleSaveNext() {

        this.nextStage = true;

    }


    handleAddAdoption() {

        this.efforRecId = '';
        this.effortRecord = {};
        this.showModal = true;
    }

    closeModal() {

        this.showModal = false;
    }

    handlePermanencyChange(event) {

        this.permanencyRec[event.target.name] = event.target.value;
    }

    handleSubmit(event) {

        event.preventDefault();
        const fields = event.detail.fields;
        if (this.nextStage) {

            fields.Adoption_Planning_Stage__c = '2';
        }
        fields.Date_Exception_granted_child_interests__c = this.permanencyRec.Date_Exception_granted_child_interests__c;
        this.template
            .querySelector('[data-name="permanencyForm"]').submit(fields);

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

    handleEffortSubmit(event) {

        event.preventDefault();
        const fields = event.detail.fields;
        fields.Permanency_Plan__c = this.permanencyRecId;
        fields.Effort_Date__c = this.effortRecord.Effort_Date__c;
        this.template
            .querySelector('[data-name="effortForm"]').submit(fields);

    }

    handleEffortSuccess(event) {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record created Successfully';
        this.fireToastMsg();
        this.showModal = false;
        this.effortRecord = {};
        refreshApex(this.refreshdata);

    }

    handleRowAction(event) {

        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'edit':
                this.efforRecId = row.Id;
                this.effortRecord.Effort_Date__c = row.Effort_Date__c;
                this.showModal = true;
                break;

            case 'delete':
                this.handleDeleteRec(row);
                break;
        }
    }

    handleDeleteRec(row) {

        deleteRecord(row.Id)
            .then(() => {
                this.type = 'success';
                this.title = 'Success!';
                this.message = 'Record Deleted Successfully!';
                this.fireToastMsg();
                refreshApex(this.refreshdata);

            })
            .catch(error => {

                let errorMsg;
                this.loading = false;
                this.title = "Error!";
                this.type = "error";
                if (error) {
                    let errors = this.reduceErrors(error);
                    errorMsg = errors.join('; ');
                } else {
                    errorMsg = 'Unknown Error';
                }
                this.message = errorMsg;
                this.fireToastMsg();
            })

    }

    handleChange(event) {

        this.effortRecord[event.target.name] = event.target.value;
    }

}