import { LightningElement, track, api, wire } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getInitInfo from '@salesforce/apex/ServicePlanController.getIntiVisitationInfo';
import { deleteRecord } from 'lightning/uiRecordApi';
import getRecord from '@salesforce/apex/RelatedListController.getRecords';
import { refreshApex } from '@salesforce/apex';

const fields = ['Id', 'Client__c', 'Client__r.Name', 'Established_Date__c', 'End_Date__c', 'Person_involved__c'];
const queryDetail = {
    fieldValue: fields,
    objectApiName: 'Visitation_Plan__c',
    filterValue: 'Service_Plan__c ='
};

const actions = [{ label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

const columns = [{ label: 'Client Name', fieldName: 'clientName', type: 'string', wrapText: true },
    {
        label: 'Established Date',
        fieldName: 'Established_Date__c',
        type: 'date',
        wrapText: true,
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric",
            timeZone: "UTC"
        }
    },
    {
        label: 'End Date',
        fieldName: 'End_Date__c',
        type: 'date',
        wrapText: true,
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric",
            timeZone: "UTC"
        }
    },
    { type: 'action', typeAttributes: { rowActions: actions } }
];
export default class VisitationPlansLwc extends UtilityBaseElement {

    @api recordId;
    @track clientPickList = [];
    @track personInvolvedPicklist = [];
    @track openAddVisitationPlan = false;
    @track visitationRecord = {};
    @track visitationRecordList = [];
    columns = columns;
    clientName;
    @track getSelected = [];
    response = [];
    visitationId = '';
    isValid;

    @track queryDetails = JSON.stringify(queryDetail);
    @wire(getRecord, { recordId: '$recordId', queryDetails: '$queryDetails' })
    relateRecords(response) {
        this.response = response;
        if (response.data) {
            this.visitationRecordList = JSON.parse(JSON.stringify(response.data));
            for (let i = 0; i < this.visitationRecordList.length; i++) {
                if (this.visitationRecordList[i].Client__c != null) {
                    this.visitationRecordList[i].clientName = this.visitationRecordList[i].Client__r.Name;
                }
            }

        } else if (response.error) {
            this.loading = false;
            this.title = "Error!";
            this.type = "error";
            this.message = response.error;
            this.fireToastMsg();
        }
    }

    connectedCallback() {

        this.doInitInfo();
    }

    doInitInfo() {

        getInitInfo({ servicePlanId: this.recordId })
            .then(result => {
                let res = JSON.parse(result);
                this.clientPickList = res.clientPicklist;
                this.personInvolvedPicklist = res.personInvolvedPicklist;

            }).catch(error => {

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

    handleAddVisitationPlan() {

        this.visitationRecord = {};
        this.getSelected = [];
        this.clientName = '';
        this.openAddVisitationPlan = true;
    }

    handleChange(event) {

        let name = event.target.name;
        let value = event.target.value;
        if (name == 'Person_involved__c') {
            this.visitationRecord.Person_involved__c = value.join(';');
        } else {
            this.visitationRecord[name] = value;
        }

    }

    handleCancel() {
        this.openAddVisitationPlan = false;
        this.visitationId = '';
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {

            case 'edit':
                this.getSelected = row.Person_involved__c.split(';');
                this.visitationId = row.Id;
                this.clientName = row.Client__c;
                this.visitationRecord = row;
                this.openAddVisitationPlan = true;
                break;

            case 'delete':

                this.handleDeleteRec(row);
                break;
        }
    }

    onFormValidate() {

        this.isValid = this.onRequiredValidate();        
    }

    handleSubmit(event) {

        event.preventDefault();
        if (this.isValid) {
            const fields = event.detail.fields;
            fields.Service_Plan__c = this.recordId;
            fields.Person_involved__c = this.visitationRecord.Person_involved__c;
            fields.Client__c = this.visitationRecord.Client__c;
            fields.Established_Date__c = this.visitationRecord.Established_Date__c;
            fields.End_Date__c = this.visitationRecord.End_Date__c;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }

    }

    handleSuccess(event) {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record Action Successfully';
        this.fireToastMsg();
        this.openAddVisitationPlan = false;
        this.visitationId = '';
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