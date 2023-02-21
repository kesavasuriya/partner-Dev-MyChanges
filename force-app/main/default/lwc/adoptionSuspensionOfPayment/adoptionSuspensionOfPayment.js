import { LightningElement, track, api } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getSuspensionintialInfo from '@salesforce/apex/AdoptionCaseController.getSuspensionintialInfo';
import upsertSuspensionRec from '@salesforce/apex/AdoptionCaseController.upsertSuspensionRec';
import deleteSuspensionRec from '@salesforce/apex/AdoptionCaseController.deleteSuspensionRec';
import onSubmitSuspensionApprovalProcess from '@salesforce/apex/AdoptionCaseController.onSubmitSuspensionApprovalProcess';

const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];
const columns = [
    { label: 'Transaction Date', fieldName: '', type: 'string', wrapText: true },
    { label: 'Suspension Begin Date', fieldName: 'Start_Date__c', type: 'string',wrapText: true },
    { label: 'Suspension End Date', fieldName: 'End_Date__c', type: 'string', wrapText: true},
    { label: 'Approval Status', fieldName: 'Adoption_Suspension_Approval_Status__c', type: 'string',  wrapText: true },
    { label: 'Approved by', fieldName: 'Adoption_Suspension_Approved_By__c', type: 'string',  wrapText: true },
    { type: 'action',typeAttributes: { rowActions: actions }, wrapText: true }
];

export default class AdoptionSuspensionOfPayment extends UtilityBaseElement {

    @track showSuspensionModal = false;
    @track isLoading = false;
    @api adoptionCaseId;
    @track suspensionForReasonPick;
    @track suspensionList = [];
    @track adoptionSuspensionRec ={};
    @track showUpdateBtn =false;
    @track readOnly = false;
    @track annualReviewRec = {};
    isOverlapped = true;
    columns = columns;
    supervisorId;
    enableSubmit;
    showApprovalScreen = false;
    

    connectedCallback() {

        this.isLoading = true;
        this.getSuspensionintiInfo();
    }

    getSuspensionintiInfo() {

        getSuspensionintialInfo({adoptionCaseId:this.adoptionCaseId}) 
        .then(result => {
            if (result) {

                let res = JSON.parse(result);
                this.suspensionForReasonPick = res.suspensionForReasonPickList;
                this.isLoading = false;
                if(res.suspensionRecordList) {
                    this.suspensionList = this.checkNamespaceApplicable(res.suspensionRecordList,false);
                }
                if(res.annualReviewRec) {
                    this.annualReviewRec = this.checkNamespaceApplicable(res.annualReviewRec[0],false);
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

    handleChange(event) {

        this.adoptionSuspensionRec[event.target.name] = event.target.value;
        
    }

    handleSave() {

        if(!this.onValidate()) { 

            if( this.adoptionSuspensionRec.Start_Date__c < this.adoptionSuspensionRec.End_Date__c) {
                this.isOverlapped = true;
            } else {
    
                this.isOverlapped = false;
                this.title ="Warning!";
                this.type="Warning"
                this.message="New suspension record end date should be greater than new start date.";
                this.fireToastMsg();
            
            }
            
            if((this.suspensionList.length > 1 || (this.suspensionList.length == 1 && this.suspensionList[0].Id !=  this.adoptionSuspensionRec.Id)) ) {
                let compareList = this.suspensionList[0].Id !=  this.adoptionSuspensionRec.Id ? this.suspensionList[0] : this.suspensionList[1];
                if(compareList.Start_Date__c < this.adoptionSuspensionRec.Start_Date__c ) {
                    if(compareList.End_Date__c) {
                        if(compareList.End_Date__c < this.adoptionSuspensionRec.Start_Date__c ) {
                            if(this.adoptionSuspensionRec.End_Date__c) {
                                if(compareList.End_Date__c < this.adoptionSuspensionRec.End_Date__c) {
                                    if( this.adoptionSuspensionRec.Start_Date__c < this.adoptionSuspensionRec.End_Date__c) {
                                        this.isOverlapped = true;
                                } else {
    
                                        this.isOverlapped = false;
                                        this.title ="Warning!";
                                        this.type="Warning"
                                        this.message="New suspension record end date should be greater than new start date.";
                                        this.fireToastMsg();
                                    
                                    }
                                } else {
    
                                    this.isOverlapped = false;
                                    this.title ="Warning!";
                                    this.type="Warning"
                                    this.message="New suspension record end date must be greater than old end date.";
                                    this.fireToastMsg();
                                }
                            } else {
                                this.isOverlapped = true; 
                            }
                        } else {
                            this.isOverlapped = false;
                            this.title ="Warning!";
                            this.type="Warning"
                            this.message="New suspension record Start date must be greater than old end date.";
                            this.fireToastMsg();
    
                        }
                    } else {
                        if(this.adoptionSuspensionRec.End_Date__c) {
                            if (compareList.Start_Date__c < this.adoptionSuspensionRec.End_Date__c) {
                                if ( this.adoptionSuspensionRec.Start_Date__c < this.adoptionSuspensionRec.End_Date__c)  {
                                    this.isOverlapped = true;
                                } else {
                                    this.isOverlapped = false;
                                    this.title ="Warning!";
                                    this.type="Warning"
                                    this.message="New suspension record end date should be greater than new start date.";
                                    this.fireToastMsg();
                                }
                                
                            } else {
                                this.isOverlapped = false;
                                this.title ="Warning!";
                                this.type="Warning"
                                this.message="New suspension record end date should be greater than old start date.";
                                this.fireToastMsg();
                            }
                        } else {
                            this.isOverlapped = true;
                        }
                    }
                } else {
    
                    this.isOverlapped = false;
                    this.title ="Warning!";
                    this.type="Warning"
                    this.message="New suspension record start date should be greater than old start date.";
                    this.fireToastMsg();
                    
                }
            }

            if(this.isOverlapped == true) {

                    this.adoptionSuspensionRec.Adoption_Case__c = this.adoptionCaseId;
                    this.isLoading = true;
                    upsertSuspensionRec({updateSuspensionRecJSON: JSON.stringify(this.checkNamespaceApplicable(this.adoptionSuspensionRec, true))})
                    .then(result => {

                        this.isLoading = false;
                        this.showSuspensionModal = false;
                        this.getSuspensionintiInfo();
                        this.title ="Success!";
                        this.type="success"
                        this.message="Suspension Created Successfully"
                        this.fireToastMsg();
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

             
        } else  {

            this.title ="Error!";
            this.type="error"
            this.message="Please complete the requried field(s)"
            this.fireToastMsg();
        }
    }

    handleAddSuspension() {

        if(this.annualReviewRec.Annual_Review_Approval_Status__c == 'Approved' && (this.suspensionList.length <= 0 || this.suspensionList[0].Adoption_Suspension_Approval_Status__c == 'Approved')) {

             //this.isLoading = true;
            this.adoptionSuspensionRec = {};
            this.readOnly=false;
            this.showSuspensionModal = true;

        } else if(this.annualReviewRec.Annual_Review_Approval_Status__c != 'Approved') {

            this.title ="Error!";
            this.type="error"
            this.message="Current Annual Review approval must be complete to create Suspension"
            this.fireToastMsg();

        }else if(this.suspensionList.length && this.suspensionList[0].Adoption_Suspension_Approval_Status__c != 'Approved') {

            this.title ="Error!";
            this.type="error"
            this.message="Current Suspension Record Approval must be complete to create new Suspension"
            this.fireToastMsg();
        }
           
    }

    closeSuspensionhModal(event) {

        //this.isLoading = false;
        this.showSuspensionModal = false;
    }
    
    handleRowAction(event) {

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            case 'show_details':
                this.showRowDetails(row);
                break;
            case 'edit':
                this.showEditDetails(row);
                break;
        }
    }

    showEditDetails(row) {

        this.showUpdateBtn=true;
        this.adoptionSuspensionRec = row;
        this.readOnly=false;
        this.showSuspensionModal = true;
        
    }

    showRowDetails(row) {

        this.readOnly=true;
        this.adoptionSuspensionRec = row;
        this.showSuspensionModal = true;
        
    }

    deleteRow(row) {
       

        const { id } = row;
        const index = this.findRowIndexById(id);
        if (index !== -1) {
            this.suspensionList = this.suspensionList
                .slice(0, index)
                .concat(this.suspensionList.slice(index + 1));
        }
                   
        deleteSuspensionRec({delSuspensionRecJSON:JSON.stringify(row)})
        .then(res=>{

            this.title ="Success!";
            this.type = "SUCCESS";
            this.message="Suspension Record deleted succesfully.";
            this.fireToastMsg();
            this.getSuspensionintiInfo();
            
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

    }

    findRowIndexById(id) {
        let ret = -1;
        this.suspensionList.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }

    handleSubmitForApproval() {

        if(this.adoptionSuspensionRec.Adoption_Suspension_Approval_Status__c == 'Approved') {

            this.title ="Error!";
            this.type = "Error";
            this.message="Suspension Record already Approved";
            this.fireToastMsg();
        } else if(this.adoptionSuspensionRec.Adoption_Suspension_Approval_Status__c == 'Submitted') {

            this.title ="Error!";
            this.type = "Error";
            this.message="Suspension Record already Submitted for approval";
            this.fireToastMsg();
        } else if(this.adoptionSuspensionRec.Adoption_Suspension_Approval_Status__c != 'Approved') {

            this.handleSave();
            setTimeout(() => {
                this.submit();
            }, 2000);
        }
                  
    }

    submit() {

        if( this.showSuspensionModal == false) {
            this.showApprovalScreen = true;
        }
               
    }

    handleSelectRec(event) {

        this.supervisorId = event.detail.recordId;
        this.enableSubmit = this.supervisorId?false:true;
    }

    submitApproval() {

        this.isLoading = true;
        onSubmitSuspensionApprovalProcess({suspensionId:this.adoptionSuspensionRec.Id,selectedSupervisorUserId:this.supervisorId})
        .then(result => {

            this.showApprovalScreen = false;
            this.isLoading = false;
            this.title = "Success!";
            this.type = "success";
            this.message = "Suspension Record Submitted for Approval Successfully";
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

    hideApprovalScreen() {
        this.showApprovalScreen = false;
    }


}