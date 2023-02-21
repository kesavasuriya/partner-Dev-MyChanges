import { LightningElement, track, api } from 'lwc';
import updateRateRec from '@salesforce/apex/AdoptionCaseController.upsertRateRecord';
import getIntialInfo from '@salesforce/apex/AdoptionCaseController.getRateRecordInfo';
import UtilityBaseElement from 'c/utilityBaseLwc';
import AddNewRateAndAnnualReviewRec from '@salesforce/apex/AdoptionCaseController.checkAddingNewRateAndAnnualReviewStatus';
import getSubmitForApproval from '@salesforce/apex/AdoptionCaseController.onSubmitSubsidyRateApprovalProcess';

const actions = [
    { label: 'Preview', name: 'preview'},
    { label: 'Edit', name: 'edit'}
    
];
const columns = [
    { label: 'TRANSACTION DATE', fieldName: 'Transaction_Date__c', type: 'string'},
    { label: 'PROVIDER ID', fieldName: 'providerId', type: 'string'},
    { label: 'RATE BEGIN DATE', fieldName: 'Rate_Begin_Date__c', type: 'string'},
    { label: 'RATE END DATE', fieldName: 'Rate_End_Date__c', type: 'string'},
    { label: 'MONTHLY PAYMENT AMOUNT', fieldName: 'Monthly_Payment_Amount__c', type: 'string'},
    { label: 'APPROVAL DATE', fieldName: 'SSA_Approval_Date__c', type: 'string'},
    { label: 'STATUS', fieldName: 'Adoption_Case_Rate_Status__c', type: 'string'},
    { type: 'action', typeAttributes: { rowActions: actions} }
    
];

export default class AdoptionCaseSubsidyRates extends UtilityBaseElement {

    @track showRateModal = false;
    @track readOnly = false;
    @api caseId;
    @track rateRecord = {};
    @track rateRecordList = [];
    primaryBasisPickValue;
    @track loading =false;
    @track showAddButton = true;
    @track showSubmitforApprovalModal =false;
    @track selectedUserId;
    @track adoptiveParent1;
    @track adoptiveParent2;
    @track agreementStartDate;
    @track agreementApprovalStatus;
    @track providerId;
    @track enableSubmit = true;
    @track enableSendforApproval = false;
    conditionCheck = true;
    approvalStatus;
    columns = columns;
    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    connectedCallback() {

        this.loading = true;
        this.doInitInfo();
        //this.rateRecord.Adoption_Case__c = this.caseId;
    }

    doInitInfo() {

        getIntialInfo({caseId : this.caseId})
        .then(result =>{

            let res = JSON.parse(result);
            this.primaryBasisPickValue = res.primaryBasisPicklist;
            if((res.rateRecord).length != 0) {

                this.rateRecordList = this.checkNamespaceApplicable(res.rateRecord, false);
                this.showAddButton = false;
                //this.approvalStatus = this.rateRecordList[0].Rate_Approval_Status__c;
            }
            if(res.caseRec) {

                let rec = this.checkNamespaceApplicable(res.caseRec, false);
                this.adoptiveParent1 = rec.Adoptive_Parent_1__c; 
                this.adoptiveParent2 = rec.Adoptive_Parent_2__c;
                this.providerId = rec.Subsidy_Provider_Id__c;
                this.agreementStartDate = rec.Subsidy_Agreement_Start_Date__c;
                this.agreementApprovalStatus = rec.Subsidy_Agreement_Approval_Status__c;

            }
            if(this.rateRecordList.length > 0) {
                for(let i = 0; i < this.rateRecordList.length; i++) {
                    this.rateRecordList[i].providerId = this.providerId;
                }
            }
            this.loading = false;

        }).catch(error => {

            this.loading=false;
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
        });

    }

    handleRateModal() {

        this.enableSendforApproval = false;
        this.loading=true;
        AddNewRateAndAnnualReviewRec({adoptionCaseId: this.caseId})
        .then(result=>{

            let res = JSON.parse(result);
            let subsidyRec = this.checkNamespaceApplicable(res.subsidyRateRecord,false);
            let annualRec = this.checkNamespaceApplicable(res.annualReviewRec,false);
            this.loading=false;
            
            if (this.agreementApprovalStatus != 'Approved') {

                this.showRateModal =false;
                this.title='Warning!';
                this.type="warning";
                this.message = 'Subsidy Agreement Record Must Be Approved';
                this.fireToastMsg();
            } else {

                if (subsidyRec && subsidyRec.length) {

                    if(subsidyRec[0].Adoption_Case_Rate_Status__c == 'Approved') {

                        if (annualRec && annualRec.length) {

                            if (annualRec[0].Annual_Review_Approval_Status__c == 'Approved') {

                                this.rateRecord = {};
                                this.readOnly = false;
                                this.showRateModal = true;   
                            } else {

                                this.title = 'Warning!';
                                this.type = 'warning';
                                this.message = 'Annual Review approval must be completed to continue adding a new Subsidy Rate.'
                                this.fireToastMsg();
                            }
                            
                        } else {

                            this.title = 'Warning!';
                                this.type = 'warning';
                                this.message = 'Annual Review approval must be completed to continue adding a new Subsidy Rate.'
                                this.fireToastMsg();
                       }
                    } else {

                        this.title = 'Warning!';
                        this.type = 'warning';
                        this.message = 'Current Rate approval must be completed to continue adding a new Subsidy Rate '
                        this.fireToastMsg();
                    }
                } else {

                    this.rateRecord = {};
                    this.readOnly = false;
                    this.showRateModal = true;
                }
            }
        }).catch(error => {

            this.loading=false;
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
        });
   }

   closeRateModal() {

        this.showRateModal = false;

    }

    handleChange(event) {

        let fieldType = event.target.type;
        let name = event.target.name;
        let value = event.target.value;
        if (fieldType != 'checkbox') {
            this.rateRecord[name] = value;
        } else {
            this.rateRecord[name] = event.target.checked;
        }
    }

    handleSave() {

        if(!this.onValidate()) { 

            const oneDay = 24 * 60 * 60 * 1000; // hours*minutes*seconds*milliseconds Agreement_Start_Date__c
            const firstDate = new Date(this.rateRecord.Rate_Begin_Date__c);
            const secondDate = new Date(this.rateRecord.Rate_End_Date__c);
            const diffDays = Math.round(Math.abs((firstDate - secondDate) / oneDay));
            if(this.rateRecord.Rate_Begin_Date__c >=  this.agreementStartDate) { 
                if (diffDays >= 365) {
                    this.conditionCheck = true;
                } else {
                    this.conditionCheck = false;
                    this.title = 'Warning!';
                    this.type = 'warning';
                    this.message = ' Rate end date and begin date difference should be 365 days.';
                    this.fireToastMsg();
                }
            } else {

                this.conditionCheck = false;
                this.title = 'Warning!';
                this.type = 'warning';
                this.message = 'Rate begin Date should not be less than agreement start date';
                this.fireToastMsg();

            }

            if(this.conditionCheck == true) {

                this.rateRecord.Adoption_Case__c = this.caseId;
                this.loading=true;
                updateRateRec({raterecord : JSON.stringify(this.checkNamespaceApplicable(this.rateRecord, true))})
                .then( result =>{

                    this.loading=false;
                    this.title = "Success!";
                    this.type = "success";
                    this.message = "Record Update Successfully"; 
                    this.fireToastMsg();
                    this.showRateModal = false;
                    this.loading = true;
                    this.doInitInfo();

                }).catch(error => {

                    this.loading=false;
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
                });
            }

            
        } else  {

            this.title ="Error!";
            this.type="error"
            this.message="Please complete the requried field(s)"
            this.fireToastMsg();
        }
    }

    handleViewModal(row) {

        this.loading = true;
        let id = row.Id;
        for(let i=0; i<this.rateRecordList.length; i++) {

            if(this.rateRecordList[i].Id == id) {

                this.rateRecord = this.rateRecordList[i];
                this.adoptiveParent1 = this.rateRecord.Adoption_Case__r.Adoptive_Parent_1__c; 
                this.adoptiveParent2 = this.rateRecord.Adoption_Case__r.Adoptive_Parent_2__c;
                this.providerId = this.rateRecord.Adoption_Case__r.Subsidy_Provider_Id__c;
                this.readOnly = true;
                this.loading = false;
                this.showRateModal = true;
            }
        }
    }

    handleEditModal(row) {

        this.enableSendforApproval = false;
        this.loading = true;
        let id = row.Id;
        for(let i=0; i<this.rateRecordList.length; i++) {

            if(this.rateRecordList[i].Id == id) {

                this.rateRecord = this.rateRecordList[i];
                this.adoptiveParent1 = this.rateRecord.Adoption_Case__r.Adoptive_Parent_1__c; 
                this.adoptiveParent2 = this.rateRecord.Adoption_Case__r.Adoptive_Parent_2__c;
                this.providerId = this.rateRecord.Adoption_Case__r.Subsidy_Provider_Id__c;
                this.loading = false;
                this.readOnly = false;
                this.showRateModal = true;

            }
        }
        

    }

    handleSubmitForApproval(event) {

        if(!this.onValidate()) { 

            this.rateRecord.Adoption_Case__c = this.caseId;
            this.loading = true;
              updateRateRec({raterecord : JSON.stringify(this.checkNamespaceApplicable(this.rateRecord, true))})
               .then( result =>{

                  this.loading = false;
                  this.showRateModal = false;
                  this.title = "Success!";
                  this.type = "success";
                  this.message = "Record Update Successfully"; 
                  this.fireToastMsg();
                  this.loading = true;
                  this.doInitInfo();
                if (this.rateRecord.Adoption_Case_Rate_Status__c !='Approved' && this.rateRecord.Adoption_Case_Rate_Status__c != 'Submitted') {

                    this.showSubmitforApprovalModal = true;
                    this.showRateModal = false;
                } else if ((this.rateRecord.Adoption_Case_Rate_Status__c == 'Submitted') ||(this.rateRecord.Adoption_Case_Rate_Status__c == 'Approved')) {

                    this.showSubmitforApprovalModal = false;    
                    this.title='Error!';
                    this.type = "error";
                    this.message ="Subsidy Agreement Record Already Submitted "
                    this.fireToastMsg();
                }
              }).catch(error => {

                  this.loading=false;
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
              });
          } else {

                this.title ="Error!";
                this.type="error"
                this.message="Please complete the requried field(s)"
                this.fireToastMsg();
          }
    }

    closeSubmiteModal(event) {

        this.showSubmitforApprovalModal = false;
    }

    handleSelectRec(event) {

        this.selectedUserId = event.detail.recordId;
        this.enableSubmit = this.selectedUserId?false:true;
    }
    submitApproval(event) {

        this.loading = true;
        getSubmitForApproval({subsidyRateId: this.rateRecord.Id, selectedSupervisorUserId:this.selectedUserId})
        .then(result=>{

            this.loading = false;
            this.showSubmitforApprovalModal = false;
            this.title = "Success!";
            this.type = "success";
            this.message = "Subsidy Rate Record Submitted for Approval Successfully";
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

    handleRowAction(event) {

        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'preview': 
                this.handleViewModal(row);
                break;
            case 'edit': 
                this.handleEditModal(row);
                break;
        }
    }


}