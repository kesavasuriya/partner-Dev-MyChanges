import { LightningElement, track, api } from 'lwc';
import getPersonIncome from '@salesforce/apex/TitleIvEController.getPersonIncomes';
import UtilityBaseElement from 'c/utilityBaseLwc';

const columns = [
    { label: 'Entry Date', fieldName: 'Entry_Date__c', type: 'date',typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric"
    } },
    { label: 'Entered By', fieldName: 'enteredBy', type: 'text' },
    { label: 'Data Source', fieldName: 'Data_Source__c', type: 'text' },
    { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date',typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric"
    } },
    { label: 'End Date', fieldName: 'End_Date__c', type: 'date',typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric"
    } },
    { label: 'Income Source', fieldName: 'Income_Source__c' , type: 'text' },
    { label: 'Frequency', fieldName: 'Frequency__c' , type: 'text' },
    { label: 'Monthly Income', fieldName: 'Monthly_Income__c' , type: 'currency' },
    { label: 'Amount', fieldName: 'Amount__c' , type: 'currency' },
];

export default class TitlePersonIncome extends UtilityBaseElement
{
    columns = [];
    showModal = false;
    data;
    showPersonIncomeTable = false;
    @api childId;
    @track isSpinner = false;

    connectedCallback() {
        this.isSpinner = true;
        this.showModal = true;
        getPersonIncome({childId :this.childId}).then(result => {
            this.data = this.checkNamespaceApplicable(JSON.parse(result).personIncomeList, false);
            if(this.data.length){
                this.showPersonIncomeTable = true;
                this.columns = columns;
            } else {
                this.showPersonIncomeTable = false;
                this.columns=[];
            }
            this.isSpinner = false;
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
            this.loading = false;
            this.message = errorMsg;
            this.fireToastMsg();
        })
    }

    closeModal(event) {
        
        const childdetail = new CustomEvent('handlechild', {detail : false});
        this.dispatchEvent(childdetail);
    }
}