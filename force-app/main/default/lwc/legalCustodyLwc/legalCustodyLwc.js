import { LightningElement,track,api } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getInitialInfos from '@salesforce/apex/LegalCustodyController.getInitialInfos';

const column = [{ label: 'Legal Custody Name', fieldName: 'Name', type: 'string' },
    { label: 'Begin Date', fieldName: 'Begin_Date__c', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'End Date', fieldName: 'End_Date__c', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
  
];
export default class LegalCustodyLwc extends UtilityBaseElement {

    column = column;
    @api recordId;
    @track legalCustodyList = [];
    showModal = false;
    @track legalCustodyId;
    childPickList = [];
    @track legalCustodyRec={};
    
    get showCustodianRequired() {
        if(this.legalCustodyRec.Legal_Custody__c != null && (this.legalCustodyRec.Legal_Custody__c == 'Custody to Father' || this.legalCustodyRec.Legal_Custody__c == 'Custody to Mother')) {
            return true;
        } else {
            return false;
        }
    }
    connectedCallback() {
        this.doInit();
    }

    doInit() {
        getInitialInfos({recordId : this.recordId})
        .then(res=>{
            this.legalCustodyList = JSON.parse(res).legalCustodyList;
            this.childPickList = JSON.parse(res).childPickList;

        })
    }

    handleSubmit(event) {

        let fields = event.detail.fields;
        event.preventDefault();
        fields.Service_Case__c = this.recordId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);

    }

    handleSuccess() {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record action Successfully';
        this.fireToastMsg();
        this.showModal = false;
        this.doInit();
    }

    handleNew() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    handleChildChange() {

    }

    handleChange(event) {
        console.log(event.currentTarget.dataset.field);
        this.legalCustodyRec[event.currentTarget.dataset.field] = event.target.value;
    }


}