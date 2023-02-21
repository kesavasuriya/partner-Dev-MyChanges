import { LightningElement, track, api,wire} from 'lwc';
import getTitleIVERecords from '@salesforce/apex/TitleIvEController.getEligibilityDetailRecords';
import getRelatedTitleRecs from '@salesforce/apex/TitleIvEController.getRelatedTitleRecs';
import updateNarrativeRec from '@salesforce/apex/TitleIvEController.updateNattrive';
import updateSignature from '@salesforce/apex/TitleIvEController.updateSignature';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import { loadScript } from 'lightning/platformResourceLoader';
import submitforApproval from '@salesforce/apex/TitleIvEController.onSubmitForApproval';
import getResponseRec from '@salesforce/apex/TitleIvEController.getEligibilityDetailRec';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import {getRecord} from 'lightning/uiRecordApi';

import UtilityBaseElement from 'c/utilityBaseLwc';


export default class ComponentSataus extends UtilityBaseElement {
    @track apiResponse = {};
    @track apiObject = {};
    @api titleiverecordidlist;
    @track courtRecord = [];
    @track titleIVERec = [];
    @track titleIVEChildRecs = [];
    @track setRequest = [];
    @track showEligibilityTable = false;
    @track showNarrativeModal = false;
    @track showErrorMessage = false;
    @track showSignatureModal = false;
    @track narrative = {};
    @track specialistSignature;
    @track specialistSignatureDate = {};
    @track selectedUserId;
    @track submitforApprovalRecId;
    @track titleIveRecId;
    showSubmitforApprovalModal = false;
    showSignImageModal = false;
    showSigneditModal = false;
    @track isLoading = false;
    apiMessage = {};
    narrativeRec = {};
    Message;
    showMessage = false;
    @track name;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.name = data.fields.Name.value;
        }
    }
     
    @api refresh() {
        this.doInitInfo();
    }
    connectedCallback() {
				
				loadScript(this, momentForTime)
            .then(() => {
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
                this.message = errorMsg;
                this.fireToastMsg();
            })
       console.log(this.name);
        this.isLoading = true;
        this.apiMessage[1] = 'Court component is Eligible Reimbursable as child Removal date is earlier than court order date';
        this.apiMessage[2] = 'Court component is Ineligible as child Removal date is later than court order date';
        this.apiMessage[3] = 'Removal Home is Eligible Reimbursable as Specified relative client id is same as the CTW- contrary to welfare client id';
        this.apiMessage[4] = 'Removal Home is Ineligible as Specified relative client id is not same as the CTW- contrary to welfare client id';
        this.apiMessage[5] = 'Demographics is Eligible Reimbursable as child is United states citizen or qualified Alien and Age during the AFDC eligibility month is less than 18';
        this.apiMessage[6] = 'Demographics is Ineligible as child is not United states citizen nor qualified Alien';
        this.apiMessage[7] = 'Demographics is Ineligible as Age during the AFDC eligibility month is greater than or equal to 18';
        this.apiMessage[8] = 'Demographics is Ineligible as child is not United states citizen nor qualified Alien and Age during the AFDC eligibility month is greater than or equal to 18';
        this.apiMessage[9] = 'Deprivation is Ineligible as child is not Deprived of parental support';
        this.apiMessage[10] = 'Deprivation is Eligible Reimbursable as child is Deprived of parental support  and deprivation factor is "Absence"';
        this.apiMessage[11] = 'Deprivation is Eligible Reimbursable as child is Deprived of parental support  and deprivation factor is "Death of either parent"';
        this.apiMessage[12] = 'Deprivation is Eligible Reimbursable as child is Deprived of parental support  and deprivation factor is "Incapacity"';
        this.apiMessage[13] = 'Deprivation is Eligible Reimbursable as child is Deprived of parental support  and deprivation factor is "Unemployment"';
        this.apiMessage[14] = 'Deprivation is Eligible Reimbursable as child is Deprived of parental support  and deprivation factor is "Underemployment"';
        this.apiMessage[15] = 'Deprivation is Ineligible as child is Deprived of parental support but the deprivation factor is "None"';
        this.apiMessage[16] = 'Income is Eligible Reimbursable as Total available income is less than or equal to Standard of need amount';
        this.apiMessage[17] = 'Income is Ineligible as Total available income is greater than Standard of need amount';
        this.apiMessage[18] = 'Asset is Eligible Reimbursable as total Asset value is less than or equal to USD 10000';
        this.apiMessage[19] = 'Asset is Ineligible as total Asset value is greater than USD 10000';
        this.apiMessage[20] = 'Placement is Eligible Reimbursable as Placement is Reimbursable and Child Placement Date is later than Removal Date';
        this.apiMessage[21] = 'Placement is Eligible Non Reimbursable as Placement is non Reimbursable';
        this.apiMessage[22] = 'Placement is Eligible Non Reimbursable as Child Placement Date is later than Removal Date';
        this.apiMessage[23] = 'Placement is Eligible Non Reimbursable as Child Placement Date earlier than Removal Date';
        this.apiMessage[24] = 'Removal Type is Eligible Reimbursable and it is a court order removal';
        this.apiMessage[25] = 'Removal Type is Eligible Reimbursable and it is a VPA removal';
        this.apiMessage[26] = 'Demographics is Eligible Reimbursable as child is United states citizen or qualified Alien and Age during the AFDC eligibility month is less than 18 and child is receiving SSI or SSA Benefits';
        this.apiMessage[27] = 'Demographics is Eligible Reimbursable as child is United states citizen or qualified Alien and Age during the AFDC eligibility month is less than 18 and child is not receiving SSI or SSA Benefits';
        this.apiMessage[28] = 'Demographics is Eligible Non Reimbursable as child is receiving SSI or SSA Benefits and Agency did not Opt To Suspend The SSI Payment And Claim IVE';
        this.apiMessage[29] = 'Demographics is Eligible Non Reimbursable as child is receiving SSI or SSA Benefits and Agency did not Opt To Suspend The SSI Payment And Claim IVE';
        this.apiMessage[100] = 'Removal date or Court order date is NULL or EMPTY';
        this.apiMessage[101] = 'Age During AFDC month is NULL';
        this.apiMessage[102] = 'Is the child recelving SSI or SSA during review period is NULL or EMPTY';
        this.apiMessage[103] = 'Has the agency opted to suspend the SSI payment and claim Iv is NULL or EMPTY';
        this.apiMessage[104] = 'Is the Agency the RepresentativePayee is NULL or EMPTY';
        this.apiMessage[105] = 'Is the Child a US Citizen or Is the Child a Qualified Alien is NULL or EMPTY';
        this.apiMessage[106] = 'Child deprived of parental support is NULL or EMPTY';
        this.apiMessage[107] = 'Deprivation factor is NULL or EMPTY';
        this.apiMessage[108] = 'Family size is NULL';
        this.apiMessage[109] = 'SpRelClIdsameAsCtw is NULL or EMPTY';
        this.apiMessage[110] = 'Removal Type is NULL or EMPTY';
        this.apiMessage[111] = 'PlacementReimbursable is NULL or EMPTY';
        this.apiMessage[112] = 'Placement begin date or Child removal date is NULL or EMPTY';


        this.doInitInfo();
       }

    doInitInfo() {
         this.titleIVERec = [];
        getTitleIVERecords({ titleIVEIdList: this.titleiverecordidlist })

        .then(result => {
            let titleIvERecList = [];
            this.titleIVERec = this.checkNamespaceApplicable(JSON.parse(result), false);
            if (this.titleIVERec.length != null) {
 
                for (let i = 0; i < this.titleIVERec.length; i++) {
                    this.titleIVERec[i].CreatedDate = moment(this.titleIVERec[i].CreatedDate).format('MM/DD/YYYY hh:mm A');
                    this.titleIVERec[i].Approved_Date_Time__c = moment(this.titleIVERec[i].Approved_Date_Time__c).format('MM/DD/YYYY hh:mm A');
                    /*this.titleIVERec[i].Review_Period_Start_Date__c = moment(this.titleIVERec[i].Review_Period_Start_Date__c).format('MM/DD/YYYY hh:mm A');
                    this.titleIVERec[i].Review_Period_End_Date__c = moment(this.titleIVERec[i].Review_Period_End_Date__c).format('MM/DD/YYYY hh:mm A');*/
                    this.titleIVERec[i].selected = false;
                    

                }
            }
            this.isLoading = false;

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
            this.isLoading = false;
            this.message = errorMsg;
            this.fireToastMsg();
        })
    }

    openEligibleTable(event) {

        this.isLoading = true;
        this.titleIveRecId = event.currentTarget.getAttribute('data-name');
        let recordType = event.currentTarget.getAttribute('data-label');
        this.removeSelectedRow();
        if(recordType == 'parentRecord') {

            for (let i = 0; i < this.titleIVERec.length; i++) {
                this.titleIVERec[i].selectedRow = '';
                if (parseInt(event.currentTarget.getAttribute('data-index')) == i) {
                    this.titleIVERec[i].selectedRow = 'selectedRowClass';
                }
            }

        } else if(recordType == 'childRecord') {

            let lst =[];
            let index;
            for (let i = 0; i < this.titleIVERec.length; i++) {
                this.titleIVERec[i].selectedRow = '';
                if(this.titleIVERec[i].Id == event.currentTarget.getAttribute('data-parentid')) {
                    lst = this.titleIVERec[i].childTitleRecs;
                    index = i;

                }
            }
                    for (let j = 0; j < lst.length; j++) {
                        lst[j].selectedRow = '';
                        if (parseInt(event.currentTarget.getAttribute('data-index')) == j) {
                            lst[j].selectedRow  = 'selectedRowClass';
                        }
                    }
                    this.titleIVERec[index].childTitleRecs =lst;
        }
        
        getResponseRec({ titleIVEId: this.titleIveRecId })
            .then(result => {
                this.apiResponse = this.checkNamespaceApplicable(JSON.parse(result), false);
                this.apiObject = this.apiResponse;
                this.showEligibilityTable = true;
      
                if (this.apiResponse.Placement_Status__c != 'MISSING' && this.apiResponse.Placement_Status__c) {
                    this.apiObject.placement = 'CRITERIA ' + this.apiResponse.Placement_Status__c+'ED';
                } else {
                    this.apiObject.placement = 'MISSING INFO';
                }

                if (this.apiResponse.Demographics_Status__c != 'MISSING' && this.apiResponse.Demographics_Status__c) {
                    this.apiObject.demographics = 'CRITERIA ' + this.apiResponse.Demographics_Status__c+'ED';
                } else {
                    this.apiObject.demographics = 'MISSING INFO';
                }

                if (this.apiResponse.CourtStatus_Status__c != 'MISSING' && this.apiResponse.CourtStatus_Status__c) {
                    this.apiObject.courtStatus = 'CRITERIA ' + this.apiResponse.CourtStatus_Status__c+'ED';
                } else {
                    this.apiObject.courtStatus = 'MISSING INFO';
                }

                if (this.apiResponse.HomeRemoval_Status__c != 'MISSING' && this.apiResponse.HomeRemoval_Status__c) {
                    this.apiObject.homeRemoval = 'CRITERIA ' + this.apiResponse.HomeRemoval_Status__c+'ED';
                } else {
                    this.apiObject.homeRemoval = 'MISSING INFO';
                }

                if (this.apiResponse.Income_Status__c != 'MISSING' && this.apiResponse.Income_Status__c) {
                    this.apiObject.income = 'CRITERIA ' + this.apiResponse.Income_Status__c+'ED';
                } else {
                    this.apiObject.income = 'MISSING INFO';
                }

                if (this.apiResponse.Asset_Status__c != 'MISSING' && this.apiResponse.Asset_Status__c) {
                    this.apiObject.asset = 'CRITERIA ' + this.apiResponse.Asset_Status__c+'ED';
                } else {
                    this.apiObject.asset = 'MISSING INFO';
                }

                if (this.apiResponse.Deprivation_Status__c != 'MISSING' && this.apiResponse.Deprivation_Status__c) {
                    this.apiObject.deprivation = 'CRITERIA ' + this.apiResponse.Deprivation_Status__c+'ED';
                } else {
                    this.apiObject.deprivation = 'MISSING INFO';
                }

                if (this.apiResponse.RemovalType_Status__c != 'MISSING' && this.apiResponse.RemovalType_Status__c) {
                    this.apiObject.removalType = 'CRITERIA ' + this.apiResponse.RemovalType_Status__c+'ED';
                } else {
                    this.apiObject.removalType = 'MISSING INFO';
                }
                this.apiObject.CreatedDate = moment(this.apiResponse.CreatedDate).format('MM/DD/YYYY hh:mm A');
                this.isLoading = false;
            
                
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
                this.isLoading = false;
                this.message = errorMsg;
                this.fireToastMsg();
            })
    }
    handleErrorMessage() {
        this.showErrorMessage = true;
    }
    handleDeemedIncome() {
        var url = '/apex/Deemed_Income_Worksheet?id=' + this.titleiverecordidlist[0];
        window.open(url, '_blank');
    }
    handleIncomeAsset() {
        var url = '/apex/IncomeAssetWorksheet?id=' + this.titleiverecordidlist[0];
        window.open(url, '_blank');
    }
    handleRedeterminationEligibility() {
        var url = '/apex/RedeterminationEligibilityWorksheet?id=' + this.titleiverecordidlist[0] + '&status=' + this.this.titleIVERec[i].FinalStatus__c;
        window.open(url, '_blank');
    }

    handleNarrativeModal(event) {

        this.narrativeRec.Id = event.currentTarget.getAttribute('data-name');
        this.submitforApprovalRecId = event.currentTarget.getAttribute('data-name');
        this.narrative = event.currentTarget.getAttribute('data-narrative');
        this.specialistSignatureDate.Id = event.currentTarget.getAttribute('data-name');

        this.showNarrativeModal = true;
    }
    closeNarrativeModal() {

        this.showNarrativeModal = false;

    }
    closeSignatureModal() {

        this.showSignatureModal = false;
        this.showSignImageModal = false;
        this.showSubmitforApprovalModal = false;
        this.showSigneditModal = false;

    }

    handleNarrativeChange(event) {

        this.narrativeRec[event.target.name] = event.target.value;

    }

    handleNarrativeSave() {
        updateNarrativeRec({ updateNarrativeJSON: JSON.stringify(this.checkNamespaceApplicable(this.narrativeRec, true)) })
            .then(result => {

                this.showNarrativeModal = false;
                this.showSignatureModal = true;
                this.title = "Success!";
                this.type = "success";
                this.message = "Record Created Successfully";
                this.fireToastMsg();

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
                this.isLoading = false;
                this.message = errorMsg;
                this.fireToastMsg();
            })

    }

    handleSignature(event) {

        this.specialistSignature = event.detail;

    }

    handleDate(event) {

        this.specialistSignatureDate.IV_E_Specialist_Signature_Date__c = event.target.value;
    }

    handleSignImage(event) {

        this.showSignImageModal = true;
        this.specialistSignatureDate.Id = event.currentTarget.getAttribute('data-name');
        this.specialistSignature = event.currentTarget.getAttribute('data-sign');

    }

    handleEditSign(event) {

        this.specialistSignature = undefined;
        this.specialistSignatureDate.Id = event.currentTarget.getAttribute('data-name');
        this.specialistSignatureDate.Title_Iv_E__c = event.currentTarget.getAttribute('data-titleparent');
        this.showSigneditModal = true;
    }

    handleSubmit() {
        if (this.specialistSignature) {
            updateSignature({ updateSignJSON: this.specialistSignature, updateTitleIVEJSON: JSON.stringify(this.specialistSignatureDate) })
            .then(result => {

                let foundelement = this.titleIVERec.find(ele => ele.Id == this.specialistSignatureDate.Id);
                if (foundelement) {
                    foundelement.IV_E_Specialist_Signature__c = result;
                    this.titleIVERec = [...this.titleIVERec];
                } else {
                    //this.titleIVERec.forEach((element) => {
                    let foundelement = this.titleIVERec.find(ele => ele.Title_Iv_E__c == this.specialistSignatureDate.Title_Iv_E__c);
                    if (foundelement) {
                        if (foundelement.childTitleRecs && foundelement.childTitleRecs.length) {
                            let foundelement1 = foundelement.childTitleRecs.find(ele => ele.Id == this.specialistSignatureDate.Id);
                            if (foundelement1) {
                                foundelement1.IV_E_Specialist_Signature__c = result;
                                this.titleIVERec = [...this.titleIVERec];
                            } 
                        }
                    }   

                }
                this.showSignatureModal = false;
                this.title = "Success!";
                this.type = "success";
                this.message = "Signature Updated  Successfully";
                this.fireToastMsg();
                if (this.showSigneditModal == false) {
                    if (this.titleIVERec.Status__c == 'Submitted') {
                        this.title = "Warning!";
                        this.type = "warning";
                        this.message = "Record is Already Submitted for Approval";
                        this.fireToastMsg();
                    } else if (this.titleIVERec.Status__c == 'Approved') {
                        this.title = "Warning!";
                        this.type = "warning";
                        this.message = "Record is Already Approved";
                        this.fireToastMsg();
                    } else {
                        this.showSubmitforApprovalModal = true;
                    }
                }
                this.showSigneditModal = false;

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
                this.isLoading = false;
                this.message = errorMsg;
                this.fireToastMsg();
            })
        } else {
            this.title = "Error!";
            this.type = "error";
            this.message = 'Please confirm the signature';
            this.fireToastMsg();
        }
    }

    handleSelectRec(event) {

        this.selectedUserId = event.detail.recordId;
    }

    handleToggleClick(event) {

        this.isLoading = true;
        let titleParentId = event.currentTarget.getAttribute('data-name');
				let titleId = event.currentTarget.getAttribute('data-id');
				let period = event.currentTarget.getAttribute('data-period');
				let iconName = event.target.name;
				if (iconName == 'DownIcon') {
						getRelatedTitleRecs({ titleIVEId: titleParentId, latestTitleIVEId: titleId, titlePeriod: period})

						.then(result => {

								let titleIVEChildRecs = this.checkNamespaceApplicable(JSON.parse(result), false);
                                for (let i = 0; i < titleIVEChildRecs.length; i++) {
                                    titleIVEChildRecs[i].CreatedDate = moment(titleIVEChildRecs[i].CreatedDate).format('MM/DD/YYYY hh:mm A');
                                    titleIVEChildRecs[i].Approved_Date_Time__c = moment(titleIVEChildRecs[i].Approved_Date_Time__c).format('MM/DD/YYYY hh:mm A');

                                    //titleIVEChildRecs[i].Review_Period_Start_Date__c = moment(titleIVEChildRecs[i].Review_Period_Start_Date__c).format('MM/DD/YYYY hh:mm A');
                                    //titleIVEChildRecs[i].Review_Period_End_Date__c = moment(titleIVEChildRecs[i].Review_Period_End_Date__c).format('MM/DD/YYYY hh:mm A');
                                }

                                let foundelement = this.titleIVERec.find(ele => ele.Title_Iv_E__c == titleParentId);
                                if (foundelement) {
                                    foundelement.selected = true;
                                    foundelement.childTitleRecs = titleIVEChildRecs;
                                    this.titleIVERec = [...this.titleIVERec];
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
								this.isLoading = false;
								this.message = errorMsg;
								this.fireToastMsg();
						})
				} else {

                    let foundelement = this.titleIVERec.find(ele => ele.Title_Iv_E__c == titleParentId);
                                if (foundelement) {
                                    foundelement.selected = false;
                                    foundelement.childTitleRecs = [];
                                    this.titleIVERec = [...this.titleIVERec];
                                }
                }
       
        this.isLoading = false;
    }

    submitApproval() {

        submitforApproval({ titleIVERecId: this.submitforApprovalRecId, selectedSupervisorUserId: this.selectedUserId })
            .then(result => {
                this.showSubmitforApprovalModal = false;
                this.title = "Success!";
                this.type = "success";
                this.message = "TitleIV-E Record Submitted for Approval Successfully";
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
                this.isLoading = false;
                this.message = errorMsg;
                this.fireToastMsg();
            })
    }

    showMessageTemplate(event) {
        this.showMessage = false;
        this.Message = this.apiMessage[event.currentTarget.getAttribute('data-message')];
        this.showMessage = true;

    }
    removeSelectedRow() {

        let lst = [];
        for (let i = 0; i < this.titleIVERec.length; i++) {
            
            if(this.titleIVERec[i].selectedRow) {
             this.titleIVERec[i].selectedRow = '';
            }

            if(this.titleIVERec[i].childTitleRecs) {
             lst=this.titleIVERec[i].childTitleRecs;

                for(let j = 0; j < lst.length; j++) {
                lst[j].selectedRow = '';
                }
                this.titleIVERec[i].childTitleRecs=lst;
                lst = [];
            }
        }
    }


}