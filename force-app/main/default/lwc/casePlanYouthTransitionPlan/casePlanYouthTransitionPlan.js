import { LightningElement, api, track } from 'lwc';
import getYouthTransitionPlanRec from '@salesforce/apex/CasePlanController.getYouthTransitionPlanRecords';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    { label: 'Select Plan', fieldName: 'recurl', type: 'url', target: '_self', wrapText: true, typeAttributes: { label: { fieldName: 'Name' } } },
    { label: 'Child Name', fieldName: 'childName', type: 'text', wrapText: true },
    { label: 'Created Date', fieldName: 'CreatedDate',  wrapText: true ,type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Completed Date', fieldName: 'Transition_Plan_Completed_Date__c',  wrapText: true,type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Status', fieldName: 'Status__c', type: 'text', wrapText: true },
   

];

export default class CasePlanYouthTransitionPlan extends NavigationMixin(UtilityBaseElement) {

    @api recordId;
    @track youthTransitionPlanList = [];
    @track loading = false;
    @track showTable = true;
    columns = columns;

    connectedCallback() {
    
        this.loading = true;
        getYouthTransitionPlanRec({casePlanId : this.recordId})
        .then(result =>{

            let res = JSON.parse(result);
            this.youthTransitionPlanList = this.checkNamespaceApplicable(res.youthTransitionPlanList, false);

            if(this.youthTransitionPlanList.length) {

                for(let i = 0; i<this.youthTransitionPlanList.length; i++) {
                    this.youthTransitionPlanList[i].recurl = '/lightning/r/' + this.youthTransitionPlanList[i].Id + '/view';
                    this.youthTransitionPlanList[i].childName = this.youthTransitionPlanList[i].Contact__r.Name;
                }

            } else {
                
                this.showTable = false;
            }

            this.loading = false;
        })
        .catch(error => {
    
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