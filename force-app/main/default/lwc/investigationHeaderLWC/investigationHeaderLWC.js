import { LightningElement, api, track } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getInvestigationRecord from '@salesforce/apex/InvestigationController.getInvestigationRecord';
import getSearchResult from '@salesforce/apex/InvestigationController.getCaseConnectSearchResults';
import doCaseConnectApproval from '@salesforce/apex/InvestigationController.doCaseConnectApproval';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import { NavigationMixin } from 'lightning/navigation';
import getUserAccessInfo from '@salesforce/apex/ServiceCaseController.checkUserHasAccess';
import { updateRecord } from 'lightning/uiRecordApi';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

const caseConnectColumns = [
                            { label: 'Service Case ID', fieldName: 'caseURL',
                            type:'url', typeAttributes: {
                                label: { 
                                    fieldName: 'caseName' 
                                },
                                target : '_self'
                            }}, { label : 'HOH', fieldName : 'hohName', wrapText : 'true'}, 
                            { label : 'Case Status', fieldName : 'caseStatus', wrapText : 'true'},
                            {label : 'Date', fieldName : 'caseDate', wrapText : 'true'},
                            { label : 'Worker', fieldName : 'worker', wrapText : 'true'},
                            {label : 'Local Department', fieldName : 'localDpt', wrapText : 'true'}
                        ];
export default class InvestigationHeaderLWC extends NavigationMixin(UtilityBaseElement){

    @api recordId;
    contactChannel = '/event/Refresh_Investigation__e';
    subscription = {};
    @api objectApiName;
    @track investRec ={};
    @track intakeNo = '';
    @track startDate;
    @track restrict = '';
    @track hoh = '';
    @track intakeReferral = '';
    @track worker ='';
    @track casevaultId ='';
    @track reviewer = '';
    @track CaseNumber='';
    status;
    @track showModal = false;
    responseTimer;
    @track showResponseTimerWarning=false;
    @track isClosed = true;
    timeZone = TIME_ZONE;
    buttonLabel;
    modalMsg;
    showValidateModal = false;
    showIntakeNavigation = false;
    @track assignRec = {};
    showCaseConnect = false;
    caseConnectColumns = caseConnectColumns;
    @track caseConnectData = [];
    selectedCaseConnect;
    showSelect = true;
    showApproval = false;
    selectedUserId;
    enableSubmit = true;
    showNewCaseConnect = false;
    @track adminWorker;
    @track familyWorker;
    @track childWorker;

    
    connectedCallback(){
        
        loadScript(this, momentForTime)
        subscribe(this.contactChannel, -1, this.refreshList).then(response => {
            this.subscription = response;
        });
        onError(error => {});
        this.doInit();
        
    }
    refreshList = (res) => {
        this.doInit();

    }

    doInit() {

        getInvestigationRecord({investigationId: this.recordId, objectApiName: this.objectApiName})
        .then(result=> {

            let res = JSON.parse(result);
            console.log('res:::',res);
            this.familyWorker = res.familyWorker;
            this.childWorker = res.childWorker;
            this.adminWorker = res.adminWorker;
            
            this.investRec = this.checkNamespaceApplicable(res.investigationRecord,false);
            if(this.investRec.Service_Case__c) {
                this.showNewCaseConnect = false;
                this.investRec.serviceCaseName = this.investRec.Service_Case__r.Name;
            } else {
                this.showNewCaseConnect = true;
            }
            this.assignRec = this.checkNamespaceApplicable(res.assignmentRec,false);
            //this.caseConnectData = res.searchLists;
            
            if(this.investRec.Restrict_Unrestrict__c == null) {
                this.investRec.Restrict_Unrestrict__c = 'Restrict';
            }
            this.buttonLabel = this.investRec.Restrict_Unrestrict__c;
            if(this.investRec.Intake__c) {
                this.showIntakeNavigation = true;
            }
            if(this.investRec.Response_Timer__c) {
                this.responseTimer = this.investRec.Response_Timer__c;
            } else {
                var today = new Date();
                today.setMonth( today.getMonth() + 1);
                /*var date = today.getFullYear()+'/'+(today.getMonth()+1)+'/'+today.getDate();
                var time = today.getHours() + ":" + today.getMinutes();*/
                //this.responseTimer=date+' '+time;
                this.responseTimer = today;
                    }
            if(this.investRec.Intake__c != null && this.investRec.Intake__r.CaseNumber){
                this.intakeNo = this.investRec.Intake__r.CaseNumber;
            }
            if(this.investRec.Intake__c != null && this.investRec.Intake__r.Status) {
                this.status = this.investRec.Intake__r.Status;
            }
            if(this.status =='Closed') {
                this.isClosed = true;
            } else {
                this.isClosed = false;
            }
            if(res.startDate){
                this.startDate = res.startDate;
            }
            if(this.investRec.Intake__c != null && this.investRec.Intake__r.Supervisor_Approver__c){
                this.reviewer = this.investRec.Intake__r.Supervisor_Approver__r.Name;
            }
            
            if(this.investRec.Intake__c != null && this.investRec.Intake__r.Restrict_UnRestrict__c){
                this.restrict = this.investRec.Intake__r.Restrict_UnRestrict__c;
            }
            if(this.investRec.Head_of_Household__c && this.investRec.Head_of_Household__r.Name){
                this.hoh = this.investRec.Head_of_Household__r.Name;
            }
            
            if(this.investRec.Head_of_Household__c && this.investRec.Head_of_Household__r.Casevault_PID__c){
                this.casevaultId = this.investRec.Head_of_Household__r.Casevault_PID__c;
            }
            if(this.investRec.Intake__c != null && this.investRec.Intake__r.Origin){
                this.intakeReferral = this.investRec.Intake__r.Origin;
            }
            if(this.investRec.Number_of_days_created_date__c != 0) {
                this.showResponseTimerWarning = false;
            } else {
                this.showResponseTimerWarning = true;
            }
            
        })
        .catch(error => {

            this.isLoading = false;
            this.handleError(error);       
        })
    }

    openModal() {

        this.showModal = true;
    }

    closeModal() {

        this.showModal = false;
    }

    handleMouseOver() {

        if(this.buttonLabel == 'Restrict') {
            this.buttonLabel = 'Unrestrict';
        } else if(this.buttonLabel == 'Unrestrict'){
            this.buttonLabel = 'Restrict';
        }
    }

    handleMouseOut() {
        this.buttonLabel = this.investRec.Restrict_Unrestrict__c;
    }

    handleRestrictClick() {

        getUserAccessInfo({ recordId: this.recordId}).then(result => {

            if(result) {
                
                const fields = {};
                fields.Id = this.recordId;
                if(this.investRec.Restrict_Unrestrict__c == 'Restrict') {
                    fields.Restrict_Unrestrict__c = 'Unrestrict';
                } else if(this.investRec.Restrict_Unrestrict__c == 'Unrestrict'){
                    fields.Restrict_Unrestrict__c = 'Restrict';
                }
                const recordInput = { fields };

                updateRecord(recordInput)
                    .then(() => {

                        this.modalMsg = 'Record was ' +  fields.Restrict_Unrestrict__c;
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
        this.doInit();
    }

    handleRecordNavigate(event) {

        let recordId = event.target.dataset.id;
        if(recordId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    actionName: 'view'
                }
            });
        }

        
    }

    handleInitCaseConnect() {

        this.caseConnectData = [];
        this.selectedCaseConnect = '';
        this.showSelect = true;
        this.showApproval = false;
        this.showCaseConnect = false;
    }

    handleCaseConnect() {

        this.handleInitCaseConnect();
        getSearchResult({recordId: this.recordId})
        .then(result => {
            let response = JSON.parse(result);
            if(response) {
                this.caseConnectData = response;
            }
            this.showCaseConnect = true;

        }).catch(error => {
                this.handleError(error);
        });
       
    }

    handleCaseConnectSelect() {

        this.showCaseConnect = false;
        this.showApproval = true;

    }

    handleRowSelection(event) {

        this.selectedCaseConnect = event.detail.selectedRows[0].caseId;
        if(this.selectedCaseConnect) {
            this.showSelect = false;
        }
    }

    handleSC() {

        this.selectedCaseConnect = 'New';
        this.handleCaseConnectSelect();
    }

    hideModal() {

        this.showCaseConnect = false;
    }

    hideApprovalModal() {

        this.showApproval = false;
    }

    handleSelectRec(event) {

        this.selectedUserId = event.detail.recordId;
        this.enableSubmit = this.selectedUserId?false:true;
    }

    handleApproval() {

        doCaseConnectApproval({ recordId : this.recordId, supervisorId : this.selectedUserId, caseConnect : this.selectedCaseConnect})
        .then(result => {

            this.title = 'Success!';
            this.type = 'success';
            this.message = 'Record is submitted for approval';
            this.fireToastMsg();
            this.hideApprovalModal();

        }).catch(error => {
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
}