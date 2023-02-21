import { LightningElement, track, api, wire } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getProviders from '@salesforce/apex/PlacementController.fetchAccount';
import getSelectProviderInfos from '@salesforce/apex/PermanacyPlanAdoptionController.getSelectProviderDetail';
import getSubmitForApproval from '@salesforce/apex/PermanacyPlanAdoptionController.onSubmitForApproval';
import { getRecord } from 'lightning/uiRecordApi';

const columns = [
    { label: 'PROVIDER ID', fieldName: 'Casevault_ProID__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' } },
    { label: 'PROVIDER NAME', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'VACANCY', fieldName: 'Number_of_Beds__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' } },
    { label: 'PLACEMENT STRUCTURE', fieldName: 'Placement_Service__c', type: 'text', sortable: true },
    { label: 'PROVIDER CATEGORY', fieldName: 'Type__c', type: 'text', sortable: true }
];

const FIELDS = ['Permanency_Plan__c.Subsidy_Agreement_Start_Date__c', 'Permanency_Plan__c.Subsidy_Agreement_Start_Date__c', 'Permanency_Plan__c.Subsidy_Agreement_End_Date__c', 'Permanency_Plan__c.Offer_Accepted_Date__c',
    'Permanency_Plan__c.Adoptive_Parent_1_signature_date__c', 'Permanency_Plan__c.Adoptive_Parent_2_Signature_Date__c', 'Permanency_Plan__c.LDSS_Director_Designee_Signature_Date__c'
];

export default class PermanencyPlanSubsidyAgreement extends UtilityBaseElement {

    @track subsidyAgreementRec = {};
    @api permanencyRecId;
    @track permanencyRec = {};
    @track permanencyRecord = {};
    @track showSearchProviderModal = false;
    @track searchInput = {};
    columns = columns;
    @track providerList = [];
    @track selectedProviderId;
    @track sleectproviderMD_chessie_Id;
    @track showProviderTable = false;
    @track isLoading = false;
    @track showSubmitforApprovalModal = false;
    @track selectedUserId;
    @track enableSubmit = false;
    @track enableSubmitForApprovalBtn = false;
    @track showSignModal = false;
    @track signatureFieldName;
    @track signatureObj = {};
    isValid;
    openApprovalScreen;

    @wire(getRecord, { recordId: '$permanencyRecId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {

            this.permanencyRec.Subsidy_Agreement_Start_Date__c = data.fields.Subsidy_Agreement_Start_Date__c.value;
            this.permanencyRec.Subsidy_Agreement_End_Date__c = data.fields.Subsidy_Agreement_End_Date__c.value;
            this.permanencyRec.Offer_Accepted_Date__c = data.fields.Offer_Accepted_Date__c.value;
            this.permanencyRec.Adoptive_Parent_1_signature_date__c = data.fields.Adoptive_Parent_1_signature_date__c.value;
            this.permanencyRec.Adoptive_Parent_2_Signature_Date__c = data.fields.Adoptive_Parent_2_Signature_Date__c.value;
            this.permanencyRec.LDSS_Director_Designee_Signature_Date__c = data.fields.LDSS_Director_Designee_Signature_Date__c.value;

        } else if (error) {
            this.title = "Error!";
            this.type = "error";
            this.message = error;
            this.fireToastMsg();
        }
    }

    get providerTypes() {
        return [
            { 'label': 'Public', 'value': 'Public Provider' },
            { 'label': 'Private', 'value': 'Private Provider Org' },
        ];
    }

    searchHandle(event) {

        let name = event.target.name;
        let value = event.target.value;
        this.searchInput[name] = value;

    }

    handleShowSearch(event) {

        this.showSearchProviderModal = true;

    }

    closeSearchModal(event) {

        this.showSearchProviderModal = false;

    }

    handleSearchProvider(event) {

        this.isLoading = true;
        getProviders({ searchInputJSON: JSON.stringify(this.searchInput) })
            .then(result => {
                if (result) {

                    this.providerList = JSON.parse(result);
                    this.isLoading = false;
                    this.showSearchProviderModal = false;
                    this.showProviderTable = true;
                    if (!this.providerList.length) {
                        this.title = "info!";
                        this.type = "info";
                        this.message = "Such provider not exsits";
                        this.fireToastMsg();
                    }
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

    handleRowSelection(event) {

        var selectedRows = event.detail.selectedRows;
        this.selectedProviderId = selectedRows[0].Id;
        this.sleectproviderMD_chessie_Id = selectedRows[0].Casevault_ProID__c;
        this.subsidyAgreementRec.Subsidy_Provider_Id__c = this.sleectproviderMD_chessie_Id;

    }

    handleSubmitForApproval() {


        this.isValid = this.onRequiredValidate();
        this.openApprovalScreen = true;

    }

    closeShowTableModal(event) {

        this.showSearchProviderModal = false;
        this.showProviderTable = false;

    }

    handleSelectedProvider(event) {

        getSelectProviderInfos({ providerId: this.selectedProviderId })
            .then(result => {
                if (result) {

                    this.showProviderTable = false;
                    let appilcantAndCoAppilcantList = JSON.parse(result);
                    if (appilcantAndCoAppilcantList.length) {

                        for (let i = 0; i < appilcantAndCoAppilcantList.length; i++) {

                            if (appilcantAndCoAppilcantList[i].Applicant_or_Co_Applicant__c == "Applicant") {

                                this.subsidyAgreementRec.Adoptive_Parent_1__c = appilcantAndCoAppilcantList[i].Name;
                            } else if (appilcantAndCoAppilcantList[i].Applicant_or_Co_Applicant__c == "Co-Applicant") {

                                this.subsidyAgreementRec.Adoptive_Parent_2__c = appilcantAndCoAppilcantList[i].Name;
                            }
                        }
                    }
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


    closeSubmiteModal(event) {

        this.showSubmitforApprovalModal = false;

    }

    handleSelectRec(event) {

        this.selectedUserId = event.detail.recordId;
        this.enableSubmit = this.selectedUserId ? false : true;

    }

    submitApproval(event) {

        getSubmitForApproval({ permanencyRecId: this.permanencyRecId, selectedSupervisorUserId: this.selectedUserId })
            .then(result => {

                this.showSubmitforApprovalModal = false;
                this.title = "Success!";
                this.type = "success";
                this.message = "Subsidy Agreement Record Submitted for Approval Successfully";
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

    handleSuccess(event) {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record Updated Successfully';
        this.fireToastMsg();

        if (this.openApprovalScreen) {

            if ((this.subsidyAgreementRec.Subsidy_Approval_Status__c != 'Submitted') && (this.subsidyAgreementRec.Subsidy_Approval_Status__c != 'Approved')) {

                this.showSubmitforApprovalModal = true;

            } else {

                if (this.subsidyAgreementRec.Subsidy_Approval_Status__c == 'Submitted') {

                    this.message = "Subsidy Agreement Record Already Submitted";

                } else if (this.subsidyAgreementRec.Subsidy_Approval_Status__c == 'Approved') {

                    this.message = "Subsidy Agreement Record Already Approved";
                }

                this.showSubmitforApprovalModal = false;
                this.title = 'Error!';
                this.type = "error";
                this.fireToastMsg();
            }
        }

    }

    handleError(event) {

        this.title = "Error!";
        this.type = "error";
        this.message = event.detail.detail;
        this.fireToastMsg();

    }

    onFormValidate() {

        this.openApprovalScreen = false;
        this.isValid = this.onRequiredValidate();

    }

    handleSubmit(event) {

        event.preventDefault();
        if (this.isValid) {

            const fields = event.detail.fields;
            if (this.signatureObj.length > 0) {

                fields.Adoptive_Parent_1_Signature__c = this.signatureObj.Adoptive_Parent_1_Signature__c;
                fields.Adoptive_Parent_2_Signature__c = this.signatureObj.Adoptive_Parent_2_Signature__c;
                fields.LDSS_Director_DESIGNEE_SIGNATURE__c = this.signatureObj.LDSS_Director_DESIGNEE_SIGNATURE__c;
            }

            fields.Subsidy_Provider_Id__c = this.selectedProviderId;
            fields.Subsidy_Agreement_Start_Date__c = this.permanencyRec.Subsidy_Agreement_Start_Date__c;
            fields.Subsidy_Agreement_End_Date__c = this.permanencyRec.Subsidy_Agreement_End_Date__c;
            fields.Offer_Accepted_Date__c = this.permanencyRec.Offer_Accepted_Date__c;
            fields.Adoptive_Parent_1_signature_date__c = this.permanencyRec.Adoptive_Parent_1_signature_date__c;
            fields.Adoptive_Parent_2_Signature_Date__c = this.permanencyRec.Adoptive_Parent_2_Signature_Date__c;
            fields.LDSS_Director_Designee_Signature_Date__c = this.permanencyRec.LDSS_Director_Designee_Signature_Date__c;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }

    handleOnLoad(event) {

        var record = event.detail.records;
        var fields = record[this.permanencyRecId].fields;

        if (fields.Subsidy_Approval_Status__c) {

            this.subsidyAgreementRec.Subsidy_Approval_Status__c = fields.Subsidy_Approval_Status__c.value;
            if (this.subsidyAgreementRec.Subsidy_Approval_Status__c == 'Submitted' || this.subsidyAgreementRec.Subsidy_Approval_Status__c == 'Approved') {

                this.enableSubmitForApprovalBtn = true;
            }
        }

    }

    handleChange(event) {

        let fieldName = event.target.name;
        this.permanencyRec[fieldName] = event.target.value;

    }
}