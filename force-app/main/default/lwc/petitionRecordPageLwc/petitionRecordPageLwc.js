import { LightningElement, wire, track, api } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { getRecord } from 'lightning/uiRecordApi';
import getInitiInfo from '@salesforce/apex/CourtController.getInitialInfos';

const FIELDS = ['Court__c.Type_of_Petition__c', 'Court__c.Service_Case__c', 'Court__c.Petition_for_Child__c', 'Court__c.Child_s_Attorney__c',
    'Court__c.Petition_Date__c', 'Court__c.Date_Request_Completed__c', 'Court__c.The_person_s_with_Legacy_Custody_is__c', 'Court__c.Other_Client_named_on_Petition__c',
    'Court__c.Child_in_Shelter_Care_on__c', 'Court__c.Resonable_Date__c', 'Court__c.The_person_s_whom_has_had_Physical__c', 'Court__c.Parent_1_Name__c',
    'Court__c.Removal_Date__c', 'Court__c.Date_of_Emergency_Shelter_Care__c', 'Court__c.Parent_2_Name__c'
];

export default class PetitionRecordPageLwc extends UtilityBaseElement {

    @api objectApiName;
    @api recordId;
    @track petitionRecord = {};
    petitionforChild = [];
    otherclientName = [];
    childAttorneyPicklist = [];
    parentNamePicklist = [];
    isValid;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {

            this.title = "Error!";
            this.type = "error";
            this.message = error;
            this.fireToastMsg();

        } else if (data) {
            this.petitionRecord.Type_of_Petition__c = data.fields.Type_of_Petition__c.value;
            this.petitionRecord.Petition_Date__c = data.fields.Petition_Date__c.value;
            this.petitionRecord.Date_Request_Completed__c = data.fields.Date_Request_Completed__c.value;
            this.petitionRecord.Child_in_Shelter_Care_on__c = data.fields.Child_in_Shelter_Care_on__c.value;
            this.petitionRecord.Resonable_Date__c = data.fields.Resonable_Date__c.value;
            this.petitionRecord.Removal_Date__c = data.fields.Removal_Date__c.value;
            this.petitionRecord.Petition_for_Child__c = data.fields.Petition_for_Child__c.value;
            this.petitionRecord.Child_s_Attorney__c = data.fields.Child_s_Attorney__c.value;
            this.petitionRecord.The_person_s_with_Legacy_Custody_is__c = data.fields.The_person_s_with_Legacy_Custody_is__c.value;
            this.petitionRecord.The_person_s_whom_has_had_Physical__c = data.fields.The_person_s_whom_has_had_Physical__c.value;
            this.petitionRecord.Parent_1_Name__c = data.fields.Parent_1_Name__c.value;
            this.petitionRecord.Parent_2_Name__c = data.fields.Parent_2_Name__c.value;
            this.petitionRecord.The_person_s_with_Legacy_Custody_is__c = data.fields.The_person_s_with_Legacy_Custody_is__c.value;
            this.petitionRecord.Other_Client_named_on_Petition__c = data.fields.Other_Client_named_on_Petition__c.value;
            this.petitionRecord.Date_of_Emergency_Shelter_Care__c = data.fields.Date_of_Emergency_Shelter_Care__c.value;
        }
    }

    get showCINACMP() {

        if (this.petitionRecord.Type_of_Petition__c == 'CINA') {
            return true;
        } else {
            return false;
        }

    }

    connectedCallback() {
        getInitiInfo({ recordId: this.recordId })
            .then(result => {
                let res = JSON.parse(result);
                console.log('res:::',res);
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
        this.message = 'Record Updated Successfully';
        this.fireToastMsg();

    }

    handleError(event) {

        this.title = "Error!";
        this.type = "error";
        this.message = event.detail.detail;
        this.fireToastMsg();
    }


}