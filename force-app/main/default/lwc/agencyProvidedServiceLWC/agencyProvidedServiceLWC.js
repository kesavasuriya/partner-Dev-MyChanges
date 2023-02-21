import { LightningElement,track,api } from 'lwc';
import getClient from '@salesforce/apex/VendorService.getClient';
import createService from '@salesforce/apex/VendorService.createService';
import getAllService from '@salesforce/apex/VendorService.getAllAgencyService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteService from '@salesforce/apex/VendorService.deleteService';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import formatfordate from '@salesforce/resourceUrl/formatfordate';
import TIME_ZONE from '@salesforce/i18n/timeZone';

import UtilityBaseElement from 'c/utilityBaseLwc';

const actions = [
    { label: 'Edit', name: 'edit'},
    { label: 'Delete', name: 'delete' }
];

const columns = [
    { label: 'Client Program', fieldName: 'Client_Program_Name__c', type: 'string'},
    { label: 'Service', fieldName: 'AgencyServices__c', type: 'string'},
    { label: 'Frequency', fieldName: 'Frequency__c', type: 'string' },
    { label: 'Duration', fieldName: 'Duration__c', type: 'string' },
    { label: 'Actual Begin Date', fieldName: 'Actual_Begin_DateTime__c', type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone : TIME_ZONE}},
    { label: 'Actual End Date', fieldName: 'Actual_End_DateTime__c',type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone : TIME_ZONE}},
    { label: 'Notes', fieldName: 'Notes__c', type: 'string'},
    {  type: 'action', typeAttributes: { rowActions: actions} }
    
];

export default class AgencyProvidedServiceLWC extends UtilityBaseElement{

    @api recordId;
    @track columns = [];
    @track details = {};
    @track service = {};
    @track serviceEdit = {};
    @track serviceEdit2 = {};
    @track serviceRec = {};
    @track namelist = [];
    @track clientProgramName = [];
    @track editclientProgramName = [];
    @track action = [];
    @track duration = [];
    @track frequency = [];
    @track name = [];
    @track agencyService = [];
    @track serviceList = [];
    showModalAddNewService = false;
    showModalEditNewService = false;
    loading = false;
    showdelete = false;
    hideAddNewServiceButton = true;
    showtable=false;
    deleteId;
    @track visibleData = [];
    showChild = false;
    timezone = TIME_ZONE;


    connectedCallback() {

        Promise.all([
            loadScript(this, momentForTime),loadScript(this, formatfordate)
        ]).then(()=> {
            this.doInit();
            
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

    doInit() {

        this.columns = columns;
        let id = this.recordId;
        getClient({clientId:id})
        .then(result => {
            this.namelist = JSON.parse(result).contactList ;
            this.action = JSON.parse(result).actionPicklist;
            this.duration = JSON.parse(result).durationPicklist;
            this.frequency = JSON.parse(result).frequencyPicklist;
            this.agencyService = JSON.parse(result).agencyServicePicklist;
            this.name = JSON.parse(result).contactPicklist;
        
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
        
        this.getServices(); 

    }

    getServices() {
        this.loading = true;
        this.showChild = false;
        getAllService({serviceId:this.recordId})
        .then(result => {

            if(result != null || result.length > 0) {

                this.serviceList = this.checkNamespaceApplicable(JSON.parse(result),false);
                /*for( let i = 0; i < this.serviceList.length; i++) {
                    this.serviceList[i].clientDob = moment.tz(this.serviceList[i].Client__r.Date_of_Birth__c ,this.timezone).format('MM/DD/YYYY');
                }*/
                this.showChild = true;
            } else {
                this.serviceList = [];
            }
            
            this.loading = false;
        }).catch(error => {

            this.loading = false;
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

        this.hideAddNewServiceButton = false;
        let value = event.target.value;
        for(let i=0;i<this.namelist.length;i++) {
            if(this.namelist[i].Id == value) {

                this.namelist[i]=this.checkNamespaceApplicable(this.namelist[i],false);
                this.details.clientid = this.namelist[i].Casevault_PID__c;
                this.details.DOB =  this.namelist[i].Date_of_Birth__c;
                //this.details.DOB =  moment.tz(this.namelist[i].Date_of_Birth__c,this.timezone).format('MM/DD/YYYY');
                this.details.gender = this.namelist[i].Gender__c;
                this.details.age = this.namelist[i].Age__c;
                this.details.id = this.namelist[i].Id;
                this.details.name = this.namelist[i].Name;
                this.details.clientProgram = this.namelist[i].Program_Area__c;
            }
        }
        this.clientProgramName = [
            {label : this.details.clientProgram,
            value : this.details.clientProgram}
        ];
    }

    showAddNewService() {

        this.showModalAddNewService = true;
        this.service = {};
    }

    handleCancel() {
        this.showModalAddNewService = false;
    }

    handleSave() {

        this.service.Client__c = this.details.id;
        this.service.Type__c = 'Agency Provided Services';
        if(!this.onValidate()) { 
            this.loading = true;
            createService({serviceJSON : JSON.stringify(this.checkNamespaceApplicable(this.service,true))})
            .then(result =>{
                this.showModalAddNewService = false;
                this.loading = false;
                const evt = new ShowToastEvent({
                    title : 'Success',
                    message : 'Service Created',
                    variant : 'success',
                    mode : 'dismissable'
                });
                this.dispatchEvent(evt);
                this.getServices();
            }).catch(error => {

                this.loading = false;
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
        }  else {
       
            const evt1 = new ShowToastEvent({
                title : 'Error',
                message : 'Required fields are missing',
                variant : 'error',
                mode : 'dismissable'

            });
            this.dispatchEvent(evt1);
        }

    }

    onValidate(){
        const allValid = [
            ...this.template.querySelectorAll("lightning-input"),...this.template.querySelectorAll("lightning-combobox"),...this.template.querySelectorAll("lightning-textarea")
            ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
            }, true);
            return !allValid;
    }

    handleService(event) {

        this.service[event.target.name] = event.target.value;
        
    }

    handleEditService(event) {

        this.serviceEdit2[event.target.name] = event.target.value;
    }

    handleRowAction(event) {

        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'edit': 
            this.serviceEdit = row;
            this.serviceEdit2.Id = this.serviceEdit.Id;
            this.editclientProgramName = [
                {label : this.serviceEdit.Client_Program_Name__c,
                value : this.serviceEdit.Client_Program_Name__c}
            ];
            this.showModalEditNewService = true;
            break;

            case 'delete':
                this.handleDelete(row);
                break;
        }
    }

    handleUpdate() {

        if(!this.onValidate()) { 

            this.loading = true;
            createService({serviceJSON : JSON.stringify(this.checkNamespaceApplicable(this.serviceEdit2,true))})
            .then(result =>{
                this.showModalEditNewService = false;
                this.loading = false;
                const evt = new ShowToastEvent({
                    title : 'Success',
                    message : 'Service Updated',
                    variant : 'success',
                    mode : 'dismissable'
                });
                this.dispatchEvent(evt);
                this.getServices();
            }).catch(error => {

                this.loading = false;
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
        
            const evt1 = new ShowToastEvent({
                title : 'Error',
                message : 'Required fields are missing',
                variant : 'error',
                mode : 'dismissable'

            });
            this.dispatchEvent(evt1);
        }
    }

    hideModalEditNewService() {

        this.showModalEditNewService = false;
    }

    handleDelete(serviceRec) {

        this.showdelete = true;
        this.deleteId = serviceRec.Id;
    }

    hideDelete() {
        this.showdelete = false;
    }

    handleDeleteService() {

        deleteService({serviceId : this.deleteId})
        .then(result =>{
            this.showdelete = false;
            const evt = new ShowToastEvent({
                title : 'Success',
                message : 'Service Deleted',
                variant : 'success',
                mode : 'dismissable'
            });
            this.dispatchEvent(evt);
            this.getServices();
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

    paginationHandler(event) {

        this.visibleData = [...event.detail.records];     
    }
}