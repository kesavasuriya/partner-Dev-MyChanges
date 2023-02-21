import { LightningElement,api,track,wire } from 'lwc';
import getRecord from '@salesforce/apex/RelatedListController.getRecords';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

const fields = ['Id', 'Name', 'Current_Address__c','Address_Line_2__c','Address_Line_1__c','City__c','County__c','State__c','ZipCode__c','Start_Date__c'];
const queryDetail = {
    fieldValue: fields,
    objectApiName: 'Contact_Address__c',
    filterValue: 'Contact__c='
};

const actions = [{ label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

const columns = 
[
    // { label: 'Address Name', fieldName: 'name', type: 'string', wrapText: false },
   
   { label: 'Address Name', type: 'button', wrapText: true, typeAttributes: { label: { fieldName: 'address'},name: 'edit',variant:'base'}  },
   { label: 'Current Address', fieldName: 'Current_Address__c',  wrapText: true,type: 'boolean' },
   { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date', wrapText: true,typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
   { label: 'End  Date', fieldName: 'End_Date__c', type: 'date', wrapText: true,typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { type: 'action', typeAttributes: { rowActions: actions } }
];
export default class AddressLwc extends UtilityBaseElement {

    @api recordId;
    @api objectApiName;
    @track addressRecord ={};
    @track addressRecordList = [];
    @track response = [];
    @track showTable= false;
    @track addressId='';
    columns = columns;
    @track showAddressModal = false;

    @track queryDetails = JSON.stringify(queryDetail);
    @wire(getRecord, { recordId: '$recordId', queryDetails: '$queryDetails' })
    relateRecords(response) {
        this.response = response;
        if (response.data) {
            this.addressRecordList = JSON.parse(JSON.stringify(response.data));
            for(let i=0;i<this.addressRecordList.length;i++) {
                if( this.addressRecordList[i].Address_Line_1__c) {
                    this.addressRecordList[i].street = this.addressRecordList[i].Address_Line_1__c;
                }
                if( this.addressRecordList[i].Address_Line_2__c) {
                    this.addressRecordList[i].street +=" "+this.addressRecordList[i].Address_Line_2__c;
                }

            }
        

        } else if (response.error) {
            console.log(response.error);
            this.loading = false;
            this.title = "Error!";
            this.type = "error";
            this.message = response.error;
            this.fireToastMsg();
        }
    }


    addressInputChange(event) {

        this.addressRecord.Address_Line_1__c = event.target.street;
        this.addressRecord.City__c =  event.target.city;
        this.addressRecord.State__c = event.target.province;
        this.addressRecord.County__c = event.target.country;
        this.addressRecord.ZipCode__c = event.target.postalCode;
    }

    handleSubmit(event) {
        
        let fields = event.detail.fields;
        event.preventDefault();
        console.log('recordId======',this.recordId);
        fields.Contact__c = this.recordId;
        fields.Address_Line_1__c =  this.addressRecord.Address_Line_1__c;
        fields.City__c = this.addressRecord.City__c;
        fields.State__c = this.addressRecord.State__c;
        fields.County__c = this.addressRecord.County__c;
        fields.ZipCode__c = this.addressRecord.ZipCode__c;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

handleSuccess(event) {

        this.title = 'Success!';
        this.type = 'success';
        this.message = 'Record Action Successfully';
        this.fireToastMsg();
        this.showAddressModal = false;
        this.addressRecord = {};
        this.addressId = '';
        refreshApex(this.response);
    }

    handleError(event) {

        this.title = "Error!";
        this.type = "error";
        this.message = event.detail.detail;
        this.fireToastMsg();
    }

handleAddAddress(event) {

    this.addressRecord = {};
    this.addressId = '';
    this.showAddressModal = true;

}

closeAddressModal(event) {
    this.showAddressModal = false;
    this.addressRecord = {};
    this.addressId = '';
}

handleRowAction(event) {
    let action = event.currentTarget.dataset.action;
        let recId = event.currentTarget.dataset.id;
        let index = event.currentTarget.dataset.rownumber;
        switch (action) {
            case 'edit':
                this.addressId = recId;
                this.addressRecord = this.addressRecordList[index];
                this.showAddressModal = true;
                break;
             
            case 'delete':
                deleteRecord(recId)
                    .then(() => {
                        this.type = 'success';
                        this.title = 'Success!';
                        this.message = 'Record Deleted Successfully!';
                        this.fireToastMsg();
                        refreshApex(this.response);

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
    this.addressRecord[event.target.name] = event.target.value;
}
}