import { LightningElement,api,track } from 'lwc'; 
import getClient from '@salesforce/apex/VendorService.getClient';
import getSearchList from '@salesforce/apex/VendorService.getSearchList';
import createService from '@salesforce/apex/VendorService.createService';
import getAllService from '@salesforce/apex/VendorService.getAllService';
import getService from '@salesforce/apex/VendorService.getService';
import createPurchase from '@salesforce/apex/VendorService.createPurchase';
import deleteService from '@salesforce/apex/VendorService.deleteService';
import getAllPurchaseAuthorization from '@salesforce/apex/VendorService.getAllPurchaseAuthorization';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPurchase from '@salesforce/apex/VendorService.getPurchase';
import submitSuperApproval from '@salesforce/apex/VendorService.onSubmitForApproval';
import downloadPurchaseRecord from '@salesforce/apex/VendorService.downloadPurchaseRecord';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import formatfordate from '@salesforce/resourceUrl/formatfordate';
import TIME_ZONE from '@salesforce/i18n/timeZone';


const columns = [
    { label: 'PROVIDER ID', fieldName: 'providerId' },
    { label: 'PROVIDER Name', fieldName: 'providerName' },
    { label: 'TAX ID', fieldName: 'taxID' },
    { label: 'LOCATION ADDRESS', fieldName: 'address' },
    { label: 'COUNTRY', fieldName: 'country' },
    { label: 'SERVICES', fieldName: 'Structure_Service_Name__c' }
];

const actions = [
    { label: 'Add', name: 'add'},
    { label: 'Edit', name: 'edit'},
    { label: 'Delete', name: 'delete' }
];

const columnlist = [
    { label: 'Provider ID', fieldName: 'providerId' },
    { label: 'Provider Name', fieldName: 'providerName' },
    { label: 'Service', fieldName: 'service' },
    { label: 'Purchase Authorization', type:  'button',typeAttributes: { 
        variant :'base', name : 'purchaseAuthorization',
                 label: 'Purchase Authorization' }},
    { label: 'Actual Begin Date', fieldName: 'Actual_Begin_Date__c' ,type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"}},
    { label: 'Actual End Date', fieldName: 'Actual_End_Date__c',type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"} },
    {  type: 'action', typeAttributes: { rowActions: actions} }
];

const columnlistpurchase = [
    { label: 'Authorization ID', type:  'button',typeAttributes: { 
        variant :'base', name : 'authorizationId',
                 label: {
                     fieldName : 'Name'
                 } }},
    { label: 'Fiscal Category Code', fieldName: 'Fiscal_Category_Description__c' },
    { label: 'Start Date', fieldName: 'Start_Date__c' , type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"}},
    { label: 'End Date', fieldName: 'End_Date__c' , type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"}},
    { label: 'Cost not to exceed', fieldName: 'Cost_not_be_exceed__c' },
    { label: 'Actual Amount', fieldName: 'Final_Amount__c' },
    { label: 'Status', fieldName: 'Status__c' },
    { label: 'Report', type:  'button',typeAttributes: { 
        variant :'base', name : 'report',
                 label: 'Download' }}
   
];

import UtilityBaseElement from 'c/utilityBaseLwc';
export default class VendorServicesLWC extends UtilityBaseElement{

    @api recordId;

    columns = columns;
    columnlist = columnlist;
    columnlistpurchase = columnlistpurchase;
    @track namelist=[];
    @track purchaseList=[];
    @track name = [];
    @track nameObj = {};
    @track details = {};
    @track search = {};
    @track serviceDetail = {};
    @track service = {};
    @track purchase = {};
    @track purchaseForm = {};
    @track purchaseTable = {};
    @track serviceForPurchase = {};
    @track serviceEdit = {};
    @track serviceEdit2 = {};
    @track purchaseEdit = {};
    @track showModalAddNewService = false;
    checkedValue = false;
    loading = false;
    showApprovalScreen = false;
    enableEdit = false;
    showEditServiceDetail = false;
    showdelete = false;
    hideAddNewServiceButton = true;
    showpurchaseTable = false;
    disableSave = false;
    showpurchaseListContent = false;
    SubmitterName;
    ApproverName;
    deleteId;
    @track actualBeginDate = false;
    @track showServiceDetail = false;
    @track openPurchaseAuthorizationList = false;
    @track openPurchaseAuthorizationForm = false;
    @track providers = [];
    @track serviceList = [];
    @track clientProgramName = [];
    @track editclientProgramName = [];
    @track action = [];
    @track frequency = [];
    @track duration = [];
    @track serviceEndReason = [];
    @track reasonServiceNotReceived = [];
    @track vendorServicePicklist = [];
    @track demo = [];
    @track demobj = {};
    @track fiscalCategoryCode = [];
    @track voucherRequested = [];
    supervisorId;
    enableSubmit = true;
    purchaseId;
    @track visibleData = [];
    showChild = false;
    @track visibleData1 = [];
    showChild1 = false;
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

        let id = this.recordId;
        getClient({clientId:id})
        .then(result => {
            this.namelist = this.checkNamespaceApplicable(JSON.parse(result).contactList,false) ;
            this.action = this.checkNamespaceApplicable(JSON.parse(result).actionPicklist,false);
            this.duration = this.checkNamespaceApplicable(JSON.parse(result).durationPicklist,false);
            this.frequency = this.checkNamespaceApplicable(JSON.parse(result).frequencyPicklist,false);
            this.reasonServiceNotReceived = this.checkNamespaceApplicable(JSON.parse(result).reasonServiceNotReceivedPicklist,false);
            this.serviceEndReason = this.checkNamespaceApplicable(JSON.parse(result).serviceEndReasonPicklist,false);
            this.fiscalCategoryCode = this.checkNamespaceApplicable(JSON.parse(result).fiscalCodePicklist,false);
            this.voucherRequested = this.checkNamespaceApplicable(JSON.parse(result).voucherRequestedPicklist,false);
            this.vendorServicePicklist = this.checkNamespaceApplicable(JSON.parse(result).vendorServicePicklist,false);
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
        getAllService({clientId:this.recordId})
        .then(result => {
            this.loading = false;
            if(result != null || result.length > 0) {

                this.serviceList = this.checkNamespaceApplicable(JSON.parse(result),false);
                for(let i = 0;i < this.serviceList.length; i++) {

                    this.serviceList[i].providerId = this.serviceList[i].Provider__r.Casevault_ProID__c;
                    this.serviceList[i].providerName = this.serviceList[i].Provider__r.Name;
                    this.serviceList[i].service = this.serviceList[i].Structure_Services__r.Structure_Service_Name__c;
                    
                }
                this.showChild = true;
            }
            
        }).catch(error => {

            this.loading=false;
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
                this.details.DOB = this.namelist[i].Date_of_Birth__c;
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

        this.search = {};
        this.providers = [];
        this.showModalAddNewService = true;
    }

    handleCancel() {

        this.showModalAddNewService = false;
        this.search = {};
    }

    handleSearchChange(event) {

        let name = event.target.name;
        let value = event.target.value;
        this.search[name] = value;
        
    }

    handleCheckbox(event) {

        if(event.target.checked == true) {
            this.checkedValue = true;
            this.serviceDetail = event.target.name;
        }
        else
            this.checkedValue = false;

    }

    handleSearch() {

        this.loading = true;
        if(this.search.ProviderID == null && this.search.ProviderName == null && this.search.Zipcode == null && this.search.Services == null) {
            this.providers = [];
            this.loading = false;
        }
        else {

        getSearchList({searchString:JSON.stringify(this.search)})
        .then(result =>{
            this.loading = false;
            if(JSON.parse(result).length == 0 || !(result)) {

                this.providers = [];
                const evt = new ShowToastEvent({
                    title : 'Info',
                    message : 'No records are found',
                    variant : 'info',
                    mode : 'dismissable'
    
                });
                this.dispatchEvent(evt);
            } else {
                this.providers = this.checkNamespaceApplicable(JSON.parse(result),false);
                for(let i=0;i<this.providers.length;i++) {
                        this.providers[i].providerId = this.providers[i].Provider__r.Casevault_ProID__c;
                        this.providers[i].providerName = this.providers[i].Provider__r.Name;
                        this.providers[i].taxID = this.providers[i].Provider__r.Tax_ID__c;
                        this.providers[i].address = this.providers[i].Provider__r.BillingStreet;
                        this.providers[i].country = this.providers[i].Provider__r.BillingCountry;
                }
            }
        }).catch(error => {

            this.loading=false;
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
    }

    handleSelect() {

            this.showModalAddNewService = false;
            this.showServiceDetail = true;
            this.service = {};
        
    }

    handleDiscard() {

        this.showServiceDetail = false;
    }

    handleSave() {

        this.service.Client__c = this.details.id;
        this.service.Structure_Services__c = this.serviceDetail.Id;
        this.service.Provider__c = this.serviceDetail.Provider__c;
        this.service.Type__c = 'Vendor Services';
        if(!this.onValidate()) {

            this.showServiceDetail = false;
            this.loading = true;   
            createService({serviceJSON : JSON.stringify(this.checkNamespaceApplicable(this.service,true))})
            .then(result =>{
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

                this.loading=false;
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
        else {

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

        if(event.target.name == 'Service Received') {
            this.service.Service_Received__c = event.target.checked;
            if(event.target.checked == true) {
                this.actualBeginDate = true;
            }
            else{
                this.actualBeginDate = false;
            }
        }
        
        else if(event.target.name == 'Court Order') {
            this.service.Court_Order__c = event.target.checked;
        }
        
        else if(event.target.name == 'Service Not Received') {
            this.service.Service_Not_Received__c = event.target.checked;
        }
         
        else {
            this.service[event.target.name] = event.target.value;
        }
    }

    handlePurchase(row) {
        this.loading = true;
        this.showChild1 = false;
        let id = row.Id;
        
        getService({serviceId : id})
        .then(result =>{

            if(result != null) {

                this.purchase = this.checkNamespaceApplicable(JSON.parse(result),false);
            
            
            getAllPurchaseAuthorization({serviceId : this.purchase.Id})
                .then(result =>{

                    this.purchaseList = [];
                    if(result != null || result.length > 0 )  {

                        this.purchaseList= this.checkNamespaceApplicable(JSON.parse(result),false);
                        this.showChild1 = true;
                            
                    } 
                    this.loading = false;
                       
                }).catch(error => {

                    this.loading=false;
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
                    });

            } 

           this.serviceEdit2 = {};
            for(let i=0;i< this.serviceList.length;i++) {
                if(this.serviceList[i].Id == id) {
                    this.serviceEdit2 = this.serviceList[i];
                    
                }
            }
            this.openPurchaseAuthorizationList = true;
        
        }).catch(error => {

            this.loading=false;
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

    purchaseAuthorizationForm() {

        this.openPurchaseAuthorizationList = false;
        this.disableSave = false; 
        this.openPurchaseAuthorizationForm = true;
        this.showpurchaseTable = false;
        this.purchaseForm = {};
        this.purchaseEdit = {};
    }

    openForm(row) {

        let id = row.Id;
        this.purchaseEdit.Id = id;
        this.openPurchaseAuthorizationList = false;
        this.loading = true;
        getPurchase({purchaseId : id })
        .then(result =>{
            this.loading = false;
            this.purchaseForm= this.checkNamespaceApplicable(JSON.parse(result),false);
            this.openPurchaseAuthorizationForm = true;
            
            if(this.purchaseForm.Select_Approver__c == null && this.purchaseForm.Forwarded_From__c == null) {
                this.showpurchaseTable = false; 
                this.disableSave = false;   
            }
            else if(this.purchaseForm.Status__c == 'Approved'){
                this.disableSave = true;
                this.showpurchaseTable = true;
            }

            else{
                this.disableSave = false;
                this.showpurchaseTable = true;

            }
            
        }).catch(error => {

            this.loading=false;
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

    hideopenPurchaseAuthorizationForm() {
        this.openPurchaseAuthorizationForm = false;
    }

    hideopenPurchaseAuthorizationList() {
        this.openPurchaseAuthorizationList = false;
        
    }

    handleRowSelection(event) {

        var selectedRows = event.detail.selectedRows;
        let length = selectedRows.length - 1;
        this.serviceDetail = selectedRows[length];
        
    }

    handlePurchaseChange(event) {

        if(this.purchaseForm.Id != null) {

            this.purchaseEdit.Id = this.purchaseForm.Id;
        }
        this.purchaseEdit[event.target.name] = event.target.value;
        
    }

    handlepurchaseSave() {

        if(!this.onValidate()) {
            this.purchaseEdit.Service__c = this.purchase.Id;
            this.purchaseEdit.Final_Amount__c = this.purchaseEdit.Cost_not_be_exceed__c;
            this.loading = true;
            createPurchase({purchaseJSON : JSON.stringify(this.checkNamespaceApplicable(this.purchaseEdit,true))})
            .then(result =>{
                this.openPurchaseAuthorizationForm = false;
                const evt = new ShowToastEvent({
                    title : 'Success',
                    message : 'Purchase Authorization Created/Updated',
                    variant : 'success',
                    mode : 'dismissable'
                });
                this.dispatchEvent(evt);
                getAllPurchaseAuthorization({serviceId : this.purchase.Id})
                .then(results =>{
                    this.loading = false;
                    this.purchaseList= this.checkNamespaceApplicable(JSON.parse(results),false);
                    this.openPurchaseAuthorizationList = true;
                   
                }).catch(error => {

                    this.loading=false;
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
            }).catch(error => {

                this.loading=false;
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
        else{

            const evt1 = new ShowToastEvent({
                title : 'Error',
                message : 'Required fields are missing',
                variant : 'error',
                mode : 'dismissable'

            });
            this.dispatchEvent(evt1);
        }
    } 
    
    handleApproval(event) {
        if(this.purchaseForm.Status__c != 'Submitted for Approval' && this.purchaseForm.Status__c != 'Approved') {

            this.openPurchaseAuthorizationForm = false;
            this.showApprovalScreen = true;
            this.purchaseId = event.target.dataset.id;
        }
        else if(this.purchaseForm.Status__c == 'Submitted for Approval') {

            const evt1 = new ShowToastEvent({
                title : 'Error',
                message : 'Record Already submitted for Approval',
                variant : 'error',
                mode : 'dismissable'

            });
            this.dispatchEvent(evt1);
        }
        else if(this.purchaseForm.Status__c == 'Approved') {
            const evt1 = new ShowToastEvent({
                title : 'Error',
                message : 'Record Already Approved',
                variant : 'error',
                mode : 'dismissable'

            });
            this.dispatchEvent(evt1);
        }
        
    }

    hideApprovalScreen() {
        this.showApprovalScreen = false;
    }

    handleSelectRec(event) {

        this.supervisorId = event.detail.recordId;
        this.enableSubmit = this.supervisorId?false:true;
    }

    submitApproval(event) {
        submitSuperApproval({authorizationRecId: this.purchaseId, selectedSupervisorUserId: this.supervisorId})
        .then(result => {
            const evt = new ShowToastEvent({
                title : 'Success',
                message : 'Purchase Authorization Record sent to Supervisor Approval',
                variant : 'success',
                mode : 'dismissable'
            });
            this.dispatchEvent(evt);
            this.showApprovalScreen = false;
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

    handleEdit(row) {

        let id = row.Id;
        this.serviceEdit2 = {};
        for(let i=0;i< this.serviceList.length;i++) {
            if(this.serviceList[i].Id == id) {
                this.serviceEdit2 = this.serviceList[i];
                
            }
        }
        
        this.loading = true;
        getService({serviceId : id})
        .then(result =>{
            this.loading = false;
            this.serviceEdit = this.checkNamespaceApplicable(JSON.parse(result),false);
            this.editclientProgramName = [
                {label : this.serviceEdit.Client_Program_Name__c,
                value : this.serviceEdit.Client_Program_Name__c}
            ];
            
            this.showEditServiceDetail = true;
        }).catch(error => {

            this.loading=false;
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

    handleUpdateServiceDiscard() {
        this.showEditServiceDetail = false;
    }

    handleDownload(row) {

        let id = row.Id;
        this.openPurchaseAuthorizationList = false;
        var url = '/apex/AuthorizationRecordDownload?id='+id;
        window.open(url, '_blank');
    }

    handleUpdate() {

        if(!this.onValidate()) {

            this.showEditServiceDetail = false;
            this.loading = true;   
            createService({serviceJSON : JSON.stringify(this.checkNamespaceApplicable(this.serviceEdit,true))})
            .then(result =>{
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

                this.loading=false;
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
        else {

            const evt1 = new ShowToastEvent({
                title : 'Error',
                message : 'Required fields are missing',
                variant : 'error',
                mode : 'dismissable'

            });
            this.dispatchEvent(evt1);
        }

    }

    handleEditService(event) {

        if(event.target.name == 'Service Received') {
            this.serviceEdit.Service_Received__c = event.target.checked;
            if(event.target.checked == true) {
                this.actualBeginDate = true;
            }
            else{
                this.actualBeginDate = false;
            }
        }
        else if(event.target.name == 'Court Order') {
            this.serviceEdit.Court_Order__c = event.target.checked;
        }
        else if(event.target.name == 'Service Not Received') {
            this.serviceEdit.Service_Not_Received__c = event.target.checked;
        }
        else {
            this.serviceEdit[event.target.name] = event.target.value;
        }
    }

    handleDelete(row) {
        this.showdelete = true;
        this.deleteId = row.Id;
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
    paginationHandler1(event) {

        this.visibleData1 = [...event.detail.records];     
    }

    handleRowAction(event) {

        var action = event.detail.action;
        var row = event.detail.row;
        switch (action.name) {
            case 'edit': 
                this.handleEdit(row);
                break;

            case 'delete':
                this.handleDelete(row);
                break;

            case 'purchaseAuthorization':
                this.handlePurchase(row);
                break;

            case 'authorizationId':
                this.openForm(row);
                break;

            case 'report':
                this.handleDownload(row);
                break;
        }
    }

}