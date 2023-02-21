import { LightningElement, track, api } from 'lwc';
import getInit from '@salesforce/apex/ContactMeetingController.getMeetingInfo';
import { NavigationMixin } from 'lightning/navigation';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { deleteRecord } from 'lightning/uiRecordApi';

const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];

const columns = [

    { label: 'Type of meeting', fieldName: 'Type_of_the_Meeting__c', type: 'text', wrapText: 'true' },
    { label: 'Date of meeting', fieldName: 'Date_of_Meeting__c', type: 'date', typeAttributes: { month: "numeric", year: "numeric", day: "numeric", timeZone: "UTC" } },
    { label: 'Child name', fieldName: 'childNames', type: 'text', wrapText: 'true' },
    { label: 'Meeting outcome/Decision', fieldName: 'Meeting_Decision__c', type: 'text', wrapText: 'true' },
    { type: 'action', typeAttributes: { rowActions: actions } }
];


export default class ContactMeetingLwc extends NavigationMixin(UtilityBaseElement) {

    @api recordId;
    @api objectApiName;
    @track meetingId = '';
    columns = columns;
    showMeetingModal = false;
    @track meetingRecord = {};
    childFamilyMembers = [];
    @track meetingList = [];
    @track childFamilyMembersValue;
    @track loading = false;
    displayDate;
    isValid

    get showdate() {
        if (this.meetingRecord.Follow_up_Meeting__c == 'Yes') {
            return true;
        } else {
            return false;
        }
    }

    get showType() {
        if (this.meetingRecord.Type_of_the_Meeting__c == 'FIM') {
            return true;
        } else {
            return false;
        }
    }

    get showRecordPageComponent() {
        if (this.recordId != null && this.objectApiName == 'Meeting__c') {
            this.meetingId = this.recordId;
            return true;
        } else {
            return false;
        }
    }

    get meetingTitle() {
        if (this.meetingList) {
            return 'Meeting (' + this.meetingList.length + ')';
        } else {
            return 'Meeting';
        }
    }

    get showTable() {
        if (this.meetingList.length) {
            return true;
        } else {
            return false;
        }
    }

    connectedCallback() {

        this.loading = true;
        this.doInit();
    }

    doInit() {

        getInit({ recordId: this.recordId, objectName: this.objectApiName })
            .then(result => {
                let res = JSON.parse(result);
                this.childFamilyMembers = res.childFamilyMembers;

                if (res.meetings != null && res.meetings.length > 0) {
                    this.meetingList = [];
                    this.meetingList = this.checkNamespaceApplicable(res.meetings, false);
                }
                if (res.meetingRecord != null) {
                    this.meetingRecord = res.meetingRecord;
                    if (res.meetingRecord.Select_Child_Family_Member__c != null) {
                        this.childFamilyMembersValue = res.meetingRecord.Select_Child_Family_Member__c.split(';');
                    }

                }
                this.loading = false;

            }).catch(error => {
                this.loading = false;
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




    openMeetingModal() {

        this.meetingRecord = {};
        this.showMeetingModal = true;

    }

    closeMeetingModal() {
        this.showMeetingModal = false;
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'edit':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        objectApiName: 'Meeting__c',
                        actionName: 'view'
                    },
                });
                break;

            case 'delete':
                deleteRecord(row.Id)
                    .then(() => {
                        this.type = 'success';
                        this.title = 'Success!';
                        this.message = 'Record Deleted Successfully!';
                        this.fireToastMsg();
                        this.loading = true;
                        this.doInit();
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
                break;
        };

    }


    handleChange(event) {

        let value = event.target.value;
        let personvalue;
        let fieldName = event.currentTarget.dataset.field;
        if (event.target.name == 'Select_Child_Family_Member__c') {
            personvalue = value.join(';');
            this.meetingRecord[event.target.name] = personvalue;
        } else if (fieldName) {
            this.meetingRecord[fieldName] = value;
        } else {
            this.meetingRecord[event.target.name] = value;
        }
    }

    onFormValidate() {

        this.isValid = this.onRequiredValidate();        
    }

    handleSubmit(event) {

        event.preventDefault();
        const fields = event.detail.fields;
        if (this.isValid) {
            if (this.objectApiName == 'Case') {
                fields.Intake__c = this.recordId;
            } else {
                fields[this.objectApiName] = this.recordId;
            }
            fields.Select_Child_Family_Member__c = this.meetingRecord.Select_Child_Family_Member__c;
            fields.Date_of_Meeting__c = this.meetingRecord.Date_of_Meeting__c;
            fields.Follow_up_meeting_Start_date__c = this.meetingRecord.Follow_up_meeting_Start_date__c;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }

    handleSuccess() {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Metting record created/updated successfully';
        this.fireToastMsg();
        this.showMeetingModal = false;
        this.doInit();

    }

    handleError(event) {

        this.title = "Error!";
        this.type = "error";
        this.message = event.detail.detail;
        this.fireToastMsg();
    }

}