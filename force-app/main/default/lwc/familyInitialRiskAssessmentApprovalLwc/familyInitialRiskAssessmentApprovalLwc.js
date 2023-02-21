import { LightningElement , api, track} from 'lwc';
import getInit from '@salesforce/apex/AssessmentController.getFIRAApprovalInfo';
import getPicklist from '@salesforce/apex/AssessmentController.getFIRAApprovalPicklist';
import saveApprovalRec from '@salesforce/apex/AssessmentController.upsertfamilyApprovalSign';
import submitSuperApproval from '@salesforce/apex/AssessmentController.onSubmitForApproval';

import UtilityBaseElement from 'c/utilityBaseLwc';

export default class FamilyInitialRiskAssessmentApprovalLwc extends UtilityBaseElement {

    @api serviceCaseId;
    @api assessmentId;
    @api tableAction;
    @track approvalRec = {};
    @track rerouteSupervisorOptions = [];
    loading = false;
    savedRec = false;
    supervisorId = '';
    enableSubmit = true;
    readOnly = false;
    signatureFieldName = '';
    showSignModal = false;
    sourceUrlParent1 = '';
    showParent1 = false;
    sourceUrlParent2 = '';
    showParent2 = false;
    @track signatureObj = {};
    showApprovalScreen = false;

    connectedCallback() {

        this.loading = true;
        getPicklist()
        .then(result => {

            let res = JSON.parse(result);
            this.rerouteSupervisorOptions = res.rerouteSupervisorOptions;
            this.loading = false;
            this.doInit();
        }).catch(error => {

            this.errorMessage(error);
        });
    }

    doInit() {

        this.loading = true;
        getInit({recordId : this.assessmentId})
        .then(result => {
            let res = JSON.parse(result);
            if(res.assessmentRec != null) {
                this.approvalRec = this.checkNamespaceApplicable(res.assessmentRec,false);
            }
            if(this.approvalRec.Approval_Status__c == 'Approved') {
                this.readOnly = true;
            } else if(this.tableAction == 'view') {
                this.readOnly = true;
            } else if(this.tableAction == 'edit') {
                this.readOnly = false;
            }
            if(this.approvalRec.FIRA_Case_worker_Signature__c) {

                let removeImageTag = this.approvalRec.FIRA_Case_worker_Signature__c.replaceAll("&amp;","&");
                this.sourceUrlParent1 = removeImageTag.substring(10,removeImageTag.length-8);
                this.showParent1 = true;
                
             } 
             if(this.approvalRec.Supervisor_Signature__c) {

                let removeImageTag = this.approvalRec.Supervisor_Signature__c.replaceAll("&amp;","&");
                this.sourceUrlParent2 = removeImageTag.substring(10,removeImageTag.length-8);
                this.showParent2 = true;
                
             } 
            this.loading = false;
        }).catch(error => {

            this.errorMessage(error);
        });

    }

    handleChange(event) {

        this.approvalRec[event.target.name] = event.target.value;
    }

    handleSave() {

        this.handleOnlySaveLogic();
        if(this.savedRec == true) {
            setTimeout(() => {
                this.handleEventInParent();
            }, 2000);
        }
            
    }

    handleOnlySaveLogic() {

        if(!this.onValidate()) {

            this.loading = true;
            saveApprovalRec({familyRiskReassessmentJSON : JSON.stringify(this.checkNamespaceApplicable(this.approvalRec,true)), parent1Signature :this.signatureObj.FIRA_Case_worker_Signature__c , parent2Signature :this.signatureObj.Supervisor_Signature__c })
            .then(result => {

                this.loading = false;
                this.title = 'Success!';
                this.type = 'success';
                this.message = 'Record saved successfully';
                this.savedRec = true;
                this.fireToastMsg();
                this.doInit();
                

            }).catch(error => {

                this.errorMessage(error);
            });

        } else {

            this.title = "Error!";
            this.message = "Required fields are missing";
            this.type = "error";
            this.fireToastMsg();
        
        }
    }

    handleEventInParent() {

        const stageEvent = new CustomEvent('doinit');
        this.dispatchEvent(stageEvent);
    }

    handleApproval() {

        if(this.approvalRec.Approval_Status__c == 'Approved') {

            this.title = "Error!";
            this.message = "Family Initial Risk Assessment Already Approved";
            this.type = "error";
            this.fireToastMsg();
        } else if(this.approvalRec.Approval_Status__c == 'Submit for Approval') {

            this.title = "Error!";
            this.message = "Family Initial Risk Assessment submitted for Approval";
            this.type = "error";
            this.fireToastMsg();
        } else {

            this.handleOnlySaveLogic();
            setTimeout(() => {
                this.submit();
            }, 2000);
            
        }
    }

    submit() {

        if( this.savedRec == true) {
            this.showApprovalScreen = true;
        }
               
    }

    hideApprovalScreen() {

        this.showApprovalScreen = false;

    }

    handleSelectRec(event) {

        this.supervisorId = event.detail.recordId;
        this.enableSubmit = this.supervisorId?false:true;
    }

    submitApproval() {

        this.loading = true;
        submitSuperApproval({ assessmentRecId: this.approvalRec.Id, selectedSupervisorUserId: this.supervisorId })
        .then(result => {
           
            this.loading = false;
            this.title = 'Success!';
            this.type = 'success';
            this.message = 'Family Initial Risk Assessment record submitted for approval';
            this.fireToastMsg();
            this.showApprovalScreen = false;
            this.doInit();
            this.handleEventInParent();

        }).catch(error => {

            this.errorMessage(error);            
        })
    }

    handleSignModal(event) {

        this.signatureFieldName = event.target.name;
        this.showSignModal = true;
    }

    closeSignModal() {

        this.showSignModal = false;
    }

    handleSignature(event) {

        this.signatureObj[this.signatureFieldName] = event.detail;
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