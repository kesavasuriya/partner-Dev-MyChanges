import { LightningElement, api, track } from 'lwc';
import getServicePlanRec from '@salesforce/apex/CasePlanController.getServicePlanRecord';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    { label: 'Service Plan', fieldName: 'recurl', type: 'url', target: '_self', wrapText: true, typeAttributes: { label: { fieldName: 'Name' } } },
    { label: 'Effective Date', fieldName: 'Start_Date__c', type: 'date', wrapText: true,type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Target End Date', fieldName: 'Target_End_Date__c',  wrapText: true, type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Completion Date', fieldName: '',  wrapText: true, type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },

];

export default class CasePlanServicePlan extends NavigationMixin(UtilityBaseElement) {

    @api recordId;
    @track servicePlanRecordList =[];
    @track showServicePlan = true; 
    columns = columns;

    connectedCallback() {

        getServicePlanRec({casePlanId : this.recordId})
        .then(result =>{

            let res = JSON.parse(result);
            this.servicePlanRecordList =  this.checkNamespaceApplicable(res.servicePlanRecord, false);
                         
            if(this.servicePlanRecordList.length) {

                for(let i=0; i<this.servicePlanRecordList.length; i++) {

                    this.servicePlanRecordList[i].Name = this.servicePlanRecordList[i].Service_Plan__r.Name;
                    this.servicePlanRecordList[i].Start_Date__c = this.servicePlanRecordList[i].Service_Plan__r.Start_Date__c;
                    this.servicePlanRecordList[i].Target_End_Date__c = this.servicePlanRecordList[i].Service_Plan__r.Target_End_Date__c;
                    this.servicePlanRecordList[i].recurl = '/lightning/r/' + this.servicePlanRecordList[i].Service_Plan__c + '/view';;
                }

            } else {

                this.showServicePlan = false;
            }

        }).catch(error => {
    
            this.loading = false;
            let errorMsg;
            this.title ="Error!";
            this.type ="error";
            if(error) {
                let errors = this.reduceErrors(error);
                errorMsg = errors.join('; ');
            } else {
            errorMsg = 'Unknown Error';
            }
            this.message = errorMsg;
            this.fireToastMsg();
        });
    }
   
}