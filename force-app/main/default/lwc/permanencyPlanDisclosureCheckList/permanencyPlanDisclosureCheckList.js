import { LightningElement, track, api, wire } from 'lwc';
import onSubmitForApproval from '@salesforce/apex/PermanacyPlanAdoptionController.onSubmitForApproval';
import { getRecord } from 'lightning/uiRecordApi';
import UtilityBaseElement from 'c/utilityBaseLwc';

const FIELDS = ['Permanency_Plan__c.Applicable_Child_Approval_Status__c', 'Permanency_Plan__c.Disclosure_Approval_Status__c', 'Permanency_Plan__c.Disclosure_Creation_Date__c'];

export default class PermanencyPlanDisclosureCheckList extends UtilityBaseElement {

    @api permanencyRecId;
    @track readOnly = false;
    @track disclosureChecklistRec = {};
    @track loading = false;
    showApprovalScreen = false;
    supervisorId;
    enableSubmit = true;
    @track enableApprovalButton = true;
    disclosureDate;
    permanencyRec = {};
    isValid;
    openApprovalScreen;

    @wire(getRecord, { recordId: '$permanencyRecId', fields: FIELDS })
    wiredRecord({ error, data }) {

        if (data) {
            this.disclosureDate = data.fields.Disclosure_Creation_Date__c.value;
            if (data.fields.Applicable_Child_Approval_Status__c.value == 'Approved' && data.fields.Disclosure_Approval_Status__c.value == null && data.fields.Disclosure_Creation_Date__c.value != null) {
                this.enableApprovalButton = true;
            } else {
                this.enableApprovalButton = false;
            }

        } else if (error) {

        }
    }

    submitforApproval() {

        this.openApprovalScreen = true;
        this.isValid = this.onRequiredValidate();
    }

    hideApprovalScreen() {

        this.showApprovalScreen = false;
    }

    handleSelectRec(event) {

        this.supervisorId = event.detail.recordId;
        this.enableSubmit = this.supervisorId ? false : true;
    }

    submitApproval() {

        onSubmitForApproval({ permanencyRecId: this.permanencyRecId, selectedSupervisorUserId: this.supervisorId })
            .then(result => {
                this.title = "Success!";
                this.type = "success";
                this.message = "DisclosureChecklist Record Submitted for Approval";
                this.fireToastMsg();
                this.showApprovalScreen = false;
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

    handleSuccess(event) {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record Updated Successfully';
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
        this.permanencyRec[event.target.name] = event.target.value;
    }

    onFormValidate() {

        this.openApprovalScreen = false;
        this.isValid = this.onRequiredValidate();
    }

    handleSubmit(event) {

        event.preventDefault();
        if (this.isValid) {
            const fields = event.detail.fields;
            fields.Disclosure_Creation_Date__c = this.permanencyRec.Disclosure_Creation_Date__c;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }
}