import { LightningElement, api, track } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getCaseDetails from '@salesforce/apex/AdoptionCaseController.getCurrentAdoptionCaseDetails'

export default class AdoptionCaseHeaderLWC extends UtilityBaseElement {
    @api recordId;
    @track caseInfos = {};
    @track contactInfos = '';
    @track clientId = '';
    developerName;
    
    connectedCallback() {
        
        
        getCaseDetails({adoptionCaseId : this.recordId})
        .then(result =>{
    
            let res = JSON.parse(result);
            this.caseInfos = this.checkNamespaceApplicable(res.caseRec, false);
            this.developerName = this.caseInfos.RecordType.Name;
            this.clientId = this.checkNamespaceApplicable(res.contactRec, false).Casevault_PID__c;
            let contactRec = this.checkNamespaceApplicable(res.conList, false);
            if(contactRec.length ){
                if(contactRec[0].HEAD_OF_HOUSEHOLD__c ==true) {
                    this.contactInfos = contactRec[0].Name;
                }
            }
        }).catch(error => {
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