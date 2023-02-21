import { LightningElement, api, track } from 'lwc';
import getAnnualReviewInfo from '@salesforce/apex/AdoptionCaseController.getAnnualReviewInfo';
import upsertAnnualReviewRecord from '@salesforce/apex/AdoptionCaseController.upsertAnnualReviewRecord';
import AddNewRateAndAnnualReviewRec from '@salesforce/apex/AdoptionCaseController.checkAddingNewRateAndAnnualReviewStatus';
import getSubmitForApproval from '@salesforce/apex/AdoptionCaseController.onSubmitAnnualReviewApprovalProcess';
import UtilityBaseElement from 'c/utilityBaseLwc';

const actions = [
    { label: 'Edit', name: 'edit'},
    
];
const columns = [
    { label: 'Review Date', fieldName: 'Review_Date__c', type: 'string'},
    { label: 'Approval Status', fieldName: 'Annual_Review_Approval_Status__c', type: 'string'},
    { type: 'action', typeAttributes: { rowActions: actions} }
    
];
export default class AdoptionCaseAnnualReview extends UtilityBaseElement {

    @api caseId;
    @track annualReviewList = [];
    showModal = false;
    loading = false;
    @track annualReviewRec = {};
    @track caseRec = {};
    @track showSubmitforApprovalModal =false;
    @track selectedUserId;
    @track enableSubmit = true;
    @track enableSendforApproval = false;
    columns = columns;
    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    connectedCallback() {

        this.doInit();
    }

    doInit() {

        this.loading = true;
        getAnnualReviewInfo({caseId:this.caseId})
        .then(result => {

            let res = JSON.parse(result);
            if(res.annualReviewRecords) {
                this.annualReviewList = this.checkNamespaceApplicable(res.annualReviewRecords, false);
            }
            if(res.caseRec) {
                this.caseRec = this.checkNamespaceApplicable(res.caseRec, false);
            }
            this.loading = false;
            
        }).catch(error => {

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
        })
    }
    
    
    handleChange(event) {

        this.annualReviewRec[event.target.name] = event.target.value;
    }

    handleEdit(row){

        this.loading = true;
        let id = row.Id;
        this.annualReviewRec = {};
        for(let i=0; i<this.annualReviewList.length; i++) {

            if(this.annualReviewList[i].Id == id) {

                this.annualReviewRec = this.annualReviewList[i];
                this.loading = false;
                this.showModal = true;
            }
        }
    }

    handleAdd() {

        this.loading = true;
        AddNewRateAndAnnualReviewRec({adoptionCaseId: this.caseId})
        .then(result=>{

            this.loading = false;
            let res = JSON.parse(result);
            let subsidyRec = this.checkNamespaceApplicable(res.subsidyRateRecord,false);
            let annualRec = this.checkNamespaceApplicable(res.annualReviewRec,false);
                if (subsidyRec && subsidyRec.length) {

                    if(subsidyRec[0].Adoption_Case_Rate_Status__c == 'Approved') {

                        if (annualRec && annualRec.length) {

                            if (annualRec[0].Annual_Review_Approval_Status__c == 'Approved') {

                                this.title ='Warning!';
                                this.type='warning';
                                this.message = 'Annual Review is Completed. If you want to create an annual review create a new Subsidy rate under Subsidy Rate Tab.';
                                this.fireToastMsg();
                            } else {

                                this.title ='Warning!';
                                this.type='warning';
                                this.message = 'current Annual Review approval must be complete to continue the create new Annual Review.';
                                this.fireToastMsg();
                            }
                            
                        } else {

                            //Set default rate end date value set review Date in Annual Review 
                            this.annualReviewRec = {};
                            this.annualReviewRec.Review_Date__c = subsidyRec[0].Rate_End_Date__c;
                            this.showModal = true;
                        }
                    } else {

                        this.title ='Warning!';
                        this.type='warning';
                        this.message = 'Rate approval must be completed to continue adding a new Annual Review.';
                        this.fireToastMsg();
                    }
                } else {

                    this.title ='Warning!';
                    this.type='warning';
                    this.message = 'There is no existing Rate record found.';
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
    }
    hideModal() {

        this.showModal = false;
    }
    handleSave() {

        this.annualReviewRec.Adoption_Case__c = this.caseId;
        if(!this.onValidate()) { 

            this.loading = true;
            upsertAnnualReviewRecord({annualReviewrecord:JSON.stringify(this.checkNamespaceApplicable(this.annualReviewRec, true))})
            .then(result => {

                this.showModal = false;
                this.doInit();
                this.title = "Success!";
                this.type = "success";
                this.message = "Record Update Successfully"; 
                this.fireToastMsg();
                this.loading=false;
                
                
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

            this.title = "Error!";
            this.type = "error";
            this.message = "Required fields are missing"; 
            this.fireToastMsg();
        }

    }

    handleSubmitForApproval(event) {

        if(!this.onValidate()) { 

            this.annualReviewRec.Adoption_Case__c = this.caseId;
            this.loading = true;
            upsertAnnualReviewRecord({annualReviewrecord:JSON.stringify(this.checkNamespaceApplicable(this.annualReviewRec, true))})
            .then( result =>{

                 this.loading = false;
                  this.title = "Success!";
                  this.type = "success";
                  this.message = "Record Update Successfully"; 
                  this.fireToastMsg();
                  
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
              if (this.annualReviewRec.Annual_Review_Approval_Status__c !='Approved' && this.annualReviewRec.Annual_Review_Approval_Status__c != 'Submitted') {

                this.showModal=false;
                this.showSubmitforApprovalModal = true;
                
                
            } else if ((this.annualReviewRec.Annual_Review_Approval_Status__c == 'Submitted') ||(this.annualReviewRec.Annual_Review_Approval_Status__c == 'Approved')) {
                this.showSubmitforApprovalModal = false;    
                this.title='Error!';
                this.type = "error";
                this.message ="Annual Review Record Already Submitted "
                this.fireToastMsg();
            }
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
        getSubmitForApproval({annualReviewId: this.annualReviewRec.Id, selectedSupervisorUserId:this.selectedUserId})
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
            case 'edit': 
                this.handleEdit(row);
                break;
        }
    }

}