import { LightningElement, wire, track, api } from 'lwc';
import getInitInfo from '@salesforce/apex/CourtTabController.getInitInfos';
import createCourtCaseNumber from '@salesforce/apex/CourtTabController.createCourtCaseRec';
import getCourtOrderRecord from '@salesforce/apex/CourtTabController.getCourtOrderRecord';
import getpickListValue from '@salesforce/apex/CourtTabController.getPickList';
import upsertCourtOrder from '@salesforce/apex/CourtTabController.upsertCourtOrderRecord';
import { deleteRecord } from 'lightning/uiRecordApi';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import { createRecord } from 'lightning/uiRecordApi';


import { NavigationMixin } from 'lightning/navigation';

import UtilityBaseElement from 'c/utilityBaseLwc';

const actions = [
    { label: 'View', name: 'view' },
    { label: 'Edit', name: 'edit' },
    { label: 'File upload', name: 'fileUpload'}
];

const columns = [
    { label: 'Client Name', fieldName: 'clientName', type: 'text', wrapText: true },
    { label: 'Court Petition ID', fieldName: 'CourtPetition_Id__c', type: 'text', wrapText: true },
    { label: 'Scheduled Hearing Type', fieldName: 'Scheduled_Hearing_Type__c', type: 'text', wrapText: true },
    { label: 'Hearing Date/Time', fieldName: 'Hearing_Date_and_Time__c', type: 'date',typeAttributes:{day:"numeric",month:"numeric",year:"numeric",hour:"numeric",minute:"numeric",hour12:"true",timeZone : TIME_ZONE} },
    { label: 'Hearing Status', fieldName: 'Hearing_Status__c', type: 'text', wrapText: true },
    { label: 'Hearing Notes', fieldName: 'Hearing_Notes__c', type: 'text', wrapText: true },
    { type: 'action', typeAttributes: { rowActions: actions } }
];

export default class hearingDetailsandCourtOrderTab extends NavigationMixin(UtilityBaseElement) {

    subscription = {};
    CHANNEL_NAME = '/data/Court__ChangeEvent';
    columns = columns;
    @api recordId;
    @track concludedRecords = [];
    @track scheduledRecords = [];
    @track visibleData = [];
    @track visibleData1 = [];
    @track showHearingModal = false;
    @track showCourtCaseNumberModal = false;
    @track addCaseNumber = false;
    @track courtCaseNumber = {};
    @track courtCaseNumberList = [];
    @track showHearingEditModal = false;
    @track clientPickList = [];
    @track hearingId = '';
    @api objectApiName;
    @track showCourtOrder = false;
    @track readOnly = false;
    @track CourtOrderRecord = {};
    @track courtOrderComments = {};
    hearingOutcomelistvalue = [];
    otherClientName;
    createCourtOrder = {};
    @track Childspermanencyplancontinues = [];
    @track RemovalEpisode = [];
    @track HearingOutcome = [];
    petitionIdList = [];
    @track courtId;
    @track nextScheduleHearingRecord ={};

    get showDateTime() {
        if(this.nextScheduleHearingRecord.Is_There_Another_Court_Hearing_Scheduled__c == true) {
            return true;
        } else {
            return false;
        }
    }

    get showNextScheduleHearing() {
        if(this.nextScheduleHearingRecord.Hearing_Status__c == 'Concluded') {
            return true;
        } else {
            return false;
        }
    }

    connectedCallback() {

        subscribe(this.CHANNEL_NAME, -1, this.refreshList).then(response => {
            this.subscription = response;
        });

        onError(error => { });

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

        this.doInitInfo();
    }

    refreshList = () => {

        this.doInitInfo();

    }


    doInitInfo() {

        getInitInfo({ recordId: this.recordId })
            .then(result => {
                let res = JSON.parse(result);
                this.clientPickList = res.clientPickList;
                this.courtCaseNumberList = this.checkNamespaceApplicable(res.courtCaseNumberList, false);
                this.petitionIdList = res.hearingPetitionIdList;

                if (res.concludedRecords) {

                    this.concludedRecords = this.checkNamespaceApplicable(res.concludedRecords, false);
                    for(let i = 0; i < this.concludedRecords.length; i++) {
                        if(this.concludedRecords[i].Court__c != null && this.concludedRecords[i].Court__r.Petition_for_Child__c != null) {
                            this.concludedRecords[i].clientName = this.concludedRecords[i].Court__r.Petition_for_Child__r.Name;
                        }
                    }
                }
                if (res.scheduledRecords) {

                    this.scheduledRecords = this.checkNamespaceApplicable(res.scheduledRecords, false);
                }
            })


    }

    showHearingDetail() {

        this.showHearingModal = true;
    }

    closeHearingModal() {

        this.showHearingModal = false;
    }


    handleAddHearingSuccess(event) {

        this.title = 'Success!';
        this.type = 'success';
        this.message = 'Hearing Added Successfully!';
        this.fireToastMsg();
        this.doInitInfo();
        this.showHearingModal = false;
    }

    showCourtCaseNumber() {

        this.showCourtCaseNumberModal = true;
    }

    closeCourtModal() {

        this.showCourtCaseNumberModal = false;
        this.addCaseNumber = false;
    }

    addCourtCaseNumber() {

        this.addCaseNumber = true;
        this.courtCaseNumber = {};
    }

    handleCourtCaseNumberChange(event) {

        let name = event.target.name;
        let value = event.target.value;
        this.courtCaseNumber[name] = value;

    }

    handleSaveCaseNumber(event) {

        this.courtCaseNumber[this.objectApiName] = this.recordId;
        createCourtCaseNumber({ courtCaseNumberRecJSON: JSON.stringify(this.checkNamespaceApplicable(this.courtCaseNumber, true)) }).then(res => {
            this.message = 'Record Created Successfully!';
            this.title = 'Success!';
            this.type = 'success';
            this.fireToastMsg();
            this.addCaseNumber = false;
            this.doInitInfo();
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

    showEditModal(event) {

        this.hearingId = event.currentTarget.getAttribute('data-name');
        this.showHearingEditModal = true;
    }

    closeEditModal() {

        this.showHearingEditModal = false;
    }

    handleEditHearingSuccess(event) {

        this.message = 'Record Created Successfully!';
        this.title = 'Success!';
        this.type = 'success';
        this.fireToastMsg();
        this.doInitInfo()
        if (event.detail.fields.Hearing_Status__c.value == 'Concluded') {
            this.handleClick(event.detail.fields.Court__c.value);

        }
        this.showHearingEditModal = false;
    }

    handleClick(rowId) {

        this.showCourtOrder = true;
        this.createCourtOrder.Id = rowId;
        getCourtOrderRecord({ CourtOrderId: rowId })
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


    closeCourtOrderModal() {

        this.showCourtOrder = false;
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

    saveRecord() {
        upsertCourtOrder({ CourtOrderRecords: JSON.stringify(this.checkNamespaceApplicable(this.createCourtOrder, true)) })
            .then(result => {
                this.title = "Success!";
                this.type = "success";
                this.message = 'Record  updated successfully';
                this.fireToastMsg();
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

    handleCaseNumberEdit(event) {

        let index = event.target.dataset.position;
        this.addCaseNumber = true;
        this.courtCaseNumber = this.courtCaseNumberList[index];

    }

    handleCaseNumberDelete(event) {

        deleteRecord(event.target.dataset.name)
            .then(() => {
                this.title = 'Success!';
                this.type = 'success';
                this.message = 'Record deleted successfully!';
                this.fireToastMsg();

                let rows = this.courtCaseNumberList;
                const rowIndex = rows.indexOf(event.target.dataset.name);
                rows.splice(rowIndex, 1);
                this.courtCaseNumberList = rows;
            });

    }

    handleAddHearingSubmit(event) {

        event.preventDefault();
        const fields = event.detail.fields;
        if (this.courtId) {
            fields.Court__c = this.courtId;
        }
        fields.Hearing_Status__c = 'Scheduled';
        this.template.querySelector('lightning-record-edit-form').submit(fields);

    }

    handleHearingChange(event) {
        
        this.courtId = event.target.value;
    }

    handleRowAction(event) {

        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'edit':

                this.readOnly = false;
                this.handleClick(row.Court__c);
                break;

            case 'view':

                this.readOnly = true;
                this.handleClick(row.Court__c);
                break;
            
            case 'fileUpload':

                this[NavigationMixin.Navigate]({
                    type: 'standard__recordRelationshipPage',
                    attributes: {
                        recordId: row.Court__c,
                        objectApiName: 'Court__c',
                        relationshipApiName: 'AttachedContentDocuments',
                        actionName: 'view'
                    },
                });
                break;
        }
    }

    handleChange(event) {
        this.nextScheduleHearingRecord[event.currentTarget.dataset.field] = event.target.value;
    }

    handleSave() {

        let foundElement = this.scheduledRecords.find(ele => ele.Id == this.hearingId);
        if(foundElement) {
            delete this.nextScheduleHearingRecord.Is_There_Another_Court_Hearing_Scheduled__c;
            delete this.nextScheduleHearingRecord.Next_Hearing_Date_and_Time__c;
            this.nextScheduleHearingRecord.Court__c = foundElement.Court__c;
            this.nextScheduleHearingRecord.Scheduled_Hearing_Type__c = foundElement.Scheduled_Hearing_Type__c;
            this.nextScheduleHearingRecord.Hearing_Status__c = 'Scheduled';
            var fields = this.nextScheduleHearingRecord;
            var objectRecordInput = {'apiName' : 'Court_Petition_Hearing__c', fields};
            createRecord(objectRecordInput).then(response => {
                
            }).catch(error => {
                console.log('error',error);
            });


        }

    }

    handleOnLoad(event) {

        var record = event.detail.records;
        var fields = record[this.hearingId].fields;

        if (fields.Is_There_Another_Court_Hearing_Scheduled__c) {
            this.nextScheduleHearingRecord.Is_There_Another_Court_Hearing_Scheduled__c = fields.Is_There_Another_Court_Hearing_Scheduled__c.value;
        }
        if (fields.Next_Hearing_Date_and_Time__c) {
            this.nextScheduleHearingRecord.Next_Hearing_Date_and_Time__c = fields.Next_Hearing_Date_and_Time__c.value;
        }

    }
}