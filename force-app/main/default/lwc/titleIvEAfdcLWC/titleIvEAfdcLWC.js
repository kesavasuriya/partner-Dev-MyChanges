import { LightningElement, track, api } from 'lwc';
//import getPlacement from '@salesforce/apex/TitleIvEController.getPlacementRec';
import getIncomes from '@salesforce/apex/TitleIvEController.getIncomeSummaries';
import updateIncomeSummary from '@salesforce/apex/TitleIvEController.updateIncomeSummaryRec';
import delIncomeSummary from '@salesforce/apex/TitleIvEController.deleteIncomeSummaryRec';
import getDeprivationRec from '@salesforce/apex/TitleIvEController.getDeprivationRecord';
import getPickvalue from '@salesforce/apex/TitleIvEController.getDeprivationPicklist';
import upsertDeprivationRec from '@salesforce/apex/TitleIvEController.upsertDeprivationRecord';
import deleteDeprivationRec from '@salesforce/apex/TitleIvEController.deleteDeprivationRecord';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { deleteRecord } from 'lightning/uiRecordApi';

const actions =[
    
    {label: 'Edit', name: 'edit'},
    {label: 'Delete', name: 'delete'}
   ];

const deprivationTable= [{label: 'Parent', fieldName: 'childName', type: 'string', wrapText: true},
{label: 'Child Deprived of Parental Support', fieldName: 'Child_deprived_of_parental_support__c', type: 'string', wrapText: true},
{label: 'Deprivation Factor', fieldName: 'Deprivation_factor__c', type: 'string', wrapText: true},
{label: 'Reason for Absence', fieldName: 'Reason_for_absence__c', type: 'string', wrapText: true},
{label: 'Date of Parent Death', fieldName: 'Date_of_parent_death__c', type: 'date', wrapText: true, typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"}},
{label: 'Incarceration Date', fieldName: 'Incarceration_date__c', type:'date',typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"}},
{ type: 'action', typeAttributes: { rowActions: actions} }
];


export default class TitleIvEAfdcLWC extends NavigationMixin(UtilityBaseElement) {


    title;
    deprivationTable = deprivationTable;
    @track placementRec;
    @track titleIVEIncomeList = [];
    @track titleIVEDeprivationList = [];
    @track showPersonIncomeModal = false;
    @api contactId;
    @track loading = false;
    @api titleIvERec;
    @track IsAlien;
    showSaveButton = false;
    @track deprivationPicklist;
    @track upsertDeprivation = {};
    @track index = 0;
    @track deleteDeprivationRec = {};
    inAuPicklist = [];
    @track showIncomeButtons = false;
    @track defaultValues;
    @track showDeprivationModal =false;
    @track deprivationId='';
    @track deprivationRecord={};
    @track showPopover=false;
    @track personId;

    get showDeathofParentDate() {
        if(this.deprivationRecord.Deprivation_factor__c =='Death of Either Parent') {
            return true;
        } else {
            return false;
        }
    }
    get showIncarcerationDate() {
        if(this.deprivationRecord.Reason_for_absence__c =='Incarceration') {
            return true;
        } else {
            return false;
        }
    }

   connectedCallback() {
    this.doInit();

    }

    doInit() {
        this.loading = true;
        if (this.titleIvERec.Child_Removal__r.Child__r.Alien_Status__c || this.titleIvERec.Child_Removal__r.Child__r.Allien_Registartion_Number__c) {
            this.IsAlien = 'Yes';
        } else {
            this.IsAlien = 'No';

        }

        getIncomes({ titleIVEId: this.titleIvERec.Id}).then(result => {
                this.titleIVEIncomeList = this.checkNamespaceApplicable(JSON.parse(result).incomeSummaryList, false);
                this.inAuPicklist = JSON.parse(result).inAu;

                getPickvalue({titleiveId : this.titleIvERec.Id}).then(result => {
                    this.deprivationPicklist = JSON.parse(result);
                    for(let i=0; i<this.deprivationPicklist.parentPicklist.length;i++) {
                        this.deprivationPicklist.parentPicklist[i].label = this.deprivationPicklist.parentPicklist[i].Person__r.Name;
                        this.deprivationPicklist.parentPicklist[i].value = this.deprivationPicklist.parentPicklist[i].Person__c;
                    }
                    this.getDeprivationRec()
                    this.loading = false;
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
                        this.loading = false;
                        this.message = errorMsg;
                        this.fireToastMsg();
                    })

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
                    this.loading = false;
                    this.message = errorMsg;
                    this.fireToastMsg();
                })
    }

    getDeprivationRec() {

        getDeprivationRec({ titleIVEId: this.titleIvERec.Id }).then(result => {
            this.titleIVEDeprivationList = this.checkNamespaceApplicable(JSON.parse(result), false);
            for(let i=0;i<this.titleIVEDeprivationList.length;i++){
                this.titleIVEDeprivationList[i].childName = this.titleIVEDeprivationList[i].Parent__r.Name;
                if (this.titleIVEDeprivationList[i].Deprivation_factor__c != 'Death of Either Parent') {
                    this.titleIVEDeprivationList[i].Date_of_parent_death__c = 'Not Applicable';
                }
                if(this.titleIVEDeprivationList[i].Reason_for_absence__c != 'Incarceration') {
                    this.titleIVEDeprivationList[i].Incarceration_date__c = 'Not Applicable';
                }
            }

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
            this.loading = false;
            this.message = errorMsg;
            this.fireToastMsg();
        })
    }


    handleIconAction(event) {

        this.loading = true;
        let childPersonId = event.target.dataset.childid;
        this.contactId = childPersonId;
        let actionValue = event.target.name;
        
        switch (actionValue) {
            case 'action':             
            
            this.showPopover = true;
            this.loading = false;
                break;
            case 'delete':
                let incomeSummaryId = event.target.dataset.incomeid;
                let foundelement = this.titleIVEIncomeList.find(ele => ele.Id == incomeSummaryId);

                if (foundelement) {
                    delIncomeSummary({ contactId: childPersonId}).then(result => {
                            let rows = this.titleIVEIncomeList;
                            const rowIndex = rows.indexOf(foundelement);
                            this.titleIVEIncomeList = rows;
                            this.loading = false;
                            this.title = "Success!";
                            this.type = "success";
                            this.message = "Income summary record deleted successfully.";
                            this.fireToastMsg();
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

                } else {
                    this.loading = false;
                    this.title = "Error!";
                    this.type = "error";
                    this.message = 'Something went wrong to record delete';
                    this.fireToastMsg();
                }

                break;
        }
    }

    handleChildCmp(event) {
        this.showPersonIncomeModal = event.detail;
    }

    onToastEvent(type, toastTitle, msg) {

        const toastEvent = new ShowToastEvent({
            variant: type,
            title: toastTitle,
            message: msg,
        });
        return toastEvent;
    }
    

    handleIncomeChange(event) {

        let index = event.target.dataset.index;
        this.showIncomeButtons = true
        if (event.target.type == 'checkbox' && event.target.name == 'Is_income_deemed__c')  {
            this.titleIVEIncomeList[index].Is_income_deemed__c = event.target.checked;
        } else if(event.target.type == 'checkbox' && event.target.name == 'Disregard__c') {
            this.titleIVEIncomeList[index].Disregard__c = event.target.checked;
        } else {
            this.titleIVEIncomeList[index].In_AU__c = event.target.value;
        }


    }
    handleCancel() {

        this.showIncomeButtons = false;
    }
    handleIncomeSave() {
        
        updateIncomeSummary({incomeSummaryRec : JSON.stringify(this.checkNamespaceApplicable(this.titleIVEIncomeList, true))})
        .then(result => {
            this.showIncomeButtons = false;
            this.title = "Success!";
            this.type = "success";
            this.message = 'Record Update Sucessfully';
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
            this.loading = false;
            this.message = errorMsg;
            this.fireToastMsg();
        })

    }
    closeDeprivationModal() {
        this.showDeprivationModal = false;
    }
    handleRowAction(event) {

        let deprivationRec = event.detail.row;
        switch(event.detail.action.name) {
            case 'edit':
                var index = this.titleIVEDeprivationList.map(item => item.Id).indexOf(deprivationRec.Id);
                this.deprivationRecord = this.titleIVEDeprivationList[index];
                this.deprivationId = this.deprivationRecord.Id;
                this.showDeprivationModal = true;
                break;
            case 'delete':
                this.handleDelete(event.detail.row);
                break;
        }
       

    }
    handleDeprivationChange(event) {
        this.deprivationRecord[event.currentTarget.dataset.field] = event.target.value;
    }
    handleCreate(){
        this.deprivationRecord.Parent__c='';
        this.deprivationId='';
        this.showDeprivationModal = true;
    }
    handleSubmit(event) {
        event.preventDefault();
        if(!this.onValidate()) { 
        const fields = event.detail.fields;
        fields.Title_Iv_E__c = this.titleIvERec.Id;
        fields.Parent__c = this.deprivationRecord.Parent__c;
        this.template
            .querySelector('lightning-record-edit-form').submit(fields);
            this.showDeprivationModal = false;
            this.deprivationId ='';
        } else {

            this.title = "Error!";
            this.type = "error";
            this.message = "Required fields are missing"; 
            this.fireToastMsg();
        }
    }

    handleSuccess(){

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record updated successfully!';
        this.fireToastMsg();
        this.doInit();

    }

    closeShowPopover() {
        
        this.showPopover=false;
    }

    handleAdd(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.contactId,
                objectApiName: 'Contact',
                relationshipApiName: event.target.name,
                actionName: 'view'
            }
        });
    }

    handlePersonNavigate() {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.titleIvERec.Child_Removal__r.Child__c,
                actionName: 'view'
            },
        });
    }

    handleDelete(row) {

        deleteRecord(row.Id)
                    .then(() => {
                        this.type = 'success';
                        this.title = 'Success!';
                        this.message = 'Record Deleted Successfully!';
                        this.fireToastMsg();
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
    }
}