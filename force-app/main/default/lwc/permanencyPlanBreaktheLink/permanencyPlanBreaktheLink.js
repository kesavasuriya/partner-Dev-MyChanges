import { LightningElement, track, api } from 'lwc';
import getBreakthelinkRec from '@salesforce/apex/PermanacyPlanAdoptionController.getBreakthelinkRecord';
import onSubmitForApproval from '@salesforce/apex/PermanacyPlanAdoptionController.onSubmitForApproval';
import UtilityBaseElement from 'c/utilityBaseLwc';


export default class PermanencyPlanBreaktheLink extends UtilityBaseElement {

    @api permanencyRecId;
    @track breaktheLinkRec = {};
    loading = false;
    @track tprList = [];
    tprDateofParent1;
    tprDateofParent2;
    @track placement = {};
    @track courtRec = {};
    providerName;
    placementStructure;
    beginDate;
    endDate;
    approvalStatus;
    showApprovalScreen = false;
    supervisorId;
    enableSubmit = true;
    @track breakList = [];
    courtOrderDate;
    isValid;
    openApprovalScreen;

    connectedCallback() {
        this.loading = true;
        this.breaktheLinkRec.Id = this.permanencyRecId;
        this.doInitInfo();
    }

    doInitInfo() {

        getBreakthelinkRec({ permanencyPlanId: this.permanencyRecId })
            .then(result => {

                let res = this.checkNamespaceApplicable(JSON.parse(result), false);
                this.breaktheLinkRec.Date_Agreement_signed__c = this.checkNamespaceApplicable(JSON.parse(result).breaktheLinkRecord).Date_Agreement_signed__c;
                
                if (res.breaktheLinkRecord) {
                    this.breaktheLinkRec.Break_Line_Approval_Status__c = res.breaktheLinkRecord.Break_Line_Approval_Status__c;
                }

                if (res.tpRList) {

                    this.breaktheLinkRec.Child_is_Legally_free__c = true;
                    this.tprList = res.tpRList;
                    if (this.tprList.length == 1) {
                        this.tprDateofParent1 = this.tprList[0].TPR_Decision_Date__c;
                    } else if (this.tprList.length == 2) {
                        this.tprDateofParent1 = this.tprList[0].TPR_Decision_Date__c;
                        this.tprDateofParent2 = this.tprList[1].TPR_Decision_Date__c;
                    }
                }

                if (res.placementRec) {

                    this.placement = res.placementRec;
                    this.providerName = this.placement[0].Provider__r.Name;
                    this.placementStructure = this.placement[0].Placement_Structure__c;
                    this.beginDate = this.placement[0].Begin_Date__c;
                    this.endDate = this.placement[0].End_Date__c;
                    this.approvalStatus = this.placement[0].Placement_Approval_Status__c;
                    if (this.endDate != null) {
                        this.breaktheLinkRec.Child_was_in_an_Approved_Pre_Adoptive__c = true;
                    } else {
                        this.breaktheLinkRec.Child_was_in_an_Approved_Pre_Adoptive__c = false;
                    }
                }

                if (res.courtHearingRec.length) {

                    let rec = res.courtHearingRec;
                    this.courtRec = rec[0];
                    if (this.courtRec.Court__c != null && this.courtRec.Court__r.Court_Order_Date__c) {
                        this.breaktheLinkRec.Adoption_has_been_finalized__c = true;
                        this.courtOrderDate = this.courtRec.Court__r.Court_Order_Date__c;
                    }
                }

                this.loading = false;
            }).catch(error => {

                this.loading = false;
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
            });

    }


    handleSelectRec(event) {

        this.supervisorId = event.detail.recordId;
        this.enableSubmit = this.supervisorId ? false : true;
    }

    submitforApproval() {


        if (this.breaktheLinkRec.Break_Line_Approval_Status__c == 'Approved') {

            this.title = "Error!";
            this.type = "error";
            this.message = "Break the link Record Already Approved";
            this.fireToastMsg();
        } else if (this.breaktheLinkRec.Break_Line_Approval_Status__c == 'Submitted') {

            this.title = "Error!";
            this.type = "error";
            this.message = "Break the link Record Submitted for Approval";
            this.fireToastMsg();
        } else {
            this.openApprovalScreen = true;
            this.isValid = this.onRequiredValidate();
        }

    }

    hideApprovalScreen() {

        this.showApprovalScreen = false;
    }

    submitApproval() {

        onSubmitForApproval({ permanencyRecId: this.permanencyRecId, selectedSupervisorUserId: this.supervisorId })
            .then(result => {
                this.title = "Success!";
                this.type = "success";
                this.message = "Break the link Record Submitted for Approval";
                this.fireToastMsg();
                this.showApprovalScreen = false;
                this.loading = true;
                this.doInitInfo();
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
                this.message = errorMsg;
                this.fireToastMsg();
            })
    }

    onFormValidate() {

        this.openApprovalScreen = false;
        this.isValid = this.onRequiredValidate();        
    }

    handleSubmit(event) {

        event.preventDefault();
        if (this.isValid) {
            const fields = event.detail.fields;
            fields.Date_Agreement_signed__c = this.breaktheLinkRec.Date_Agreement_signed__c;
            if (this.breaktheLinkRec.Child_is_Legally_free__c == true && this.breaktheLinkRec.Child_was_in_an_Approved_Pre_Adoptive__c == true &&
                this.courtOrderDate != null && this.breaktheLinkRec.Adoption_has_been_finalized__c == true) {
                this.template
                    .querySelector('lightning-record-edit-form').submit(fields);
            } else {
                this.title = "Error!";
                this.type = "error";
                this.message = 'Required field Missing!';
                this.fireToastMsg();
            }
        }
    }

    handleSuccess(event) {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record Update Successfully';
        this.fireToastMsg();
        if (this.openApprovalScreen) {
            this.showApprovalScreen = true;    
        }
    }

    handleError(event) {

        this.title = "Error!";
        this.type = "error";
        this.message = event.detail.detail;
        this.fireToastMsg();
    }

    handleChange(event) {
        this.breaktheLinkRec[event.target.name] = event.target.value;
    }
}