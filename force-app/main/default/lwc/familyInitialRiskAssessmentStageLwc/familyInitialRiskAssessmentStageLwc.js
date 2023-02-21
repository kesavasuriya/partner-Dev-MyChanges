import { LightningElement, track, api } from 'lwc';
import getPicklist from '@salesforce/apex/AssessmentController.getFamilyInitialRiskAssessmentStagePicklist';
import getInit from '@salesforce/apex/AssessmentController.getFamilyInitialRiskAssessmentStageInfo';
import deleteAssessment from '@salesforce/apex/AssessmentController.deleteAssessment';
import UtilityBaseElement from 'c/utilityBaseLwc';


const actions = [
    { label: 'Delete', name: 'delete'}   
];
const dataColumn = [{ label: 'Assessment Name', type:  'button',typeAttributes: { 
                        variant :'base', name : 'name',
                                label:   { 
                            fieldName: 'Name' 
                        } }},
                    {label: 'Date Assessment Initiated', fieldName:'FRRE_Date_Assessment_Initiated__c',type: "date",
                    typeAttributes:{
                        year: "numeric",
                        month: "2-digit",
                        day: "2-digit",
                        hour: "2-digit",
                        minute: "2-digit"
                    }},{label:'Approval Status',fieldName:'Approval_Status__c'},
                    { type: 'action', typeAttributes: { rowActions: actions} }];
export default class FamilyInitialRiskAssessmentStageLwc extends UtilityBaseElement {

    @api recordId;
    @api objectApiName;
    @track currentStage = '1';
    showfamilyandHouseholdCompositionLwc = true;
    showNeglectAbuseIndex = false;
    showScoringOverrides = false;
    showSupplementalQuestion = false;
    showApproval = false;
    showActionCmp = false;
    @track stageList =[];
    @track assessmentRec = {};
    showActionStage = false;
    @track actionStageList = [{label : 'Action Taken', value: 'Action Taken'},{label:'Approval', value:'Approval'}];
    currentActionStage = 'Action Taken';
    readOnly = false;
    @track assessmentList = [];
    dataColumn = dataColumn;
    assessmentId = '';
    showList = true;
    tableAction = '';
    currentOnStageValue = '';
    loading = false;
    showMsg = false;
    get heading() {
        if(this.assessmentList) {
            return 'FAMILY INITIAL RISK ASSESSMENTS ('+this.assessmentList.length+')';
        } else {
            return 'FAMILY INITIAL RISK ASSESSMENTS';
        }
    }

    connectedCallback() {

        this.loading = true;
        getPicklist()
        .then(result =>{

            let res = JSON.parse(result);
            this.stageList = res.stages.splice(1);
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
        })
        this.doInit();
    }

    doInit() {

        this.loading = true;
        getInit({recordId:this.recordId})
        .then(result => {

            let res = JSON.parse(result);
           
            if(res.familyRiskReassessmentRec.length > 0) {
                this.assessmentList = this.checkNamespaceApplicable(res.familyRiskReassessmentRec, false);
                this.showMsg = false;
                
            } else if(res.familyRiskReassessmentRec.length <= 0) {
                this.assessmentList = [];
                this.showMsg = true;
            }
            this.showList = true;
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
        })
    }

    stageAction(event) {

        this.currentOnStageValue = event.target.value;
        this.setStage();
       
    }

    setStage() {

        if(this.currentOnStageValue == '1') {

            this.showfamilyandHouseholdCompositionLwc = true;
            this.showNeglectAbuseIndex = false;
            this.showScoringOverrides = false;
            this.showSupplementalQuestion = false;
            this.showApproval = false;
            this.showActionCmp = false;

        } else if(this.currentOnStageValue == '2') {

            if(this.currentStage >= this.currentOnStageValue) {

                this.showfamilyandHouseholdCompositionLwc = false;
                this.showNeglectAbuseIndex = true;
                this.showScoringOverrides = false;
                this.showSupplementalQuestion = false;
                this.showApproval = false;
                this.showActionCmp = false;

            } else {
                this.title = "Error!";
                this.type = "error";
                this.message = 'Save the Family and Household Composition';
                this.fireToastMsg();
            }

        } else if(this.currentOnStageValue == '3') {

            if(this.currentStage >= this.currentOnStageValue) {

                this.showfamilyandHouseholdCompositionLwc = false;
                this.showNeglectAbuseIndex = false;
                this.showScoringOverrides = true;
                this.showSupplementalQuestion = false;
                this.showApproval = false;
                this.showActionCmp = false;

            } else {
                this.title = "Error!";
                this.type = "error";
                this.message = 'Save the Neglect/Abuse Index';
                this.fireToastMsg();
            }


        } else if(this.currentOnStageValue == '4') {

            if(this.currentStage >= this.currentOnStageValue) {

                this.showfamilyandHouseholdCompositionLwc = false;
                this.showNeglectAbuseIndex = false;
                this.showScoringOverrides = false;
                this.showSupplementalQuestion = true;
                this.showApproval = false;
                this.showActionCmp = false;

            } else {
                this.title = "Error!";
                this.type = "error";
                this.message = 'Save the Scoring and Overrides';
                this.fireToastMsg();
            }

        } else if(this.currentOnStageValue == '5') {

            if(this.currentStage >= this.currentOnStageValue) {

                this.showfamilyandHouseholdCompositionLwc = false;
                this.showNeglectAbuseIndex = false;
                this.showScoringOverrides = false;
                this.showSupplementalQuestion = false;
                this.showApproval = true;
                this.showActionCmp = false;

            } else {
                this.title = "Error!";
                this.type = "error";
                this.message = 'Save the Supplemental Question';
                this.fireToastMsg();
            }
    
        } else if(this.currentOnStageValue == 'Action Taken') {

            this.showfamilyandHouseholdCompositionLwc = false;
            this.showNeglectAbuseIndex = false;
            this.showScoringOverrides = false;
            this.showSupplementalQuestion = false;
            this.showApproval = false;
            this.showActionCmp = true;

        } else if(this.currentOnStageValue == 'Approval') {

            if(this.assessmentRec.Actions_Taken__c != null) {
                this.showfamilyandHouseholdCompositionLwc = false;
                this.showNeglectAbuseIndex = false;
                this.showScoringOverrides = false;
                this.showSupplementalQuestion = false;
                this.showApproval = true;
                this.showActionCmp = false;
            } else {
                this.title = "Error!";
                this.type = "error";
                this.message = 'Save the Action Taken ';
                this.fireToastMsg();
            }
            
        }

    }

    handleStage(event) {

        this.assessmentId = event.detail.assRecId;
        if(event.detail.stage != 'action') {
            this.currentOnStageValue = event.detail.stage;
            this.currentStage = this.currentOnStageValue;
            this.setStage();
        } else {
            this.currentActionStage = 'Approval';
            this.showActionCmp = false;
            this.showApproval = true;
        }
        
    }

    handleNew() {

        this.assessmentRec = {};
        this.showActionStage = false;
        this.initializeValues();
        this.assessmentId = '';
        this.tableAction = 'new';
        this.showList = false;
       
    }

    handleBack() {
        this.doInit();
    }

    initializeValues() {

        this.showfamilyandHouseholdCompositionLwc = false;
        this.showNeglectAbuseIndex = false;
        this.showScoringOverrides = false;
        this.showSupplementalQuestion = false;
        this.showApproval = false;
        this.showActionCmp = false;
        this.assessmentId = this.assessmentRec.Id;
        this.currentStage = this.assessmentRec.FamilyInitialRiskAssessmentStage__c;
        if(this.assessmentRec.Department_is_unable_to_locate_child__c != null) {
            this.showActionStage = this.assessmentRec.Department_is_unable_to_locate_child__c;     
        }
        if(this.currentStage == null) {
            this.currentStage = '1';
        }
        if(this.showActionStage != true) {

            if(this.currentStage == '1') {
                this.showfamilyandHouseholdCompositionLwc = true;
            } else if(this.currentStage == '2') {
                this.showNeglectAbuseIndex = true;
            } else if(this.currentStage == '3') {
                this.showScoringOverrides = true;
            } else if(this.currentStage == '4') {
                this.showSupplementalQuestion = true;
            } else if(this.currentStage == '5') {
                this.showApproval = true;
            }
        }
        
    }

    handleRow(event) {

        this.assessmentRec = event.detail.row;
        this.initializeValues();
       
        if(event.detail.action.name != 'delete') {
            
           
            if(this.assessmentRec.Approval_Status__c == 'Approved') {
                this.readOnly = true;
            } else if(this.assessmentRec.Approval_Status__c != 'Approved') {
                this.readOnly = false;
            }
           
            if(this.showActionStage == true) {

                if(this.assessmentRec.Actions_Taken__c != null) {
                    this.currentActionStage = 'Approval';
                    this.showApproval = true;
                } else {
                    this.currentActionStage = 'Action Taken';
                    this.showActionCmp = true;
                }
            }
            this.tableAction = event.detail.action.name;
            this.showList = false;
        
        }
        
        if(event.detail.action.name == 'delete') {

            var deleteRow = event.detail.row;
            if(deleteRow.Approval_Status__c == 'Approved') {

                this.title = "Error!";
                this.message = "Record Already Approved";
                this.type = "error";
                this.fireToastMsg();
            } else {

                this.loading = true;
                deleteAssessment({recordId:deleteRow.Id})
                .then(result => {
    
                    this.title = "Success!";
                    this.type = "success";
                    this.message = 'Record deleted successfully';
                    this.fireToastMsg();
                    this.doInit();
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
                })
            }
           
        }
    }

    handleChange(event) {

        this.showfamilyandHouseholdCompositionLwc = false;
        this.showNeglectAbuseIndex = false;
        this.showScoringOverrides = false;
        this.showSupplementalQuestion = false;
        this.showApproval = false;
        this.showActionCmp = false;

        this.showActionStage = event.target.checked;
        

        if(this.showActionStage == true) {

            if(this.assessmentRec.Actions_Taken__c != null) {
                this.currentActionStage = 'Approval';
                this.showApproval = true;
            } else {
                this.currentActionStage = 'Action Taken';
                this.showActionCmp = true;
            }
        } else if(this.showActionStage != true) {

            if(this.currentStage == '1') {
                this.showfamilyandHouseholdCompositionLwc = true;
            } else if(this.currentStage == '2') {
                this.showNeglectAbuseIndex = true;
            } else if(this.currentStage == '3') {
                this.showScoringOverrides = true;
            } else if(this.currentStage == '4') {
                this.showSupplementalQuestion = true;
            } else if(this.currentStage == '5') {
                this.showApproval = true;
            }
        }
        
    }

    handleDoInit() {
        this.doInit();
    }
}