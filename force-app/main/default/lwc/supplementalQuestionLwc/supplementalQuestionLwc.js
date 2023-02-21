import { LightningElement, api, track } from 'lwc';
import getPicklist from '@salesforce/apex/AssessmentController.getSupplementalQuestionPicklist';
import getInit from '@salesforce/apex/AssessmentController.getSupplementalQuestionInfo';
import saveNeglectAbuse from '@salesforce/apex/AssessmentController.upsertfamilyRiskReassessment';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class SupplementalQuestionLwc extends UtilityBaseElement {

    @api serviceCaseId;
    @api assessmentId;
    @api tableAction;
    @track optionS1 = [];
    @track primaryOptions = [];
    @track secondaryOptions = [];
    @track supplementalQuestionRec = {};
    @track selectedprimaryOptions = [];
    @track selectedValueprimaryOptions = [];
    @track selectedsecondaryOptions = [];
    @track selectedValuesecondaryOptions = [];
    showprimarySecondary = false;
    loading = false;
    changedPrimary = false;
    changedSecondary = false;
    readOnly = false;

    connectedCallback() {

        this.loading = true;
        getPicklist()
        .then(result => {

            let res = JSON.parse(result);
            this.optionS1 = res.optionS1.splice(1);
            this.primaryOptions = res.primaryOptions;
            this.secondaryOptions = res.secondaryOptions;
            this.loading = false;
            this.doInit();

        }).catch(error => {

            this.errorMessage(error);
        });
    }

    doInit() {

        this.loading = true;
        getInit({recordId:this.assessmentId})
        .then(result => {
            let res = JSON.parse(result);
            if(res.assessmentRec != null) {
                this.supplementalQuestionRec = this.checkNamespaceApplicable(res.assessmentRec,false);
            }
            if(this.supplementalQuestionRec.FIRA_Primary__c != null){
                this.selectedValueprimaryOptions = this.supplementalQuestionRec.FIRA_Primary__c.split(';');
            }
            if(this.supplementalQuestionRec.FIRA_Secondary__c != null){
                this.selectedValuesecondaryOptions = this.supplementalQuestionRec.FIRA_Secondary__c.split(';');
            }
            if(this.supplementalQuestionRec.FIRA_Does_either_caregiver_have_history__c == 'Yes') {
                this.showprimarySecondary = true;
            }
            if(this.supplementalQuestionRec.Approval_Status__c == 'Approved') {
                this.readOnly = true;
            } else if(this.tableAction == 'view') {
                this.readOnly = true;
            } else if(this.tableAction == 'edit') {
                this.readOnly = false;
            }
            this.loading = false;
        }).catch(error => {

            this.errorMessage(error);
        });
    }
    handleSave() {

        this.supplementalQuestionRec.Department_is_unable_to_locate_child__c = false;
        this.supplementalQuestionRec.FIRA_Primary__c = this.changedPrimary == true ? this.selectedprimaryOptions.join(';') : this.selectedValueprimaryOptions.join(';');
        this.supplementalQuestionRec.FIRA_Secondary__c = this.changedSecondary == true ? this.selectedsecondaryOptions.join(';') : this.selectedValuesecondaryOptions.join(';');
        this.supplementalQuestionRec.FamilyInitialRiskAssessmentStage__c = '5';
        if(!this.onValidate()) {
            this.loading = true;
            saveNeglectAbuse({ familyRiskReassessmentJSON : JSON.stringify(this.checkNamespaceApplicable(this.supplementalQuestionRec,true))})
            .then( result => {

                this.loading = false;
                this.title = 'Success!';
                this.type = 'success';
                this.message = 'Record saved successfully';
                this.fireToastMsg();
                const stageEvent = new CustomEvent('stage',{detail : { stage : '5',assRecId : result}});
                this.dispatchEvent(stageEvent);
                this.doInit();
                
                
            }) .catch(error => {

                this.errorMessage(error);
            })
        } else {

            this.title = "Error!";
            this.message = "Required fields are missing";
            this.type = "error";
            this.fireToastMsg();
        
        }

    }

    handleChange(event) {

        if(event.target.name == 'FIRA_Does_either_caregiver_have_history__c') {
            this.supplementalQuestionRec[event.target.name] = event.target.value;
            if(event.target.value == 'Yes') {
                this.showprimarySecondary = true;
            } else {
                this.showprimarySecondary = false;
                this.selectedprimaryOptions = [];
                this.selectedsecondaryOptions = [];
            }
        }

        if(event.target.name == 'FIRA_Primary__c') {
            this.selectedprimaryOptions = event.target.value;
            this.changedPrimary = true;
        }
        if(event.target.name == 'FIRA_Secondary__c') {
            this.selectedsecondaryOptions = event.target.value;
            this.changedSecondary = true;
        }
    }

    errorMessage(error) {

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
    }
}