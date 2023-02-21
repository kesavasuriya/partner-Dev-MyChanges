import { LightningElement, track, api, wire } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import actionsInit from '@salesforce/apex/ServicePlanController.getActionsInitialInfo';
import getRecord from '@salesforce/apex/RelatedListController.getRecords';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';

const fields = ['Name', 'Person_Benefitizing__c', 'Person_Responsible__c', 'Start_Date__c', 'End_Date__c', 'Status__c', 'Comments__c'];


const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }

];

const queryDetail = {
    fieldValue: fields,
    objectApiName: 'Goal_Action__c',
    filterValue: 'Goal_Objective__c ='
};

const columns = [
    { label: 'Action Name', fieldName: 'Name', type: 'text', wrapText: 'true' },
    { label: 'Person Benefiting', fieldName: 'Person_Benefitizing__c', type: 'text', wrapText: 'true' },
    { label: 'Person  Responsible', fieldName: 'Person_Responsible__c', type: 'text', wrapText: 'true' },
    { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date', typeAttributes: { month: "numeric", year: "numeric", day: "numeric", timeZone: "UTC" } },
    { label: 'End Date', fieldName: 'End_Date__c', type: 'date', typeAttributes: { month: "numeric", year: "numeric", day: "numeric", timeZone: "UTC" } },
    { label: 'Action Status', fieldName: 'Status__c', type: 'text', wrapText: 'true' },
    { label: 'Comments', fieldName: 'Comments__c', type: 'text', wrapText: 'true' },
    { type: 'action', typeAttributes: { rowActions: actions } }

];

export default class GoalActionLWC extends UtilityBaseElement {

    @api recordId;
    @track actionList = [];
    columns = columns;
    @track actionRec = {};
    @track updateActionRec = {};
    @track statusPicklistValue = [];
    @track personBenefitingPicklistValue = [];
    @track personResponsiblePicklistValue = [];
    showAddRecord = false;
    loading = false;
    @track selected = [];
    @track getSelected = [];
    response = [];
    goalActionId = '';
    @track queryDetails = JSON.stringify(queryDetail);

    @wire(getRecord, { recordId: '$recordId', queryDetails: '$queryDetails' })
    relateRecords(response) {
        this.response = response;
        if (response.data) {
            this.actionList = response.data;

        } else if (response.error) {
            this.loading = false;
            this.title = "Error!";
            this.type = "error";
            this.message = response.error;
            this.fireToastMsg();
        }
    }


    connectedCallback() {

        this.doInit();
    }

    doInit() {

        this.loading = true;
        actionsInit({ recordId: this.recordId })
            .then(result => {

                let res = JSON.parse(result);
                this.personBenefitingPicklistValue = res.personBenefitingPicklist;
                this.personResponsiblePicklistValue = res.personResponsiblePicklist;
                this.loading = false;

            }).catch(error => {

                this.loading = false;
                let errorMsg;
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

        var targetname = event.target.name;
        var Value = event.target.value;
        if (event.target.name == 'Person_Benefitizing__c') {
            this.updateActionRec.Person_Benefitizing__c = Value.join(';');
        } else {
            this.updateActionRec[targetname] = event.target.value;
        }

    }

    handleCancel() {

        this.showAddRecord = false;
        this.actionRec = {};
        this.goalActionId = '';
    }

    handleAdd() {

        this.actionRec = {};
        this.getSelected = [];
        this.showAddRecord = true;
    }

    handleRowAction(event) {

        var action = event.detail.action;
        var selectedrow = event.detail.row;
        switch (action.name) {
            case 'edit':
                this.getSelected = selectedrow.Person_Benefitizing__c.split(';');
                this.actionRec = selectedrow;
                this.goalActionId = selectedrow.Id;
                this.showAddRecord = true;
                break;

            case 'delete':
                this.handleDeleteRec(selectedrow);
                break;
        }
    }

    handleSubmit(event) {

        event.preventDefault();
        if (!this.onValidate()) {
            const fields = event.detail.fields;
            fields.Goal_Objective__c = this.recordId;
            fields.Person_Benefitizing__c = this.updateActionRec.Person_Benefitizing__c;
            fields.Person_Responsible__c = this.updateActionRec.Person_Responsible__c;
            fields.Start_Date__c = this.updateActionRec.Start_Date__c;
            fields.End_Date__c = this.updateActionRec.End_Date__c;
            this.template
                .querySelector('lightning-record-edit-form').submit(fields);
        } else {
            this.title = "Error!";
            this.message = "Required fields are missing";
            this.type = "error";
            this.fireToastMsg();
        }

    }

    handleSuccess(event) {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record Action Successfully';
        this.fireToastMsg();
        this.showAddRecord = false;
        this.goalActionId = '';
        this.actionRec = {};
        this.updateActionRec = {};
        refreshApex(this.response);

    }

    handleError(event) {

        this.title = "Error!";
        this.type = "error";
        this.message = event.detail.detail;
        this.fireToastMsg();
    }

    handleDeleteRec(row) {


        deleteRecord(row.Id)
            .then(() => {
                this.type = 'success';
                this.title = 'Success!';
                this.message = 'Record Deleted Successfully!';
                this.fireToastMsg();
                refreshApex(this.response);
            })
            .catch(error => {

                let errorMsg;
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

}