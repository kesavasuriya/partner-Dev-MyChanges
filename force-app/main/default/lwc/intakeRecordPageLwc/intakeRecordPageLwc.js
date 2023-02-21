import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import getUserAccessInfo from '@salesforce/apex/ServiceCaseController.checkUserHasAccess';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { refreshApex } from '@salesforce/apex';


const FIELDS = ['Case.Origin', 'Case.In_Home_Services__c', 'Case.Voluntary_Placement__c','Case.Restrict_UnRestrict__c'];
export default class IntakeRecordPageLwc extends UtilityBaseElement {

@api recordId; 
intakeChannel = '/event/Refresh_Intake__e'; 
isLoading = false;
buttonLabel;
//modalMsg;
//showValidateModal = false;
hasAccess = false;
@wire(getRecord, {recordId: '$recordId', fields: FIELDS})
intakeRec

    get isInformation() {
        let intakeRec = this.intakeRec.data;
        if (intakeRec && intakeRec.fields.Origin.value == 'Information and Referral') {
            
            return true;
        }
        this.isLoading = false;
        return false;
    }

    get isHomeService() {
        let intakeRec = this.intakeRec.data;
        if (intakeRec && intakeRec.fields.Origin.value == 'Request for services') {
            return true;
        }
        this.isLoading = false;
        return false;
    }

    get inHomeService() {
        let intakeRec = this.intakeRec.data;
        if (intakeRec && intakeRec.fields.In_Home_Services__c.value && intakeRec.fields.Origin.value == 'Request for services') {
            return true;
        }
        this.isLoading = false;
        return false;    
    }

    get isPlacementType() {
        let intakeRec = this.intakeRec.data;
        if (intakeRec && intakeRec.fields.In_Home_Services__c.value && intakeRec.fields.Voluntary_Placement__c.value && intakeRec.fields.Origin.value == 'Request for services') {
            return true;
        }
        this.isLoading = false;
        return false;    
    }

    /*get buttonLabel() {
        let intakeRec = this.intakeRec.data;
        if (intakeRec && intakeRec.fields.Restrict_UnRestrict__c.value) {
            return intakeRec.fields.Restrict_UnRestrict__c.value;
        }
        this.isLoading = false;
        //return 'Restrict';    
    }*/

    handleChange(event) {

        this.isLoading = true;
        let fieldName = event.currentTarget.dataset.field;
        let Value = event.target.value;
        let fields = {Id : this.recordId};
        fields[fieldName] = Value;
        const updateIntakeRec = {fields};
        updateRecord(updateIntakeRec)
        .then(res => {
            this.isLoading = false;
            if(fieldName == 'Restrict_UnRestrict__c') {
                this.title = "Success!";
                this.type = "success";
                this.message = "Record was " + Value;
                this.fireToastMsg();
            }
        }).catch(error => {
            this.isLoading = false;
             this.handleError(error);
        })
    }

    handleError(error) {

        console.log('error:::',error);
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
    }

    connectedCallback() {

        subscribe(this.intakeChannel, -1, this.refreshList).then(response => {
            this.subscription = response;
        });
        onError(error => {});

        getUserAccessInfo({ recordId: this.recordId}).then(result => {

            this.hasAccess = result;
            
        }).catch(error => {
            this.handleError(error);
        })

    }

    refreshList() {

        refreshApex(this.intakeRec);
    }

    /*handleMouseOver() {

        if(this.buttonLabel == 'Restrict') {
            this.buttonLabel = 'Unrestrict';
        } else if(this.buttonLabel == 'Unrestrict'){
            this.buttonLabel = 'Restrict';
        }
    }

    handleMouseOut() {
        this.buttonLabel = this.intakeRec.data.fields.Restrict_UnRestrict__c.value;
    }

    handleRestrictClick() {

        getUserAccessInfo({ recordId: this.recordId}).then(result => {

            if(result) {
                
                const fields = {};
                fields.Id = this.recordId;
                if(this.intakeRec.data.fields.Restrict_UnRestrict__c.value == 'Restrict') {
                    fields.Restrict_UnRestrict__c = 'Unrestrict';
                } else if(this.intakeRec.data.fields.Restrict_UnRestrict__c.value == 'Unrestrict'){
                    fields.Restrict_UnRestrict__c = 'Restrict';
                }
                const recordInput = { fields };

                updateRecord(recordInput)
                    .then(() => {

                        this.modalMsg = 'Record was ' +  fields.Restrict_UnRestrict__c;
                        this.showValidateModal = true;
                    })
                    .catch(error => {
                        this.handleError(error);
                    });
                
            } else {

                this.modalMsg = 'Only supervisor and admin can restrict/unrestrict records';
                this.showValidateModal = true;
            }
            
        }).catch(error => {
            this.handleError(error);
        })
    }

    closeValidateModal() {
        
        this.showValidateModal = false;
    }

    handleError(error) {

        console.log('error:::',error);
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
    }*/
}