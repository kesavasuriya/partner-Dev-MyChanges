import { LightningElement, track, api, wire } from 'lwc';
import getProviders from '@salesforce/apex/PlacementController.fetchAccount';

import { deleteRecord } from 'lightning/uiRecordApi';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getRecords from '@salesforce/apex/RelatedListController.getRecords';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';

const columns = [
    { label: 'PROVIDER ID', fieldName: 'Casevault_ProID__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' } },
    { label: 'PROVIDER NAME', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'VACANCY', fieldName: 'Number_of_Beds__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' } },
    { label: 'PLACEMENT STRUCTURE', fieldName: 'Placement_Service__c', type: 'text', sortable: true },
    { label: 'PROVIDER CATEGORY', fieldName: 'Type__c', type: 'text', sortable: true }
];

const actions = [
    { label: 'View', name: 'view' },
    { label: 'Delete', name: 'delete' }
];

const fields = ['Id', 'Provider__r.Name', 'Provider__c', 'Provider__r.Casevault_ProID__c', 'Relationship_to_Child__c', 'Importance_to_Child__c'];

const emotionalTilescolumns = [
    { label: 'Provider Id', fieldName: 'ProviderId', type: 'text', wrapText: true },
    { label: 'Name', fieldName: 'ProviderName', type: 'text', wrapText: true },
    { label: 'Relation to child', fieldName: 'Relationship_to_Child__c', type: 'text', wrapText: true },
    { label: 'Importance to child', fieldName: 'Importance_to_Child__c', type: 'text', wrapText: true },
    { type: 'action', typeAttributes: { rowActions: actions } }

];

const FIELDS = ['Permanency_Plan__c.Adoption_Planning_Stage__c'];

const queryDetail = {
    fieldValue: fields,
    filterValue: 'Permanency_Plan__c =',
    objectApiName: 'Emotional_tie__c'

}

export default class PermanencyPlanEmotionalTiles extends NavigationMixin(UtilityBaseElement) {

    @api permanencyRecId;
    loading = false;
    showAddEmotionalTies = false;
    @track emotionalTiesRec = {};
    showSearchProvider = false;
    @track searchInput = {};
    @track providerList = [];
    showProviderList = false;
    columns = columns;
    @track selectedProvider = {};
    @track emotionalTiesList = [];
    readOnly = false;
    @track nextStage = false;
    disabledButton = false;

    refreshdata = [];
    emotionalTilescolumns = emotionalTilescolumns;
    queryDetail = JSON.stringify(queryDetail);

    @wire(getRecords, { recordId: '$permanencyRecId', queryDetails: '$queryDetail' })
    relateRecords(response) {
        this.refreshdata = response;
        if (response.data) {
            let records = [];
            for (let i = 0; i < response.data.length; i++) {
                let record = {};
                if (response.data[i].Provider__c) {
                    record.ProviderId = response.data[i].Provider__r.Casevault_ProID__c;
                    record.ProviderName = response.data[i].Provider__r.Name;
                    record.Provider__c = response.data[i].Provider__c
                }
                record.Id = response.data[i].Id;
                record.Relationship_to_Child__c = response.data[i].Relationship_to_Child__c;
                record.Importance_to_Child__c = response.data[i].Importance_to_Child__c
                records.push(record);
            }
            this.emotionalTiesList = records;
        } else if (response.error) {
            this.title = "Error!";
            this.type = "error";
            this.message = response.error;
            this.fireToastMsg();
        }
    }

    @wire(getRecord, { recordId: '$permanencyRecId', fields: FIELDS })
    permanencyPlanRec({ error, data }) {

        if (data) {

            if (data.fields.Adoption_Planning_Stage__c.value > 2) {

                this.disabledButton = true;
            } else {

                this.disabledButton = false;
            }
        }
    }

    get showProvider() {

        if (this.emotionalTiesRec.Type__c == 'Provider') {

            return true;
        } else {

            return false;
        }
    }

    get showOther() {

        if (this.emotionalTiesRec.Type__c == 'Other') {

            return true;
        } else {

            return false;
        }
    }

    handleSaveNext() {

        this.nextStage = true;

    }

    handleModal() {

        this.readOnly = false;
        this.showAddEmotionalTies = true;
    }

    closeModal() {

        this.showAddEmotionalTies = false;
    }

    handleTypeChange(event) {

        this.emotionalTiesRec[event.currentTarget.dataset.field] = event.target.value;

    }

    handleSearchProvider(event) {

        this.showAddEmotionalTies = false;
        this.searchInput = {};
        this.showSearchProvider = true;
    }

    closeSearchProviderModal() {

        this.showSearchProvider = false;
    }

    searchHandle(event) {

        let name = event.target.name;
        let value = event.target.value;
        if (name == 'childCharacter') {

            let multiHearingValues = value.join(';');
            this.searchInput[name] = multiHearingValues;
        } else {

            this.searchInput[name] = value;
        }

    }

    handleSearch(event) {

        this.loading = true;
        getProviders({ searchInputJSON: JSON.stringify(this.searchInput) })
            .then(result => {
                if (result) {
                    this.providerList = JSON.parse(result);
                    if (this.providerList.length > 0) {
                        this.selectedProvider = {};
                        this.showSearchProvider = false;
                        this.showProviderList = true;
                    } else {
                        this.title = "Error!";
                        this.type = "error";
                        this.message = "No records are found";
                        this.fireToastMsg();
                    }
                    this.loading = false;

                }
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

    handleClear() {

        this.searchInput = {};

    }

    handleRowSelection = event => {

        var selectedRows = event.detail.selectedRows[0];
        this.selectedProvider = selectedRows;
    }

    handleBacktoSearch() {

        this.showProviderList = false;
        this.showSearchProvider = true;
    }

    handleSelectProvider() {

        this.showProviderList = false;
        this.showAddEmotionalTies = true;

    }


    handleSubmit(event) {

        event.preventDefault();
        const fields = event.detail.fields;
        if (this.selectedProvider) {

            fields.Provider__c = this.selectedProvider.Id;
        }
        fields.Permanency_Plan__c = this.permanencyRecId;
        this.template
            .querySelector('[data-name="emotionalForm"]').submit(fields);
    }

    handlePermanencyPlanSubmit(event) {

        event.preventDefault();
        const fields = event.detail.fields;
        if (this.nextStage) {

            fields.Adoption_Planning_Stage__c = '3';
        }
        this.template
            .querySelector('[data-name="permanencyForm"]').submit(fields);

    }

    handleSuccess(event) {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record Action Successfully';
        this.fireToastMsg();
        this.selectedProvider = {};
        this.showAddEmotionalTies = false;
        this.emotionalTiesRec = {};
        if (this.nextStage) {

            const adoptionStageEvent = new CustomEvent('adoptionstage');
            this.dispatchEvent(adoptionStageEvent);
        }
        refreshApex(this.refreshdata);

    }

    handleError(event) {

        this.title = "Error!";
        this.type = "error";
        this.message = event.detail.detail;
        this.fireToastMsg();

    }

    handleRowAction(event) {

        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'view':

                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        objectApiName: 'Emotional_tie__c',
                        actionName: 'view'
                    },
                });
                break;

            case 'delete':
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
                refreshApex(this.refreshdata);

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

    handlespeech(event) {
         if('speechSynthesis' in window)
        {
            var speech = new window.SpeechSynthesisUtterance(event.target.value);
            speech.lang = 'en-US';
            window.speechSynthesis.speak(speech);
        }
        else
        {
            alert('speechSynthesis not supported');
        }
        
    }



}