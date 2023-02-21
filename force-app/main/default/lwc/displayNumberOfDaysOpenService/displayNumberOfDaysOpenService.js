import { LightningElement, api, track } from 'lwc';
import getServiceInfo from '@salesforce/apex/ServiceCaseController.getServicecaseRecord';
import getChildRemoval from '@salesforce/apex/ServiceCaseController.getChildRemovalRecord';
import getPlacement from '@salesforce/apex/ServiceCaseController.getPlacementRecord';
import getUserAccessInfo from '@salesforce/apex/ServiceCaseController.checkUserHasAccess';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class DisplayNumberOfDaysOpenService extends NavigationMixin(UtilityBaseElement) {
    
    @api recordId;
    @api objectApiName;
    contactChannel = '/event/Refresh_Service_Case__e';
    subscription = {};
    @track servicecaseIns={};
    serviceCaseApprover={};
    intakeRecord={};
    reviewer;
    worker;
    @track hoh;
    numberOfDays; 
    startDate;
    openedDate='';
    familyWorker='';
    administrativeWorker='';
    childWorker='';
    Status;
    @track isClosed = true;
    closeDate;
    buttonLabel;
    modalMsg;
    showValidateModal = false;
    showIntakeNavigation = false;


    connectedCallback() {

        subscribe(this.contactChannel, -1, this.refreshList).then(response => {
            this.subscription = response;
            console.log('subscribed',this.subscription);
        });
        onError(error => {});
       this.doInit();

    }

    refreshList = (res) => {
        console.log('refreshList=====');
        this.doInit();

    }
    doInit() {

        if(this.objectApiName == 'Service_Case__c') {
            this.doInitInfo(this.recordId);
        
        } else if(this.objectApiName == 'Placement__c'){
            getPlacement({placementId : this.recordId})
            .then(result=>{
                this.doInitInfo(result);
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
        } else {
            getChildRemoval({childRemovalId : this.recordId})
            .then(result=>{
                this.doInitInfo(result);
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

    }

    doInitInfo(id) {

        getServiceInfo({ServicecaseId: id})
        .then(result =>{
            let res = JSON.parse(result);
            this.servicecaseIns = this.checkNamespaceApplicable(res.serviceCaseRecord, false);
            if(this.servicecaseIns.Restrict_Unrestrict__c == null) {
                this.servicecaseIns.Restrict_Unrestrict__c = 'Restrict';
            }
            this.buttonLabel = this.servicecaseIns.Restrict_Unrestrict__c;
            this.startDate = res.startDate;
            this.familyWorker = res.familyWorker;
            this.administrativeWorker = res.administrativeWorker;
            this.childWorker = res.childWorker;
            //this.openedDate = openDate.getMonth()+'/'+openDate.getDate()+'/'+openDate.getFullYear();
            this.openedDate = this.startDate.substring(0,10);
            //this.servicecaseIns.Close_Date__c = window.moment.tz(this.servicecaseIns.Close_Date__c).format('MM/DD/YYYY');
            this.closeDate = res.closeDate;

            if(this.servicecaseIns.Intake__c) {
                this.showIntakeNavigation = true;
                this.intakeRecord = this.servicecaseIns.Intake__r;
            }
            this.reviewer = this.servicecaseIns.Owner.Name;
            /*if(this.servicecaseIns.Intake__r.Supervisor_Approver__r.Name) {
                this.reviewer=this.servicecaseIns.Intake__r.Supervisor_Approver__r.Name;
            }*/
            if(this.servicecaseIns.Head_of_Household__c && this.servicecaseIns.Head_of_Household__r.Name) {
                this.hoh=this.servicecaseIns.Head_of_Household__r.Name;
            }
                this.numberOfDays= this.servicecaseIns.Number_of_days__c;
                this.Status = res.status;
            if(res.status == 'Close') {
                this.isClosed = true;
            } else {
                this.isClosed = false;
            }

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

    handleMouseOver() {

        if(this.buttonLabel == 'Restrict') {
            this.buttonLabel = 'Unrestrict';
        } else if(this.buttonLabel == 'Unrestrict'){
            this.buttonLabel = 'Restrict';
        }
    }

    handleMouseOut() {
        this.buttonLabel = this.servicecaseIns.Restrict_Unrestrict__c;
    }

    handleRestrictClick() {

        getUserAccessInfo({ recordId: this.recordId}).then(result => {

            if(result) {
                
                const fields = {};
                fields.Id = this.recordId;
                if(this.servicecaseIns.Restrict_Unrestrict__c == 'Restrict') {
                    fields.Restrict_Unrestrict__c = 'Unrestrict';
                } else if(this.servicecaseIns.Restrict_Unrestrict__c == 'Unrestrict'){
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

    handleIntakeNavigate() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.servicecaseIns.Intake__c,
                actionName: 'view'
            }
        });
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