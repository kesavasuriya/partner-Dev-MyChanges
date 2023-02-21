import { LightningElement, track, api } from 'lwc';
import getActiveTabValue from '@salesforce/apex/AdoptionCaseController.getActiveTab';
import UtilityBaseElement from 'c/utilityBaseLwc';


export default class AdoptionAgreementTab extends UtilityBaseElement {

    @api recordId;
    @track activeTab = 'default';
    loading = false;
    @track contactRec = {};

    connectedCallback() {
        
        this.loading = true;
        getActiveTabValue({caseId : this.recordId})
        .then(result =>{
          let res = JSON.parse(result);
          this.contactRec = this.checkNamespaceApplicable(res.contactRec, false);
          if(res.suspensionRecordList.length) {
              this.activeTab = 'Download';
          } else if (res.annualReviewRec.length) {
            this.activeTab = 'Payment';
          } else if(res.subsidyRateRecord.length) {
              this.activeTab = 'Annual';
          } else if(this.checkNamespaceApplicable(res.caseRec, false).Subsidy_Agreement_Approval_Status__c == 'Approved') {
              this.activeTab = 'rate';
          } else {
              this.activeTab = 'default';
          }
          this.loading = false;
    
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

    handleTabClick(event) {

        const tab = event.target;
        this.activeTab = `Tab ${
            event.target.value
        } is now active`;

    }
}