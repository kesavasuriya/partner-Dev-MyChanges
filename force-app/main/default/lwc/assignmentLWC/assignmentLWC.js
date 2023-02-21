import { LightningElement, api } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getUserAccessInfo from '@salesforce/apex/ServiceCaseController.checkUserHasAccess';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { NavigationMixin } from 'lightning/navigation';

export default class AssignmentLWC extends NavigationMixin(UtilityBaseElement) {


    @api recordId;
    @api objectApiName;
    showValidateModal = false;

    handleAssignModal() {
    
        getUserAccessInfo({ recordId: this.recordId}).then(result => {

            if(result) {
                this.showValidateModal = false;
                if(this.objectApiName == 'Service_Case__c') {
                    this.defaultValues = encodeDefaultFieldValues({
                        Service_Case__c: this.recordId
                    });
                } else if(this.objectApiName == 'Investigation__c') {
                    this.defaultValues = encodeDefaultFieldValues({
                        Investigation__c: this.recordId
                    });
                } 
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Assignment__c',
                        actionName: 'new',
                    },
                    state: {
                        defaultFieldValues: this.defaultValues
                    }
                });
            } else {
                this.showValidateModal = true;
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
        })
    
    }

    closeValidateModal() {
        
        this.showValidateModal = false;
    }
}