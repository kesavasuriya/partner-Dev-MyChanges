import { LightningElement, track, api, wire } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getRecords from '@salesforce/apex/RelatedListController.getRecords';
import getPerson from '@salesforce/apex/PermanacyPlanAdoptionController.getPersons';
import { getRecord } from 'lightning/uiRecordApi';

import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';

const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];

const FIELDS = ['Permanency_Plan__c.Adoption_Planning__c'];

const fields = ['Id', 'ParentName__r.Name', 'ParentName__r.Intake_Person_Role__c', 'ParentName__c', 'TPR_Decision_Date__c', 'Date_Parent_Served__c'];

const columns = [
    { label: 'Parent Name', fieldName: 'parentName', type: 'text', wrapText: true },
    { label: 'Role', fieldName: 'role', type: 'text', wrapText: true },
    { type: 'action', typeAttributes: { rowActions: actions } }

];
const queryDetail = {
    fieldValue: fields,
    filterValue: 'Permanency_Plan__c =',
    objectApiName: 'TPR__c'

}

export default class PermanencyPlanTPR extends NavigationMixin(UtilityBaseElement) {

    @api permanencyRecId;
    @api servicecaseId;
    @track tprList = [];
    @track tprId = '';
    columns = columns;
    queryDetail = queryDetail;
    @track response = [];
    @track showAddTPRModal = false;
    personPicklist = [];
    @track tprRec = {};
    isValid;
    disabledButton = false;
    queryDetail = JSON.stringify(queryDetail);

    @wire(getRecords, { recordId: '$permanencyRecId', queryDetails: '$queryDetail' })
    relateRecords(response) {
        this.response = response;
        if (response.data) {
            let records = [];
            for (let i = 0; i < response.data.length; i++) {
                let record = {};
                record.Id = response.data[i].Id;
                record.parentName = response.data[i].ParentName__r.Name;
                record.role = response.data[i].ParentName__r.Intake_Person_Role__c;
                record.ParentName__c = response.data[i].ParentName__c;
                record.TPR_Decision_Date__c = response.data[i].TPR_Decision_Date__c;
                record.Date_Parent_Served__c = response.data[i].Date_Parent_Served__c;
                records.push(record);
            }
            this.tprList = records;

        } else if (response.error) {
            this.title = "Error!";
            this.type = "error";
            this.message = response.error;
            this.fireToastMsg();
        }
    }

    @wire(getRecord, { recordId: '$permanencyRecId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {

            if (data.fields.Adoption_Planning__c.value > 3) {

                this.disabledButton = true;
            } else {

                this.disabledButton = false;
            }
        }
    }

    connectedCallback() {

        getPerson({ recordId: this.servicecaseId })
            .then(res => {
                this.personPicklist = JSON.parse(res);
            })
    }

    handleRowAction(event) {

        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {

            case 'edit':
                this.tprRec = {};
                this.tprId = row.Id;
                this.tprRec.ParentName__c = row.ParentName__c;
                this.tprRec.TPR_Decision_Date__c = row.TPR_Decision_Date__c;
                this.tprRec.Date_Parent_Served__c = row.Date_Parent_Served__c;
                this.showAddTPRModal = true;
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
                refreshApex(this.response);
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

    handleNew() {

        this.showAddTPRModal = true;
        this.tprRec = {};
        this.tprId = '';

    }

    closeAddTPRModal() {

        this.showAddTPRModal = false;
        this.tprRec = {};

    }

    onFormValidate() {

        this.isValid = this.onRequiredValidate();
    }

    handleSubmit(event) {

        event.preventDefault();
        if (this.isValid) {

            const fields = event.detail.fields;
            fields.Permanency_Plan__c = this.permanencyRecId;
            fields.ParentName__c = this.tprRec.ParentName__c;
            fields.TPR_Decision_Date__c = this.tprRec.TPR_Decision_Date__c;
            fields.Date_Parent_Served__c = this.tprRec.Date_Parent_Served__c;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }

    }

    handleSuccess(event) {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record Action Successfully!';
        this.fireToastMsg();
        this.showAddTPRModal = false;
        this.tprRec = {};
        refreshApex(this.response);

    }

    handleError(event) {

        this.title = "Error!";
        this.type = "error";
        this.message = event.detail.detail;
        this.fireToastMsg();
    }

    handleNext() {

        if (this.tprList.length > 0) {

            const fields = {};
            fields.Id = this.permanencyRecId;
            fields.Adoption_Planning__c = '4';
            updateRecord({ fields })
                .then(() => {
                    const stageEvent = new CustomEvent('stage');
                    this.dispatchEvent(stageEvent);
                })

        } else {

            this.title = "Error!";
            this.type = "error";
            this.message = 'Add TPR Record!';
            this.fireToastMsg();
        }
    }

    handleChange(event) {

        this.tprRec[event.target.name] = event.target.value;
    }
}