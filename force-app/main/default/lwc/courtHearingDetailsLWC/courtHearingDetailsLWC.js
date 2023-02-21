import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveHearingRec from '@salesforce/apex/CourtHearingController.createScheduledHearingRec';
import getInitInfo from '@salesforce/apex/CourtHearingController.getInitInfos';
import getHearingClients from '@salesforce/apex/CourtHearingController.getHearingClientsInfos';
import createCourtCaseNumber from '@salesforce/apex/CourtHearingController.createCourtCaseRec';
import getSelectCourtCaseNo from '@salesforce/apex/CourtHearingController.getSelectCourtCaseNumberRec'
import deleteCourtCaseNo from '@salesforce/apex/CourtHearingController.deleteCourtCaseNumberRec';
import getHearingDetails from '@salesforce/apex/CourtHearingController.getHearingEditRec';
import upsertHearingDetailsRec from '@salesforce/apex/CourtHearingController.upsertHearingRecord';
import REFRESH_CHANNEL from '@salesforce/messageChannel/courtHearingRefreshChannel__c';
import COURT_ORDER_REFRESH_CHANNEL from '@salesforce/messageChannel/courtOrderRefreshChannel__c';
import {  MessageContext, subscribe, publish} from 'lightning/messageService';

import UtilityBaseElement from 'c/utilityBaseLwc';
export default class CourtHearingDetailsLWC extends UtilityBaseElement{

    @wire(MessageContext)context;
    @track hearingRec = {};
    @track showHearingModal = false;
    showClientsTable = false;
    showPetitionClient = false;
    @api recordId;
    @track isLoading=false;
    @track hearingTypeList = [];
    @track hearingScheduledList = [];
    @track petitionIdList = [];
    ShowHearingTable = false;
    @track petitionHeaingClient;
    @track otherHearingClients = [];
    @track showCourtCaseNumberModal = false;
    addCaseNumber = false;
    @track clientPickList = [];
    @track courtCaseNumber = {};
    @track showHearingEditModal=false;
    @track courtCaseNumberList = [];
    hearingStatusList;
    stateList;
    countryList;
    petitionType;
    @track updateEdit={};
    @track getHearingEditRec={};
    @track lst = [];
    hearintypelistvalue=[];
    @track visibleData = [];
    showChild = false;
    @track visibleData1 = [];
    showChild1 = false;
    @api objectApiName;
    scheduleNextHear = false;

    connectedCallback() {
        this.doInitInfo();
                subscribe(this.context,REFRESH_CHANNEL,(message) => {
                this.doInitInfo();
            });

    }   

    doInitInfo() {
        //this.isLoading=true;
        this.showChild = false;
        this.showChild1 = false;
        getInitInfo({recordId :this.recordId})
        .then(result => {
            let res = JSON.parse(result);
            if(res.petitionHearingList) {
                this.hearingScheduledList = this.checkNamespaceApplicable(res.petitionHearingList,false);
            }
            
            this.showChild = true;
            this.petitionIdList = res.hearingPetitionIdList;
            this.hearingTypeList = res.scheduledHearingTypePicklist;
            this.courtCaseNumberList = this.checkNamespaceApplicable(res.courtCaseNumberList,false);
            this.showChild1 = true;
            this.hearingStatusList=res.hearingStatus;
            this.stateList=res.states;
            this.countryList=res.country;
            this.isLoading=false;
            this.hearingTypeList.splice(0, 1);
            if(res.petitionHearingList) {
                this.ShowHearingTable = true;
            }
            this.clientPickList = res.clientPickList;
         }).catch(error => {

           this.isLoading=false;
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
        
        let fieldName = event.target.name;     
        let Value = event.target.value;
        if (fieldName != 'Scheduled_Hearing_Type__c') {

            this.hearingRec[fieldName] =  Value;
            if (fieldName == 'Court__c' && Value) {
                getHearingClients({courtId : Value}).then(result => {
                    let res = this.checkNamespaceApplicable(JSON.parse(result),false);
                    
                    this.petitionHeaingClient = res.clientName;
                    let clientNames = res.otherClientNames;
                    if(res.otherClientNames) {
                        let clientList = res.otherClientNames.split(';');
                        this.otherHearingClients = []; // Set initially empty array
                        clientList.forEach(element => {
                            this.otherHearingClients.push({
                                clientName: element,
                                courtCaseNumber: 'Other'               
                            });
                        });
                        this.showPetitionClient = this.petitionHeaingClient? true: false;
                        this.showClientsTable = this.otherHearingClients? true: false;

                    }
                    
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
            } else {
                this.petitionHeaingClient = '';
                this.otherHearingClients = [];
                this.showPetitionClient = false;
                this.showClientsTable = false;
            }
            
        } else {

            let multiHearingValues = Value.join(';');
            this.hearingRec[fieldName] =  multiHearingValues;
        }
    }

    handleDualBoxChange(event) {

        let fieldName = event.target.name;     
        let Value = event.target.value;
    }

    handleCourtCaseNumberChange(event) {    

        let name = event.target.name;     
        let value = event.target.value;
        //this.courtCaseNumber[fieldName] = value;
        this.courtCaseNumber[name] = value;

    }

    showHearingDetail(event) {

        this.showHearingModal = true;
    }

    showCourtCaseNumber(event) {
        this.showCourtCaseNumberModal = true;
    }
    addCourtCaseNumber(event) {
        this.addCaseNumber = true;
    }
    closeModal(event) {
        this.addCaseNumber = false;
        this.showHearingModal = false;
        this.showCourtCaseNumberModal = false;
        this.showHearingEditModal=false;
    }

    clearHearingDetail(event) {

        this.hearingRec = {};
        this.petitionHeaingClient = '';
        this.otherHearingClients = [];
        this.showPetitionClient = false;
        this.showClientsTable = false;
    }

    addHearingDetail(event) {
        
        if(!this.onValidate()) {
            this.hearingRec.Hearing_Status__c='Scheduled';
            saveHearingRec({hearingRecJSON : JSON.stringify(this.checkNamespaceApplicable(this.hearingRec,true))}).then(result => {
                const toastMsg = 'Scheduled record added succesfully.';
                const event = this.onToastEvent('success', 'Success!', toastMsg);
                this.dispatchEvent(event); 
                this.doInitInfo();
                this.showHearingModal = false;
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
            this.showHearingModal = false;
        } else {
            const event = this.onToastEvent('error', 'Error!', 'Complete the required field(s).');
            this.dispatchEvent(event);

        }    
    }

    onValidate() {

        const allValid = [
            ...this.template.querySelectorAll("lightning-input"),
            ...this.template.querySelectorAll("lightning-combobox"),
            ...this.template.querySelectorAll("lightning-textarea"),
            ...this.template.querySelectorAll("lightning-dual-listbox")
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
    handleSaveCaseNumber (event) {
        this.courtCaseNumber[this.objectApiName] = this.recordId;
        createCourtCaseNumber({courtCaseNumberRecJSON :JSON.stringify(this.checkNamespaceApplicable(this.courtCaseNumber,true))}).then(res =>{
        const toastMsg = 'Case Number added succesfully.';
        const event = this.onToastEvent('success', 'Success!', toastMsg);
        this.dispatchEvent(event);
        this.addCaseNumber = false;
        this.doInitInfo();
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
    showEditModal(event){
        this.showHearingEditModal=true;
        let recIdEdit=event.currentTarget.getAttribute('data-name');
        this.updateEdit.Id=recIdEdit;
        getHearingDetails({recId:recIdEdit})
        .then(result => {
        
            //this.lst = this.checkNamespaceApplicable(result,false);
            this.getHearingEditRec=this.checkNamespaceApplicable(result,false);
            this.petitionType=this.checkNamespaceApplicable(result,false).Court__r.Type_of_Petition__c;

            //this.hearintypelistvalue=(result.Scheduled_Hearing_Type__c).replace(';',',');
            this.hearintypelistvalue =this.checkNamespaceApplicable(result,false).Scheduled_Hearing_Type__c.split(';');
            


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

    handleCaseNumberEdit(event) {
        let courtcasenoId = event.target.dataset.name;
        getSelectCourtCaseNo({courtId:courtcasenoId}).then(res=>{
            this.addCaseNumber = true;
            this.lst =[];
            //this.lst = this.checkNamespaceApplicable(res,false);
            this.courtCaseNumber = this.checkNamespaceApplicable(res,false);
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

    handleCaseNumberDelete(event) {
        let rows = this.courtCaseNumberList;
        const rowIndex = rows.indexOf(event.target.dataset.name);
        rows.splice(rowIndex, 1);
        this.courtCaseNumberList = rows;
                   
        deleteCourtCaseNo({courtRec:event.target.dataset.name}).then(res=>{
            const toastMsg = 'Case Number Record deleted succesfully.';
            const event = this.onToastEvent('success', 'Success!', toastMsg);
            this.dispatchEvent(event);
            this.doInitInfo();
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
    handleEdit(event){

        let fieldName = event.target.name;
        let checkedfields = event.target.checked;
        let Value = event.target.value;
        let fieldType = event.target.type;
        if(fieldType != 'checkbox' && fieldName !='Scheduled_Hearing_Type__c' ){
            this.updateEdit[fieldName] =  Value;

        }
        else if(fieldType == 'checkbox'){
            this.updateEdit[fieldName] = checkedfields;
        }
        else if(fieldName == 'Scheduled_Hearing_Type__c'){
            /*for(let i=0;i<(event.target.value).length;i++){
                this.updateEdit[fieldName]=event.target.value[i]+',';
            }*/
            let multiHearingValues = Value.join(';');
            this.updateEdit[fieldName] =  multiHearingValues;
        }
        if(fieldName == 'Hearing_Status__c') {
            if (Value == 'Scheduled' || Value == 'Continued - Hearing in Progress' || Value == 'Continued - Without a Hearing' || Value == 'Postponed' || Value == 'Contested Hearing') {
                this.scheduleNextHear = true;
            } else {
                this.scheduleNextHear = false;
            }
        }

    }
    updateHearingRec(){
        upsertHearingDetailsRec({hearingDetailRecords:JSON.stringify(this.checkNamespaceApplicable(this.updateEdit,true))})
        .then(result =>{
            const toastMsg = 'Hearing Detail Record Updated succesfully.';
            const event = this.onToastEvent('success', 'Success!', toastMsg);
            this.dispatchEvent(event);
            this.showHearingEditModal=false;
            this.doInitInfo();
            const payload = {
                recordName : '',
            };
            publish(this.context,COURT_ORDER_REFRESH_CHANNEL,payload);
        })
        .catch(error => {

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
    paginationHandler(event) {

        this.visibleData = [...event.detail.records];     
    }
    paginationHandler1(event) {

        this.visibleData1 = [...event.detail.records];     
    }
}