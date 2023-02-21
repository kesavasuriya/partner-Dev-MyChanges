import { LightningElement, track, api, wire } from 'lwc';
import getSubmitForApproval from '@salesforce/apex/PermanacyPlanAdoptionController.subsidySubmitForApproval';
import getRecord from '@salesforce/apex/RelatedListController.getRecords';
import { refreshApex } from '@salesforce/apex';

import { deleteRecord } from 'lightning/uiRecordApi';


import UtilityBaseElement from 'c/utilityBaseLwc';

const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }

];
const fields = ['Id', 'Transaction_Date__c', 'Rate_Approval_Status__c', 'Permanency_Plan__r.Adoptive_Parent_1__c', 'Permanency_Plan__r.Adoptive_Parent_2__c', 'Rate_Begin_Date__c', 'Rate_End_Date__c', 'Monthly_Payment_Amount__c', 'SSA_Approval_Date__c'];
const queryDetail = {
    fieldValue: fields,
    filterValue: 'Permanency_Plan__c =',
    objectApiName: 'Subsidy_Rate__c'

}
const columns = [
    { label: 'Transaction Date', fieldName: 'Transaction_Date__c', type: 'date', typeAttributes: { month: "numeric", day: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Provider Id', fieldName: 'providerId', type: 'string' },
    { label: 'Rate Begin Date', fieldName: 'Rate_Begin_Date__c', type: 'date', typeAttributes: { month: "numeric", day: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Rate End Date', fieldName: 'Rate_End_Date__c', type: 'date', typeAttributes: { month: "numeric", day: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Monthly Payment Amount', fieldName: 'Monthly_Payment_Amount__c', type: 'string' },
    { label: 'Approval Date', fieldName: 'SSA_Approval_Date__c', type: 'date', typeAttributes: { month: "numeric", day: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Status', fieldName: 'Rate_Approval_Status__c', type: 'string' },
    { type: 'action', typeAttributes: { rowActions: actions } }

];


export default class PermanencyPlanSubsidyRates extends UtilityBaseElement {

    @track showRateModal = false;
    @track readOnly = false;
    @api permanencyRecId;
    rateRecord = {};
    subsidyRecord = {};
    @track rateRecordList = [];
    primaryBasisPickValue;
    @track loading = false;
    @track showAddButton = true;
    @track showSubmitforApprovalModal = false;
    @track selectedUserId;
    @track adoptiveParent1;
    @track adoptiveParent2;
    @track agreementStartDate;
    @track providerId;
    @track enableSubmit = true;
    @track enableSendforApproval = false;
    columns = columns;
    fields = fields;
    rateId = '';
    refreshData;
    subsidyRecord = {};

    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    queryDetail = JSON.stringify(queryDetail);

    @wire(getRecord, { recordId: '$permanencyRecId', queryDetails: '$queryDetail' })
    relateRecords(response) {
        this.refreshData = response;
        if (response.data) {
            this.rateRecordList = response.data;
            if (response.data[0].Permanency_Plan__r.Adoptive_Parent_1__c != null) {
                this.adoptiveParent1 = response.data[0].Permanency_Plan__r.Adoptive_Parent_1__c;
            }
            if (response.data[0].Permanency_Plan__r.Adoptive_Parent_2__c != null) {
                this.adoptiveParent2 = response.data[0].Permanency_Plan__r.Adoptive_Parent_2__c;
            }
        } else if (response.error) {
            this.title = "Error!";
            this.type = "error";
            this.message = response.error;
            this.fireToastMsg();
        }
    }

    handleRateModal() {

        this.showRateModal = true;
        this.rateRecord = {};
    }

    closeRateModal() {

        this.showRateModal = false;
    }


    handleSubmitForApproval(event) {

        if ((this.rateRecord.Rate_Approval_Status__c != 'Submitted') && (this.rateRecord.Rate_Approval_Status__c != 'Approved')) {

            this.showSubmitforApprovalModal = true;
            this.showRateModal = false;
        } else if ((this.rateRecord.Rate_Approval_Status__c == 'Submitted') || (this.rateRecord.Rate_Approval_Status__c == 'Approved')) {

            this.showSubmitforApprovalModal = false;
            this.ttitle = 'Error!';
            this.type = "error";
            this.message = "Subsidy Agreement Record Already Submitted "
            this.fireToastMsg();
        }
    }

    closeSubmiteModal(event) {

        this.showSubmitforApprovalModal = false;
    }

    handleSelectRec(event) {

        this.selectedUserId = event.detail.recordId;
        this.enableSubmit = this.selectedUserId ? false : true;
    }

    submitApproval(event) {

        getSubmitForApproval({ subsidyRateRecId: this.rateRecord.Id, selectedSupervisorUserId: this.selectedUserId })
            .then(result => {

                this.showSubmitforApprovalModal = false;
                this.title = "Success!";
                this.type = "success";
                this.message = "Subsidy Agreement Record Submitted for Approval Successfully";
                this.fireToastMsg();
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
                this.loading = false;
                this.message = errorMsg;
                this.fireToastMsg();
            })
    }

    handleRowAction(event) {

        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'edit':
                this.rateId = row.Id;
                this.handleEdit(row);
                break;
            case 'delete':
                this.handleDeleteRec(row);
                break;
        }
    }
    handleEdit(row) {
        this.showRateModal = true;
        this.rateRecord = row;

    }

    handleSuccess(event) {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record Action Successfully';
        this.fireToastMsg();
        this.showRateModal = false;
        this.rateId = '';
        this.rateRecord = {};
        refreshApex(this.refreshData)


    }

    handleError(event) {

        this.title = "Error!";
        this.type = "error";
        this.message = event.detail.detail;
        this.fireToastMsg();
    }

    handleSubmit(event) {

        event.preventDefault();
        const fields = event.detail.fields;
        fields.Permanency_Plan__c = this.permanencyRecId;
        fields.Transaction_Date__c = this.subsidyRecord.Transaction_Date__c;
        fields.Rate_Begin_Date__c = this.subsidyRecord.Rate_Begin_Date__c;
        fields.Rate_End_Date__c = this.subsidyRecord.Rate_End_Date__c;
        fields.SSA_Approval_Date__c = this.subsidyRecord.SSA_Approval_Date__c;
        this.template
            .querySelector('lightning-record-edit-form').submit(fields);
    }

    handleDeleteRec(row) {

        deleteRecord(row.Id)
            .then(() => {
                this.type = 'success';
                this.title = 'Success!';
                this.message = 'Record Deleted Successfully!';
                this.fireToastMsg();
                refreshApex(this.refreshData)

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

        let fieldName = event.target.name;
        this.subsidyRecord[fieldName] = event.target.value;

    }

}