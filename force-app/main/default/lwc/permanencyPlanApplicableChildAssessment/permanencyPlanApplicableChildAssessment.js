import { LightningElement, api,track } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getAdoptionPlanningInitInfo from '@salesforce/apex/PermanacyPlanAdoptionController.getAdoptionPlanningStageInitialInfos';
import updateApplicableChildAssessment from '@salesforce/apex/PermanacyPlanAdoptionController.updateApplicableChildAssessmentRec';
import getSubmitForApproval from '@salesforce/apex/PermanacyPlanAdoptionController.onSubmitForApproval';

export default class PermanencyPlanApplicableChildAssessment extends UtilityBaseElement {
    @api permanencyPlanRecId;
    @track hasTheChildBeenInCarePick
    @track checkTheAgeOfChildTheChildPick;
    @track sepcialNeedsfactorPick; 
    @track applicableChildAssessmentRec = {};
    @track sepcialNeedsfactorPickVal;
    @track resubmissionSignature;
    @track caseWorkerSign;
    @track showResubmissionModal = false;
    @track showCaseworkerModal = false;
    @track showSubmitforApprovalModal =false;
    @track selectedUserId;
    @track enableSubmit =false;
    isLoading = false;
    caseWorkerSignUrl = '';
    resubmissionsignUrl = '';
    showcaseWorkerSign = false;
    showresubmissionsign = false;

    handleSectionToggle(event) {
        const openSections = event.detail.activeSections;
    }
    connectedCallback() {
        this.getIntialAdoptionPlanStage();
    }

    getIntialAdoptionPlanStage() {
        //this.applicableChildAssessmentRec.Id = this.permanencyPlanId;
        this.isLoading = true;
        getAdoptionPlanningInitInfo({ permanencyPlanId: this.permanencyPlanRecId } )
        .then(result => {
            if (result) {
                let res = JSON.parse(result);
                this.checkTheAgeOfChildTheChildPick = res.checkTheAgeOfChildTheChildPicklist;
                this.hasTheChildBeenInCarePick = res.hasTheChildBeenInCarePicklist;
                this.sepcialNeedsfactorPick = res.specialNeedsPicklist;
                let applicableAssRec = {};
                applicableAssRec = res.applicableChildAssRec;
                this.applicableChildAssessmentRec = applicableAssRec;
                if(this.applicableChildAssessmentRec.Caseworker_Signature__c) {

                    let removeImageTag = this.applicableChildAssessmentRec.Caseworker_Signature__c.replaceAll("&amp;","&");
                    this.caseWorkerSignUrl = removeImageTag.substring(10,removeImageTag.length-8);
                    this.showcaseWorkerSign = true;
                    
                 }
                 if(this.applicableChildAssessmentRec.Resubmission_Signature__c) {

                    let removeImageTag = this.applicableChildAssessmentRec.Resubmission_Signature__c.replaceAll("&amp;","&");
                    this.resubmissionsignUrl = removeImageTag.substring(10,removeImageTag.length-8);
                    this.showresubmissionsign = true;
                    
                 } 
                if(applicableAssRec.One_of_following_special_needs_factors__c != null) {
                    this.sepcialNeedsfactorPickVal = applicableAssRec.One_of_following_special_needs_factors__c.split(';');
                }
                this.isLoading = false;
                
            }
        }).catch(error => {
            this.isLoading = false;
            let errorMsg;
            this.title = "Error!";
            this.type = "error";
            if (error) {
                let errors = this.reduceErrors(error);
                errorMsg = errors.join('; ');
            } else {
                errorMsg = 'Unknown Error';
            }
            this.message = errorMsg;
            this.fireToastMsg();
        })
    }

    handleChange(event) {
        let fieldName = event.target.name;
        let fieldType = event.target.type;
        let Value = event.target.value;
        if (fieldType != 'checkbox') {
            this.applicableChildAssessmentRec[event.target.name] = event.target.value;

        } else {
            this.applicableChildAssessmentRec[event.target.name] = event.target.checked;
        }
        if (fieldName == 'One_of_following_special_needs_factors__c') {
            let multiSpecialNeedValues = Value.join(';');
            this.applicableChildAssessmentRec[fieldName] =  multiSpecialNeedValues;
        }
        
    }

    handleSave(event) {
        
        if(!this.onValidate()) {
            updateApplicableChildAssessment({applicableChildAssessmentRecJSON : JSON.stringify(this.applicableChildAssessmentRec), resubmissionsign : this.resubmissionSignature, caseworkerSign : this.caseWorkerSign}).then(result => {
               this.title = "Sucess!";
               this.type = "success";
               this.message = "Applicable Child Assessment succesfully.";
               this.fireToastMsg();
               this.getIntialAdoptionPlanStage();
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
            this.showHearingModal = false;
        } else {
            this.title = "Error!";
            this.type = "error";
            this.message = "Complete the required field(s).";
            this.fireToastMsg();

        }    
    }

    onValidate() {

        const allValid = [
            ...this.template.querySelectorAll("lightning-input"),
            ...this.template.querySelectorAll("lightning-combobox"),
            ...this.template.querySelectorAll("lightning-textarea"),
            ...this.template.querySelectorAll("lightning-dual-listbox")
            ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
            }, true);
           
            return !allValid;
    }
    handleResubmissionSignModal() {

            this.showResubmissionModal = true;
    }

    handleResubmissionSignature(event) {

        this.resubmissionSignature = event.detail;
    }

    closeResubmissionModal() {

        this.showResubmissionModal = false;
    }
    handleCaseworkerSignature(event) {

        this.caseWorkerSign = event.detail;
    }
    handleCaseworkerSignModal() {

        this.showCaseworkerModal = true;
    }
    closeCaseworkerModal() {

        this.showCaseworkerModal = false;

    }
    closeSubmiteModal(event) {
        this.showSubmitforApprovalModal = false;
    }
    submitForApproval(event) {
        if ((this.applicableChildAssessmentRec.Applicable_Child_Approval_Status__c != 'Submitted') && (this.applicableChildAssessmentRec.Applicable_Child_Approval_Status__c != 'Approved')) {
            this.handleSave();
            this.showSubmitforApprovalModal = true;
        } else if ((this.applicableChildAssessmentRec.Applicable_Child_Approval_Status__c == 'Submitted') ||(this.applicableChildAssessmentRec.Applicable_Child_Approval_Status__c == 'Approved')) {
            this.showSubmitforApprovalModal = false;    
            this.ttitle='Error!';
            this.type = "error";
            this.message ="Applicable Child Assessment Record Already Submitted "
            this.fireToastMsg();
        }
        
    }
    handleSelectRec(event) {
        this.selectedUserId = event.detail.recordId;
        this.enableSubmit = this.selectedUserId?false:true;
    }
    submitApproval(event) {
        getSubmitForApproval({permanencyRecId: this.permanencyPlanRecId, selectedSupervisorUserId:this.selectedUserId})
        .then(result=>{
            this.showSubmitforApprovalModal = false;
            this.title = "Success!";
            this.type = "success";
            this.message = "Applicable Child Assessment Record Submitted for Approval Successfully";
            this.fireToastMsg();
        })
        .catch(error => {

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
}