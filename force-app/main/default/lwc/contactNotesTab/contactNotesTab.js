import { LightningElement, api, track } from 'lwc';
import getNotesInitialInformation from '@salesforce/apex/ContactNotesController.getNotesInitialInformation';
import getpersonInvolved from '@salesforce/apex/ContactNotesController.getpersonInvolved';
import createPersonInvolved from '@salesforce/apex/ContactNotesController.createPersonInvolved';
import deleteJnRecord from '@salesforce/apex/ContactNotesController.deleteJnRecords';

import UtilityBaseElement from 'c/utilityBaseLwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';


const actions = [
    { label: 'Preview', name: 'preview' },
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
    { label: 'Quality of Care', name: 'qualityOfCare' },
    { label: 'Notes', name: 'notes' },
    { label: 'History', name: 'history' },
    { label: 'File Upload', name: 'fileUpload'}
];

const notesColumn = [{ label: 'Contact Date', fieldName: 'Contact_Date__c', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Date of Entry', fieldName: 'CreatedDate', type: 'date', typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Entered By', fieldName: 'OwnerName', type: 'text', wrapText: true },
    { label: 'Contact Purpose', fieldName: 'Contact_Purpose__c', type: 'text', wrapText: true },
    { label: 'Contact Details', fieldName: 'contactDetails', type: 'text', wrapText: true },
    /*{ label: 'Person Contacted', fieldName: 'Involved_Persons_txt__c', type: 'text', wrapText: true },*/
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    }
];

const personInvolvedActions = [
    { label: 'Delete', name: 'delete' },
];

const personInvolvedColumn = [{ label: 'Name', fieldName: 'Name'},
    {
        type: 'action',
        typeAttributes: { rowActions: personInvolvedActions },
    }
];

export default class ContactNotesTab extends NavigationMixin(UtilityBaseElement) {

    @api recordId;
    @api objectApiName;
    @track contactPersonsPick = [];
    @track notesRec = {};
    @track notesList = [];
    showNotesModal = false;
    @track personInvolvedValues = [];
    readOnly = false;
    loading = false;
    source = '';
    showTable = false;
    @track showNotesCommentModal = false;
    notesCommentVal = '';
    showQuliatyModal = false;
    @track personRoleList = [];
    @track upsertNoteRec = {};
    notesId;
    isValid;
    personInvolvedColumn = personInvolvedColumn;
    @track personInvolvedList = [];
    notes
    @track personRec = {};
    @track removedPersons = [];
    @track createPersons = [];
    @track changedPersons = [];

    get notesTitle() {
        if (this.notesList) {
            return 'Notes (' + this.notesList.length + ')';
        } else {
            return 'Notes';
        }
    }

    get showTable() {
        if (this.notesList.length) {
            return true;
        } else {
            return false;
        }
    }

    notesColumn = notesColumn;

    connectedCallback() {
        this.doInit();
    }

    doInit() {

        this.loading = true;
        this.getNotesInital();
        if (this.objectApiName == 'Case') {
            this.upsertNoteRec.Intake__c = this.recordId;
            this.source = 'Intake';
        } else if (this.objectApiName == 'Service_Case__c') {
            this.upsertNoteRec[this.objectApiName] = this.recordId;
            this.source = 'Service Case';
        } else if (this.objectApiName == 'Investigation__c') {
            this.upsertNoteRec[this.objectApiName] = this.recordId;
            this.source = 'Investigation';
        }
    }

    getNotesInital() {

        getNotesInitialInformation({ recordId: this.recordId })

        .then(res => {
            let result = JSON.parse(res);
            this.contactPersonsPick = result.involvedPersonPicklist;
            if (result.contactList) {
                this.personRoleList = result.contactList;
            }
            if (result.notesList.length > 0) {
                this.notesList = result.notesList;
                for (let i = 0; i < this.notesList.length; i++) {
                    if (this.notesList[i].Owner.Name) {
                        this.notesList[i].OwnerName = this.notesList[i].Owner.Name;
                    }
                    this.notesList[i].contactDetails = 'Type of Contact :';
                    if (this.notesList[i].Contact_Type__c) {
                        this.notesList[i].contactDetails = this.notesList[i].contactDetails + this.notesList[i].Contact_Type__c + '\n';
                    } else if (!this.notesList[i].Contact_Type__c) {
                        this.notesList[i].contactDetails = this.notesList[i].contactDetails + '\n';
                    }
                    this.notesList[i].contactDetails = this.notesList[i].contactDetails + 'Contact Location :';
                    if (this.notesList[i].Contact_Location__c) {
                        this.notesList[i].contactDetails = this.notesList[i].contactDetails + this.notesList[i].Contact_Location__c + '\n';
                    } else if (!this.notesList[i].Contact_Location__c) {
                        this.notesList[i].contactDetails = this.notesList[i].contactDetails + '\n';
                    }
                    this.notesList[i].contactDetails = this.notesList[i].contactDetails + 'Contact :';
                    if (this.notesList[i].Contact_was_Attempted_Completed__c) {
                        this.notesList[i].contactDetails = this.notesList[i].contactDetails + this.notesList[i].Contact_was_Attempted_Completed__c + '\n';
                    } else if (!this.notesList[i].Contact_was_Attempted_Completed__c) {
                        this.notesList[i].contactDetails = this.notesList[i].contactDetails + '\n';
                    }
                }
                this.showTable = true;
            } else {
                this.notesList = [];
                this.showTable = false;
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

    handleChange(event) {

        let fieldname = event.target.name;
        let value = event.target.value;
        let type = event.target.type;
        if (type != 'checkbox') {

            if (fieldname == 'Contact_Purpose__c') {
                let contactPurpose = value.join(';');
                this.upsertNoteRec[fieldname] = contactPurpose;
            } else {
                this.upsertNoteRec[fieldname] = value;
            }
        } else {
            this.upsertNoteRec[fieldname] = event.target.checked;
        }
    }

    addNewNotes() {

        this.notesRec = {};
        this.upsertNoteRec = {};
        this.personInvolvedList = [];
        this.readOnly = false;
        this.personInvolvedValues = [];
        let notesId;
        this.notesId = notesId;
        this.showNotesModal = true;
    }

    closeNotesModal() {

        this.showNotesModal = false;
        this.loading = false;
    }

    handleViewModal(row) {

        this.getPersons(row.Id);
        this.notesRec = row;
        this.notesId = row.Id;
        this.readOnly = true;
        this.showNotesModal = true;
        
    }

    handleEditModal(row) {

        this.getPersons(row.Id);
        this.notesRec = row;
        this.notesId = row.Id;
        this.upsertNoteRec.Id = row.Id;
        this.readOnly = false;
        this.showNotesModal = true;
       
    }

    handleDeleteRec(id) {

        deleteRecord(id)
        .then(() => {
            this.type = 'success';
            this.title = 'Success!';
            this.message = 'Record Deleted Successfully!';
            this.fireToastMsg();
            this.doInit();
            this.getPersons(this.notesId);
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

    showNotes(row) {

        this.notesCommentVal = row.Notes__c;
        this.showNotesCommentModal = true;
    }

    closeNotesCommentModal() {
        this.showNotesCommentModal = false
    }

    handleQualityModal(row) {

        this.notesId = row.Id;
        this.showQuliatyModal = true;
    }

    closeQualityModal() {
        this.showQuliatyModal = false;
    }

    handleRowAction(event) {

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'preview':
                this.handleViewModal(row);
                break;
            case 'edit':
                this.handleEditModal(row);
                break;
            case 'delete':
                this.handleDeleteRec(row.Id);
                break;
            case 'qualityOfCare':
                this.handleQualityModal(row);
                break;
            case 'notes':
                this.showNotes(row);
                break;
            case 'history':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordRelationshipPage',
                    attributes: {
                        recordId: row.Id,
                        objectApiName: 'Notes__c',
                        relationshipApiName: 'Notes_Histories__r',
                        actionName: 'view'
                    },
                });
                break;
            case 'fileUpload':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordRelationshipPage',
                    attributes: {
                        recordId: row.Id,
                        objectApiName: 'Notes__c',
                        relationshipApiName: 'AttachedContentDocuments',
                        actionName: 'view'
                    },
                });
                break;
            default:
        }
    }

    handleSuccess() {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record Updated Successfully';
        this.fireToastMsg();
        this.showQuliatyModal = false;
    }

    onFormValidate() {

        if(this.onRequiredValidate() && (!this.onValidate())) {
            this.isValid = true;  
        }      
    }

    handleNotesSubmit(event) {

        event.preventDefault();
        const fields = event.detail.fields;
        if (this.isValid) {            

            if (this.objectApiName == 'Case') {
                fields.Intake__c = this.recordId;
            } else if (this.objectApiName == 'Service_Case__c') {
                fields[this.objectApiName] = this.recordId;
            } else if (this.objectApiName == 'Investigation__c') {
                fields[this.objectApiName] = this.recordId;
            }
            fields.Source__c = this.source;
            if(this.upsertNoteRec.Contact_Duration__c) {
                fields.Contact_Duration__c = this.upsertNoteRec.Contact_Duration__c;
            }
            fields.Involved_Persons_txt__c = this.upsertNoteRec.Involved_Persons_txt__c;
            let setpersonrole = [];
            if (this.upsertNoteRec.Involved_Persons_txt__c) {
                let persons = this.upsertNoteRec.Involved_Persons_txt__c.split(';');
                for (let i = 0; i < this.personRoleList.length; i++) {
                    if (persons.find(element => element == this.personRoleList[i].Name)) {
                        setpersonrole.push(this.personRoleList[i].Intake_Person_Role__c);
                    }
                }
            }
            if (setpersonrole.length > 0) {
                fields.Person_Role__c = setpersonrole.join(';');
            } else {
                fields.Person_Role__c = '';
            }
            this.template.querySelector('lightning-record-edit-form').submit(fields);
       } 
    }

    handleNotesSuccess(event) {

        this.createPersons = [];
            this.removedPersons = [];
            this.showNotesModal = false;
            if(this.changedPersons.length) {
            if(this.changedPersons != null && this.personInvolvedValues != null) {
                for(let i=0; i<this.changedPersons.length;i++) {
                    let foundElement = this.personInvolvedValues.find(ele => ele == this.changedPersons[i]);                    if(!foundElement) {
                        let rec = {};
                        rec.Notes__c = event.detail.id;
                        rec.Person__c = this.changedPersons[i];
                        this.createPersons.push(rec);
                    }
                }
          
                for(let i=0; i<this.personInvolvedValues.length;i++) {
                    let foundElement = this.changedPersons.find(ele => ele == this.personInvolvedValues[i]);
                    if(!foundElement) {
                        let rec ={};
                        rec.Id =  (this.personInvolvedList.find(ele => ele.Person__c == this.personInvolvedValues[i])).Id;
                        this.removedPersons.push(rec);
                    }
                }
            createPersonInvolved({personJSON : JSON.stringify(this.createPersons)})
            .then(res=>{
                this.createPersons = [];
                this.changedPersons = [];
            
            })
            deleteJnRecord({deleteRecordJSON : JSON.stringify(this.removedPersons)})
            .then(res=>{
                this.removedPersons = [];
                this.changedPersons = [];

            })
        }
    }
        this.title = "Success!";
        this.type = "success";
        this.message = "Record saved Successfully!";
        this.fireToastMsg();
        this.getNotesInital();

       
    }

    handleEditError(event) {

        this.title = "Error!";
        this.type = "error";
        this.message = event.detail.detail;
        this.fireToastMsg();
    }

    handleTimeChange(event) {
        let fieldName = event.currentTarget.dataset.field;
        this.upsertNoteRec[fieldName] = event.target.value;
        if(fieldName == 'Start_Time__c') {
            this.upsertNoteRec[fieldName] = event.target.value;
            if(this.upsertNoteRec.End_Time__c) {
                this.upsertNoteRec.Contact_Duration__c = this.diff(this.upsertNoteRec.Start_Time__c,this.upsertNoteRec.End_Time__c)
            } else {
                this.upsertNoteRec.Contact_Duration__c = 0;
            }
        } else {
            if(this.upsertNoteRec.Start_Time__c) {
                this.upsertNoteRec.Contact_Duration__c = this.diff(this.upsertNoteRec.Start_Time__c,this.upsertNoteRec.End_Time__c)
            } else {
                 this.upsertNoteRec.Contact_Duration__c = 0;
            }
        }
    }
    

    diff(start, end) {
        start = start.split(":");
        end = end.split(":");
        var startDate = new Date(0, 0, 0, start[0], start[1], 0);
        var endDate = new Date(0, 0, 0, end[0], end[1], 0);
        var diff = endDate.getTime() - startDate.getTime();
        var hours = Math.floor(diff / 1000 / 60 / 60);
        diff -= hours * 1000 * 60 * 60;
        var minutes = Math.floor(diff / 1000 / 60);

        // If using time pickers with 24 hours format, add the below line get exact hours
        if (hours < 0)
        hours = hours + 24;

        return (hours <= 9 ? "0" : "") + hours + ":" + (minutes <= 9 ? "0" : "") + minutes;
    }


    addPerson() {
        let records = [...this.personInvolvedList];
        let foundElement = this.personInvolvedList.find(ele => ele.Person__c === this.personRec.Person__c);
        if(foundElement == null) {
            records.push(this.personRec);
            this.personInvolvedList = records;
        } else {
            this.title = 'Error!';
            this.type = 'error';
            this.message = 'The Person is Already Involved in this Meeting!';
            this.fireToastMsg();
        }
    }

    getPersons(id) {
        getpersonInvolved({notesRecId : id})
        .then(res =>{
            this.personInvolvedList = [];
            this.personInvolvedList = JSON.parse(res);
            this.personInvolvedValues = [];
            for(let i =0;i<this.personInvolvedList.length; i++) {
                this.personInvolvedValues.push(this.personInvolvedList[i].Person__c);
            }
        })
        
    }

    handlePersonChange(event) {

        this.changedPersons = event.detail.value;
       
    }
    handleNotesLoad(event) {

        if(this.notesId) {
        var record = event.detail.records;
        var fields = record[this.notesId].fields; 
        if(fields.Contact_Duration__c) {
            this.upsertNoteRec.Contact_Duration__c = fields.Contact_Duration__c.value;
        }
        if(fields.Start_Time__c.value) {
            this.upsertNoteRec.Start_Time__c = fields.Start_Time__c.value;
        }  
        if(fields.End_Time__c.value) {
            this.upsertNoteRec.End_Time__c = fields.End_Time__c.value;
        } 
    }
    }
}