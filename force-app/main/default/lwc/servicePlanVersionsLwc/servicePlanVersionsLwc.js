import { LightningElement, track, api, wire } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import versionsInit from '@salesforce/apex/ServicePlanController.getServicePlanVersionsInitInfo';
import { deleteRecord } from 'lightning/uiRecordApi';
import getRecord from '@salesforce/apex/RelatedListController.getRecords';
import { refreshApex } from '@salesforce/apex';

const fields = ['Id', 'Name', 'Persons_Benefitizing__c', 'Start_Date__c', 'End_Date__c'];
const queryDetail = {
    fieldValue: fields,
    objectApiName: 'Service_Plan_Version__c',
    filterValue: 'Service_Plan__c ='
};


const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },

];

const columns = [{ label: 'Version Name', fieldName: 'Name' },
    { label: 'Persons Benefiting', fieldName: 'Persons_Benefitizing__c' },
    { label: 'Start Date', fieldName: 'Start_Date__c', type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'End Date', fieldName: 'End_Date__c', type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { type: 'action', typeAttributes: { rowActions: actions } }
];
export default class ServicePlanVersionsLwc extends UtilityBaseElement {

    @api recordId;
    @track showServicePlanVersionModal = false;
    columns = columns;
    @track serviceplanversionlist = [];
    @track serviceplanversionRec = {};
    @track updateServiceplanVersionRec = {};
    @track personBenefitingPicklistValue = [];
    @track getSelected = [];
    loading = false;
    serivePlanId = '';


    @track queryDetails = JSON.stringify(queryDetail);
    @wire(getRecord, { recordId: '$recordId', queryDetails: '$queryDetails' })
    relateRecords(response) {
        this.response = response;
        if (response.data) {
            this.serviceplanversionlist = response.data;

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
        versionsInit({ recordId: this.recordId })
            .then(result => {

                let res = JSON.parse(result);
                this.personBenefitingPicklistValue = res.personBenefitingPicklist;
                this.showServicePlanVersionModal = false;
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


    openServicePlanVersionsModal() {

        this.serviceplanversionRec = {};
        this.updateServiceplanVersionRec = {};
        this.getSelected = [];
        this.showServicePlanVersionModal = true;
    }

    handleCancel() {
        this.showServicePlanVersionModal = false;
        this.serivePlanId = '';

    }

    handleChange(event) {

        let targetValue = event.target.value;
        if (event.target.name == 'Persons_Benefitizing__c') {
            this.updateServiceplanVersionRec.Persons_Benefitizing__c = targetValue.join(';');
        } else {
            this.updateServiceplanVersionRec[event.target.name] = targetValue;
        }

    }

    handleRowAction(event) {

        var action = event.detail.action;
        var row = event.detail.row;
        switch (action.name) {

            case 'edit':
                this.getSelected = row.Persons_Benefitizing__c.split(';');
                this.serivePlanId = row.Id;
                this.serviceplanversionRec = row;
                this.updateServiceplanVersionRec = {};
                this.showServicePlanVersionModal = true;
                break;

            case 'delete':

                this.handleDeleteRec(row);
                break;
        }

    }

    handleSubmit(event) {

        event.preventDefault();
        if (!this.onValidate()) {
            const fields = event.detail.fields;
            fields.Service_Plan__c = this.recordId;
            fields.Persons_Benefitizing__c = this.updateServiceplanVersionRec.Persons_Benefitizing__c;
            fields.Start_Date__c = this.updateServiceplanVersionRec.Start_Date__c;
            fields.End_Date__c = this.updateServiceplanVersionRec.End_Date__c;
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
        this.showServicePlanVersionModal = false;
        this.serivePlanId = '';
        this.serviceplanversionRec = {};
        this.updateServiceplanVersionRec = {};
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