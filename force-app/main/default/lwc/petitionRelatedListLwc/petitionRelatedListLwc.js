import { LightningElement, api, track, wire } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getRecord from '@salesforce/apex/RelatedListController.getRecords';
import getInitiInfo from '@salesforce/apex/CourtController.getInitialInfos';
import { refreshApex } from '@salesforce/apex';

const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];

const fields = ['Id', 'Name', 'Type_of_Petition__c', 'Name_of_LDSS_Attorney__c', 'Court_Petition_ID__c'];

const columns = [
    { label: 'Client Name', fieldName: 'recurl', type: 'url', target: '_self', wrapText: true, typeAttributes: { label: { fieldName: 'Name' } } },
    { label: 'Type of Petition', fieldName: 'Type_of_Petition__c', type: 'text', wrapText: true },
    { label: 'LDSS Attorney', fieldName: 'Name_of_LDSS_Attorney__c', type: 'text', wrapText: true },
    { label: 'Court Petition ID', fieldName: 'Court_Petition_ID__c', type: 'text', wrapText: true },
    { type: 'action', typeAttributes: { rowActions: actions } }

];


export default class PetitionRelatedListLwc extends NavigationMixin(UtilityBaseElement) {

    columns = columns;
    @api recordId;
    @api objectApiName;
    showModal = false;
    petitionId = '';
    @track petitionRecList = [];
    @track petitionRecord = {};
    @track fields = fields;
    rowIndex = 0;
    response = [];
    petitionforChild = [];
    otherclientName = [];
    childAttorneyPicklist = [];
    parentNamePicklist = [];
    @track loading = false;
    @track queryDetail = {
        fieldValue: fields,
        objectApiName: 'Court__c',
        whereField: 'Type__c=\'' + 'Petition' + '\'',
    };
    isValid;
    @track queryDetails = JSON.stringify(this.queryDetail);

    @wire(getRecord, { recordId: '$recordId', queryDetails: '$queryDetails' })
    relateRecords(response) {
        this.loading = true;
        this.response = response;
        if (response.data) {
            let recordList = [];
            for (let i = 0; i < response.data.length; i++) {
                let rec = {};
                rec.Name = response.data[i].Name;
                rec.recurl = '/lightning/r/' + response.data[i].Id + '/view';
                rec.Id = response.data[i].Id;
                rec.Type_of_Petition__c = response.data[i].Type_of_Petition__c;
                rec.Name_of_LDSS_Attorney__c = response.data[i].Name_of_LDSS_Attorney__c;
                rec.Court_Petition_ID__c = response.data[i].Court_Petition_ID__c;
                recordList.push(rec);
            }
            this.petitionRecList = recordList;
            this.loading = false;

        } else if (response.error) {
            this.loading = false;
            this.title = "Error!";
            this.type = "error";
            this.message = response.error;
            this.fireToastMsg();
        }
    }


    get showCINACMP() {

        if (this.petitionRecord.Type_of_Petition__c == 'CINA') {
            return true;
        } else {
            return false;
        }
    }

    get petitionTitle() {
        if (this.petitionRecList) {
            return 'Petition (' + this.petitionRecList.length + ')';
        } else {
            return 'Petition';
        }
    }
    get showTable() {
        if (this.petitionRecList.length) {
            return true;
        } else {
            return false;
        }
    }

    handleNew(event) {
        this.showModal = true;

    }
    closeModal() {
        this.showModal = false;
    }

    connectedCallback() {
        getInitiInfo({ recordId: this.recordId })
            .then(result => {
                let res = JSON.parse(result);
                this.petitionforChild = res.petitionForChildPicklist;
                this.otherclientName = res.otherClientsNamedOnPetitionPicklist;
                this.childAttorneyPicklist = res.childAttorneyPicklist;
                this.parentNamePicklist = res.parentNamePicklist;
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



    handleChange(event) {

        let fieldName = event.currentTarget.dataset.field;
        let Value = event.target.value;
        if (fieldName) {
            this.petitionRecord[fieldName] = Value;
        } else {
            this.petitionRecord[event.target.name] = Value;
        }


    }

    onFormValidate() {

        this.isValid = this.onRequiredValidate();        
    }

    handleSubmit(event) {

        event.preventDefault();
        if(this.isValid) {
            const fields = event.detail.fields;
            if (this.objectApiName == 'Case') {
                fields.Intake__c = this.recordId;
            } else {
                fields[this.objectApiName] = this.recordId;
            }
            fields.Type__c = 'Petition';
            fields.Type_of_Petition__c = this.petitionRecord.Type_of_Petition__c;
            fields.Petition_Date__c = this.petitionRecord.Petition_Date__c;
            fields.Date_Request_Completed__c = this.petitionRecord.Date_Request_Completed__c;
            fields.Child_in_Shelter_Care_on__c = this.petitionRecord.Child_in_Shelter_Care_on__c;
            fields.Resonable_Date__c = this.petitionRecord.Resonable_Date__c;
            fields.Removal_Date__c = this.petitionRecord.Removal_Date__c;
            fields.Date_of_Emergency_Shelter_Care__c = this.petitionRecord.Date_of_Emergency_Shelter_Care__c;
            fields.Petition_for_Child__c = this.petitionRecord.Petition_for_Child__c;
            fields.Child_s_Attorney__c = this.petitionRecord.Child_s_Attorney__c;
            fields.Other_Client_named_on_Petition__c = this.petitionRecord.Other_Client_named_on_Petition__c;
            fields.The_person_s_with_Legacy_Custody_is__c = this.petitionRecord.The_person_s_with_Legacy_Custody_is__c;
            fields.The_person_s_whom_has_had_Physical__c = this.petitionRecord.The_person_s_whom_has_had_Physical__c;
            fields.Parent_1_Name__c = this.petitionRecord.Parent_1_Name__c;
            fields.Parent_2_Name__c = this.petitionRecord.Parent_2_Name__c;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }

    handleSuccess(event) {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record Created Successfully';
        this.fireToastMsg();
        this.showModal = false;
        refreshApex(this.response);
        this.loading = false;

    }

    handleError(event) {

        this.title = "Error!";
        this.type = "error";
        this.message = event.detail.detail;
        this.fireToastMsg();
        this.loading = false;
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
                        objectApiName: 'Court__c',
                        actionName: 'view'
                    }
                })

                break;

            case 'delete':
                this.loading = true;
                this.handleDeleteRec(row);
                break;
        }
    }

    handleDeleteRec(row) {

        deleteRecord(row.Id)
            .then(() => {
                this.type = 'success';
                this.title = 'Success!';
                this.message = 'Record Deleted Successfully!';
                this.fireToastMsg();
                refreshApex(this.response);
                this.loading = false;

            })
            .catch(error => {

                let errorMsg;
                this.loading = false;
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



}