import { LightningElement, track, api } from 'lwc';
import getInitiInfo from '@salesforce/apex/AssessmentController.getSAFECOHPInitialInformation';
import saveSAFCOHP from '@salesforce/apex/AssessmentController.createSAFECOHP';
import ApprovalStatus from '@salesforce/apex/AssessmentController.onSubmitStatus';
import getChoosenOHPAssessmentRec from '@salesforce/apex/AssessmentController.getAssessmentOHP';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitSuperApproval from '@salesforce/apex/AssessmentController.onSubmitForApproval';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import UtilityBaseElement from 'c/utilityBaseLwc';

const columns = [
    { label: 'Assessment Name', type:  'button',typeAttributes: { 
        variant :'base', name : 'name',
                 label:   { 
            fieldName: 'Name' 
        } }},
    { label: 'Safety Assessment Completion Date Time', fieldName: 'OHP_Signature_Obtained_Date__c', type: 'date',typeAttributes:{day:"numeric",month:"numeric",year:"numeric",hour:"numeric",minute:"numeric",hour12:"true"} },
    { label: 'Approval Status', fieldName: 'Approval_Status__c', type: 'text', wrapText: true}
    
];

export default class SafecOHPCmp extends UtilityBaseElement {
    @track immediatehealthneedsPicklist;
    @track safecOHPRec = {};
    @api recordId;
    @api objectApiName;
    @track contactNames;
    @track chlidList = [];
    @track safeCheck = false;
    @track unSafeCheck = false;
    @track safetyDecisionList = [];
    assessmentOHPList = [];
    showCmp = false;
    showOHPTable = false;
    showSubmitModal = false;
    assessmentId;
    supervisorId;
    readOnly = false;
    loading = false;
    hideNewBtn = true;
    safetyDecesionList = [];
    @track visibleData = [];
    showChild = false;
    columns = columns;

    get safecohptitle() {
        if(this.assessmentOHPList) {
            return 'SAFE-C-OHP ('+this.assessmentOHPList.length+')';
        } else {
            return 'SAFE-C-OHP';
        }
    }

    renderedCallback() {
        Promise.all([
                loadScript(this, momentForTime)
            ]).then(() => {

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
    connectedCallback() {
        let typeValue = 'SAFE-C-OHP';
        this.safecOHPRec['Assessment_Type__c'] = typeValue;
        this.loading = true;
        this.pageLoadInfo();
    }

    showNew(event) {
        this.safecOHPRec = {};
        this.showCmp = true;
        this.loading = true;
        this.readOnly = false;
        let typeValue = 'SAFE-C-OHP';
        this.safecOHPRec['Assessment_Type__c'] = typeValue;
        this.pageLoadInfo();
    }


    closeEventModal(event) {
        this.showCmp = false;
        this.loading = false;
        this.showSubmitModal = false;
    }

    getAssessmetOHPRecord(row) {
        this.showCmp = true;
        this.loading = true;
        let assessmentId = row.Id;
        getChoosenOHPAssessmentRec({ assessmentRecordId: assessmentId })
            .then(result => {
                this.safecOHPRec = {};
                this.safecOHPRec = this.checkNamespaceApplicable(JSON.parse(result).assessmentOHPRec, false);
                this.safeCheck = this.safecOHPRec.OHP_Child_is_Safe_Influences_1_12_Marked__c;
                this.unSafeCheck = this.safecOHPRec.OHP_Child_is_Unsafe_Any_Influence_1_12__c ;
                this.showCmp = true;
                this.loading = false;
                if (this.safecOHPRec.Approval_Status__c == 'Approved') {
                    this.readOnly = true;
                } else {
                    this.readOnly = false;
                }
                 /*for (let i = 0; i < this.safecOHPRec.length; i++) {
                    if(this.safecOHPRec[i].OHP_Signature_Obtained_Date__c) {
                    this.safecOHPRec[i].OHP_Signature_Obtained_Date__c = moment.tz(this.safecOHPRec[i].OHP_Signature_Obtained_Date__c, "America/Los_Angeles").format('MM/DD/YYYY hh:mm A');
                    }
                }*/

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
                this.loading = false;
                this.message = errorMsg;
                this.fireToastMsg();
            })
    }

    pageLoadInfo() {

       
        this.safecOHPRec[this.objectApiName] = this.recordId;
        

        this.safecOHPRec['Type_c'] = 'SAFE-C-OHP';
        this.loading = true;
        this.showChild = false;
        getInitiInfo({ recordId: this.recordId })
            .then(result => {
                this.loading = false;
                this.immediatehealthneedsPicklist = JSON.parse(result).thechildsImmediatehealthneedsPicklist;
                this.contactNames = JSON.parse(result).cotactsNames;
                var serviceCaseStatus = JSON.parse(result).statusService;
                if (serviceCaseStatus) {
                    this.servicecaseStatus = this.checkNamespaceApplicable(JSON.parse(result).statusService, false);
                    if (this.servicecaseStatus.Status__c == 'Close') {
                        this.hideNewBtn = false;
                    }
                }

                this.assessmentOHPList = this.checkNamespaceApplicable(JSON.parse(result).assessmentOHPList, false);
                if(this.assessmentOHPList) {
                /*for (let i = 0; i < this.assessmentOHPList.length; i++) {
                    this.assessmentOHPList[i].OHP_Signature_Obtained_Date__c = moment(this.assessmentOHPList[i].OHP_Signature_Obtained_Date__c).format('MM/DD/YYYY   hh:mm A');

                }*/
            }
                this.chlidList = JSON.parse(result).childInputWarpList;
                if (this.assessmentOHPList.length) {
                    this.showOHPTable = true;
                    this.showChild = true;
                }
            })
            .catch(error => {

               /* let errorMsg;
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
                this.fireToastMsg();*/
            })
    }

    handleSelection(event) {

        let row = event.target.name;
        //this.currentRec = this.chlidList[index];
        let rows = this.chlidList;
        //const rowIndex = rows.indexOf(row);
        rows.splice(row, 1);
        this.chlidList = rows;
        //  this.chlidList = [];

    }

    influenceHandleChange(event) {

        let fieldName = event.target.name;
        let fieldValue = event.target.value;
        this.safecOHPRec[fieldName] = fieldValue;

        if (fieldValue == 'Yes' || fieldValue == 'No') {

            let foundelement = this.safetyDecisionList.find(ele => ele.name == fieldName);

            if (!foundelement) {
                this.safetyDecisionList.push({
                    name: fieldName,
                    value: fieldValue,
                    index: event.target.dataset.index
                })
            } else {
                foundelement.value = fieldValue;
                this.safetyDecisionList = [...this.safetyDecisionList];
            }
        } else if (fieldValue == '') {

            let safetyRemovingList = this.safetyDecisionList;
            for (let i = 0; i < safetyRemovingList.length; i++) {
                if (safetyRemovingList[i].name == fieldName) {
                    safetyRemovingList.splice(i, 1);
                }
            }
            this.safetyDecisionList = safetyRemovingList;
        }

        if (this.safetyDecisionList.length == 12) {

            let foundelement = this.safetyDecisionList.find(ele => ele.value == 'No');
            if (!foundelement) {

                this.safeCheck = true;
                this.unSafeCheck = false;

            } else {
                this.unSafeCheck = true;
                this.safeCheck = false;
            }
        } else {
            this.unSafeCheck = false;
            this.safeCheck = false;
        }
        if (this.safetyDecisionList.length) {
            let foundelement = this.safetyDecisionList.find(ele => ele.value == 'No');
            if (foundelement) {

                this.unSafeCheck = true;

            } else {
                this.unSafeCheck = false;
            }
        } else {
            this.unSafeCheck = false;
            this.safeCheck = false;
        }

    }

    handleChange(event) {

        let fieldName = event.target.name;
        let checkedfields = event.target.checked;
        let Value = event.target.value;
        let fieldType = event.target.type;
        if (fieldType != 'checkbox') {
            this.safecOHPRec[event.target.name] = event.target.value;

        } else {
            this.safecOHPRec[event.target.name] = event.target.checked;
        }


        /*let foundelement = this.safetyDecisionList.find(ele => ele.name == event.target.name);
    
        if(!foundelement){
            this.safetyDecisionList.push({
                name:event.target.name,
                value:event.target.value,
                index:event.target.dataset.index
            })
        } else {
            foundelement.value = event.target.value;
            this.safetyDecisionList = [...this.safetyDecisionList];
        }*/

    }

    handleSave(event) {
        this.safecOHPRec.OHP_Child_is_Safe_Influences_1_12_Marked__c = this.safeCheck;
        this.safecOHPRec.OHP_Child_is_Unsafe_Any_Influence_1_12__c = this.unSafeCheck;
        this.loading = true;
        if (!this.onValidate()) {
            saveSAFCOHP({ assessmentSAFECOHPDataJSON: JSON.stringify(this.checkNamespaceApplicable(this.safecOHPRec, true)) }).then(result => {
                this.loading = false;
                this.pageLoadInfo();
                const toastMsg = this.assessmentId ? 'Assessment record updated succesfully.' : 'Assessment record created succesfully.';
                const event = this.onToastEvent('success', 'Success!', toastMsg);
                this.dispatchEvent(event);
                this.showCmp = false;
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
                this.loading = false;
                this.message = errorMsg;
                this.fireToastMsg();
            })
        } else {
        }

    }

    onSumbitforApproval(event) {
        if (!this.onValidate()) {
            let saveQesList = [];
            this.safecOHPRec.OHP_Child_is_Safe_Influences_1_12_Marked__c = this.safeCheck;
        this.safecOHPRec.OHP_Child_is_Unsafe_Any_Influence_1_12__c = this.unSafeCheck;
            saveSAFCOHP({ assessmentSAFECOHPDataJSON: JSON.stringify(this.checkNamespaceApplicable(this.safecOHPRec, true)) }).then(result => {
                this.pageLoadInfo();
                const toastMsg = this.assessmentId ? 'Assessment record updated succesfully.' : 'Assessment record created succesfully.';
                const event = this.onToastEvent('success', 'Success!', toastMsg);
                this.dispatchEvent(event);
                this.assessmentId = result;
                this.safecOHPRec['Id'] = result;
                this.checkSubmitStatus();
                this.showCmp = false;
                this.showSubmitModal = true;
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
                this.loading = false;
                this.message = errorMsg;
                this.fireToastMsg();
            })
        } else {
            const event = this.onToastEvent('error', 'Error!', 'Complete the required field(s).');
            this.dispatchEvent(event);
        }
    }

    handleSelectRec(event) {

        this.supervisorId = event.detail.recordId;
        this.enableSubmit = this.supervisorId ? false : true;
    }


    submitApproval(event) {
        submitSuperApproval({ assessmentRecId: this.assessmentId, selectedSupervisorUserId: this.supervisorId }).then(result => {
            const event = this.onToastEvent('success', 'Success!', 'Assessment record Send to Supervisor Approval');
            this.dispatchEvent(event);
            this.showCmp = false;
            this.showSubmitModal = false;
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
            this.loading = false;
            this.message = errorMsg;
            this.fireToastMsg();
        })
    }

    checkSubmitStatus() {

        let assessmentRec;
        ApprovalStatus({ assessmentRecId: this.assessmentId }).then(result => {
            assessmentRec = JSON.parse(result);
            if (assessmentRec.Approval_Status__c == 'Submit for Approval') {
                this.showingErrorModal = true;
                this.showErrorMsg = 'This Assessment record already in approval process.';
                //const event = this.onToastEvent('error', 'Error!', 'This assesment record already in approval process.');
                //this.dispatchEvent(event);
            } else if (assessmentRec.Approval_Status__c == 'Approved') {
                this.showingErrorModal = true;
                this.showErrorMsg = 'This Assessment record is already approved.';
                //const event = this.onToastEvent('error', 'Error!', 'This assesment record already approved.');
                //this.dispatchEvent(event);
            } else {
                this.showingErrorModal = false;
                this.showErrorMsg = '';
            }
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
            this.loading = false;
            this.message = errorMsg;
            this.fireToastMsg();
        })
    }
		
	
		cancelSubmitModal(event) {
				this.showSubmitModal = false;
		}

    onValidate() {
        const allValid = [
            ...this.template.querySelectorAll("lightning-input"), ...this.template.querySelectorAll("lightning-combobox"), ...this.template.querySelectorAll("lightning-textarea")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return !allValid;
    }

    onToastEvent(type, toastTitle, msg) {

        const toastEvent = new ShowToastEvent({
            variant: type,
            title: toastTitle,
            message: msg,
        });
        return toastEvent;
    }
    paginationHandler(event) {

        this.visibleData = [...event.detail.records];     
    }

    handleRowAction(event) {

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'name':
                this.getAssessmetOHPRecord(row);
                break;
            
        }

    }

}