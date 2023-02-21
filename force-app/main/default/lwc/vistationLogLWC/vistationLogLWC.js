import { LightningElement, track, api } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getInitiInfo from '@salesforce/apex/VisitationLogController.getInitialInformation';
import { deleteRecord } from 'lightning/uiRecordApi';

const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
]
const columns = [
    { label: 'Client Name', fieldName: 'client', type: 'String', wrapText: true },
    { label: 'Date of Visit', fieldName: 'Visit_Date__c', type: 'date', typeAttributes: { day: 'numeric', month: 'numeric', year: 'numeric', timeZone: 'UTC' } },
    { label: 'Court Ordered', fieldName: 'Court_Ordered__c', type: 'String', wrapText: true },
    { label: 'Status', fieldName: 'Status__c', type: 'String', wrapText: true },
    { label: 'Comments', fieldName: 'Comments__c', type: 'String', wrapText: true },
    { label: 'Location', fieldName: 'Location__c', type: 'String', wrapText: true },
    { label: 'Conditions', fieldName: 'Conditions__c', type: 'String', wrapText: true },
    { type: 'action', typeAttributes: { rowActions: actions } }
];
export default class VistationLogLWC extends UtilityBaseElement {
    @track showAddnew = false;
    @track columns = columns;
    @track VistationLog = {};
    @api recordId;
    @api objectApiName;
    @track clientPickOptions = [];
    @track personPickOptions = [];
    @track statusPickOptions = [];
    @track collateralVisitParticipantsOption = [];
    @track visitionLogList = [];
    @track personInvolvedValues = [];
    @track collateralValues = [];
    @track clientName = '';
    @track conditionPicklist = [];
    visitationLogRecordId = '';
    isValid;
    get visitationLogTitle() {
        if (this.visitionLogList) {
            return 'Visitation Log (' + this.visitionLogList.length + ')';
        } else {
            return 'Visitation Log';
        }
    }
    get showTable() {
        if (this.visitionLogList.length) {
            return true;
        } else {
            return false;
        }
    }

    connectedCallback() {
        this.doInit();
    }

    doInit() {

        getInitiInfo({ servicecaseId: this.recordId })
            .then(result => {
                let res = JSON.parse(result);
                this.personPickOptions = res.personInvolvedPicklist;
                this.conditionPicklist = res.conditionPicklist.slice(1);
                this.collateralVisitParticipantsOptions = res.collateralVisitParticipantsPicklist;
                this.clientPickOptions = res.clientPicklist;
                if (res.visitationLogList) {
                    this.visitionLogList = this.checkNamespaceApplicable(res.visitationLogList, false);
                }

                if (this.visitionLogList.length > 0) {

                    for (let i = 0; i < this.visitionLogList.length; i++) {
                        let row = this.visitionLogList[i];
                        row.client = row.Client__r.Name;

                    }
                }

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

    showNew(event) {

        this.VistationLog = {};
        this.visitationLogRecordId = '';
        if (this.objectApiName == 'Case') {
            this.VistationLog.Intake__c = this.recordId;
        } else {
            this.VistationLog[this.objectApiName] = this.recordId;
        }

        this.personInvolvedValues = [];
        this.collateralValues = [];
        this.showAddnew = true;
    }

    closeModal(event) {

        this.showAddnew = false;

    }

    handleChange(event) {

        let fieldName = event.target.name;
        let value = event.target.value;

        if (fieldName == 'Persons_Involved__c') {
            let personInvoleMuti = value.join(';');
            this.VistationLog[fieldName] = personInvoleMuti;
        } else if (fieldName == 'Collateral_Visit_Participants__c') {
            let collateralMulti = value.join(';');
            this.VistationLog[fieldName] = collateralMulti;
        } else {
            this.VistationLog[fieldName] = event.target.value;
        }

    }

    handleRowAction(event) {

        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'edit':
                this.visitationLogRecordId = row.Id;
                this.handleEdit(row);
                break;
            case 'delete':
                deleteRecord(row.Id)
                    .then(() => {
                        this.type = 'success';
                        this.title = 'Success!';
                        this.message = 'Record Deleted Successfully!';
                        this.fireToastMsg();
                        this.doInit();
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

                break;
        };
    }

    handleEdit(row) {

        this.loading = true;
        let id = row.Id;
        this.VistationLog = row;
        for (let i = 0; i < this.visitionLogList.length; i++) {

            if (this.visitionLogList[i].Id == id) {
                if (this.visitionLogList[i].Persons_Involved__c != null) {
                    this.personInvolvedValues = this.visitionLogList[i].Persons_Involved__c.split(';');

                } else if (this.visitionLogList[i].Persons_Involved__c == null) {
                    this.personInvolvedValues = [];
                }

                if (this.visitionLogList[i].Collateral_Visit_Participants__c != null) {
                    this.collateralValues = this.visitionLogList[i].Collateral_Visit_Participants__c.split(';');
                } else if (this.visitionLogList[i].Collateral_Visit_Participants__c == null) {
                    this.collateralValues = [];
                }
                this.showAddnew = true;
            }
        }
    }


    findRowIndexById(id) {
        let ret = -1;
        this.visitionLogList.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }

    onFormValidate() {

        this.isValid = this.onRequiredValidate();        
    }

    handleSubmit(event) {

        event.preventDefault();
        const fields = event.detail.fields;

        if (this.isValid) {
            
            if (this.objectApiName == 'Case') {
                fields.Intake__c = this.recordId;
            } else {
                fields[this.objectApiName] = this.recordId;
            }
            fields.Persons_Involved__c = this.VistationLog.Persons_Involved__c;
            fields.Client__c = this.VistationLog.Client__c;
            fields.Visit_Date__c = this.VistationLog.Visit_Date__c;
            fields.Collateral_Visit_Participants__c = this.VistationLog.Collateral_Visit_Participants__c;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        } 
    }

    handleSuccess(event) {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record Updated Successfully';
        this.fireToastMsg();
        this.showAddnew = false;
        this.VistationLog = {};
        this.doInit();
    }

    handleError(event) {

        this.title = "Error!";
        this.type = "error";
        this.message = event.detail.detail;
        this.fireToastMsg();
    }

}