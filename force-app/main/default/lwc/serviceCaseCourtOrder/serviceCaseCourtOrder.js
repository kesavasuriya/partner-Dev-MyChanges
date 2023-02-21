import { LightningElement, wire, track, api } from 'lwc';
import getInitInfo from '@salesforce/apex/CourtHearingController.getInitInfos';
import getpickListValue from '@salesforce/apex/CourtOrderController.getPickList';
import getCourtOrderRecord from '@salesforce/apex/CourtOrderController.getCourtOrderRecord';
import upsertCourtOrder from '@salesforce/apex/CourtOrderController.upsertCourtOrderRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import COURT_ORDER_REFRESH_CHANNEL from '@salesforce/messageChannel/courtOrderRefreshChannel__c';
import {  MessageContext, subscribe} from 'lightning/messageService';

import UtilityBaseElement from 'c/utilityBaseLwc';
export default class ServiceCaseCourtOrder extends UtilityBaseElement {
    @wire(MessageContext)context;
    @track courtOrderList = [];
    @api recordId;
    @track showCourtOrder = false;
    @track Childspermanencyplancontinues = [];
    @track HearingOutcome = [];
    @track RemovalEpisode = [];
    @track CourtOrderRecord = {};
    @track createCourtOrder = {};
    @track courtOrderComments = {};
    @track hearingDetails = {};
    @track isLoading = false;
    @track readOnly = false;
    @track loadingTable = false;
    otherClientName;
    @api device ='';
    @track lst = [];
    @track visibleData = [];
    showChild = false;
    @track hearingOutcomelistvalue = [];
    hearingdateTime = '';
    @track hearingdatetimeMap;
    connectedCallback() {
        //this.device = FORM_FACTOR;
        this.doInitInfo();
            subscribe(this.context,COURT_ORDER_REFRESH_CHANNEL,(message) => {
                this.doInitInfo();
            });
        }
        doInitInfo() {
        
            this.showChild = false;       
            getpickListValue()
                .then(result => {
                    this.Childspermanencyplancontinues = JSON.parse(result).Childspermanencyplancontinues;
                    this.HearingOutcome = JSON.parse(result).HearingOutcome;
                    this.RemovalEpisode = JSON.parse(result).RemovalEpisode;
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
        
        getInitInfo({ recordId: this.recordId })
            .then(result => {
                let res = JSON.parse(result);
                if (res.courtOrderLists.length != null) {
                    //this.lst = [];
                    this.courtOrderList = this.checkNamespaceApplicable(res.courtOrderLists, false);
                    //res.courtOrderLists = this.lst;
                }
                this.hearingdatetimeMap= res.formatteddateTime;
                this.showChild = true;
                this.loadingTable = false;
            }).catch(error => {

                this.loadingTable = false;
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

    handleClick(event) {

        let rowId = event.currentTarget.getAttribute('data-name');
        let foundCourtElement = this.courtOrderList.find(ele => ele.Id == rowId);
        this.showCourtOrder = true;
        this.createCourtOrder.Id = foundCourtElement.Court__c;
        this.hearingDetails = foundCourtElement;
        if(this.hearingDetails.Hearing_Date_and_Time__c) {
            this.hearingdateTime = '';
            this.hearingdateTime = moment(this.hearingdatetimeMap[foundCourtElement.Id]).format('MM/DD/YYYY hh:mm A');
            
        }
       // let newYork = moment.tz(this.hearingDetails.Hearing_Date_and_Time__c, "America/Los_Angeles").format('MM-DD-YYYY, h:mm a');
        getCourtOrderRecord({ CourtOrderId: this.createCourtOrder.Id })
            .then(result => {
                this.hearingOutcomelistvalue = [];
                this.CourtOrderRecord = this.checkNamespaceApplicable(result, false);
                if (this.CourtOrderRecord.Hearing_Outcome__c != null) {
                    this.hearingOutcomelistvalue = this.CourtOrderRecord.Hearing_Outcome__c.split(';');
                }

                if (this.CourtOrderRecord.Other_Client_named_on_Petition__c) {
                    this.otherClientName = this.CourtOrderRecord.Other_Client_named_on_Petition__r.Name;
                }
                this.showCourtOrder = true;
                this.isLoading = false;
            }).catch(error => {

                this.showCourtOrder = true;
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
    handleService(event) {
        
        let fieldName = event.target.name;
        let checkedfields = event.target.checked;
        let Value = event.target.value;
        let fieldType = event.target.type;
        this.courtOrderComments[fieldName] = false;
        if (fieldType != 'checkbox' && fieldName != 'Hearing_Outcome__c') {
            this.createCourtOrder[fieldName] = Value;

        } else if (fieldType == 'checkbox') {
            this.createCourtOrder[fieldName] = checkedfields;
            this.courtOrderComments[fieldName] = checkedfields;

        } else if (fieldName == 'Hearing_Outcome__c') {

            let multiHearingValues = Value.join(';');
            this.createCourtOrder[fieldName] = multiHearingValues;
        }
    }

    closeCourtOrderModal() {

        this.showCourtOrder = false;
    }

    saveRecord() {
        upsertCourtOrder({ CourtOrderRecords: JSON.stringify(this.checkNamespaceApplicable(this.createCourtOrder, true)) })
            .then(result => {
                const toastMsg = 'Record Insert Successfuly';
                const event = this.onToastEvent('success', 'Success!', toastMsg);
                this.dispatchEvent(event);
                this.showCourtOrder = false;
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
    }
    onToastEvent(type, toastTitle, msg) {

        const toastEvent = new ShowToastEvent({
            variant: type,
            title: toastTitle,
            message: msg,
        });
        return toastEvent;
    }

    handleEdit(event) {

        this.readOnly = false;
        this.handleClick(event);

    }

    handleView(event) {

        this.readOnly = true;
        this.handleClick(event);

    }
    paginationHandler(event) {

        this.visibleData = [...event.detail.records];
    }

}