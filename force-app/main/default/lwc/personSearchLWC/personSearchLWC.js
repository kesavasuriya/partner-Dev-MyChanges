import { LightningElement, track } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getContactDetail from '@salesforce/apex/PersonSearchController.getContacts';
import getPicklistValues from '@salesforce/apex/PersonSearchController.getPicklistValues';
import getPersonsIntakeInvSC from '@salesforce/apex/PersonSearchController.personsIntakeInvSC';
import { NavigationMixin } from 'lightning/navigation';

const personColumn = [

    { label : 'First Name', fieldName: 'FirstName', type: 'text', wrapText: true, sortable: true},
    { label : 'Last Name', fieldName: 'recordUrl', type: 'url', sortable: true, wrapText: true, target : '_self',typeAttributes : {  label : { fieldName : 'LastName'} }},
    { label: 'DOB', fieldName: 'Date_of_Birth__c', type: 'date', sortable: true, typeAttributes: {
         month: "2-digit",
        day: "2-digit",
        year: "numeric",timeZone:"UTC"
    } },
    { label: 'SSN', type: 'button', name:'ssn',  typeAttributes : { variant :'base', label : {fieldName : 'ssnMaskValue'},iconName : { fieldName : 'ssnIcon'}, iconPosition: 'right'} },
    { label: 'Gender', fieldName: 'Gender__c', type: 'text', wrapText: true , sortable: true},
    { label: 'Casevault PID', fieldName: 'Casevault_PID__c', type: 'text',wrapText: true, sortable: true},
    { label: 'DL NO', fieldName: 'State_Id_Drivers_License__c', type: 'text', wrapText : true, sortable: true},
    { label: 'Address line 1', fieldName: 'Address_Line_1__c', type: 'text', wrapText : true, sortable: true},
    { label: 'Address line 2', fieldName: 'Address_Line_2__c', type: 'text', wrapText : true, sortable: true},
    { label: 'City', fieldName: 'Address_City__c', type: 'text', wrapText: true , sortable: true},
    { label: 'State', fieldName: 'Address_State__c', type: 'text', wrapText: true , sortable: true},
    { label: 'County', fieldName: 'County_Address__c', type: 'text', wrapText: true , sortable: true},
    { label: 'Zip code', fieldName: 'Address_ZipCode__c', type: 'text', wrapText: true , sortable: true},
    { label: 'Role', fieldName: 'Intake_Person_Role__c', type: 'text', wrapText : true, sortable: true}
];

const cpsIntakecolumn = [
    { label: 'Name', type:  'button',typeAttributes: { 
        variant :'base', name : 'name',
                 label:   { 
            fieldName: 'Name' 
        } }},
    { label: 'CPS Response Type', fieldName: 'CPS_Response_Type__c', type: 'text', wrapText: true}        
];

/*const cpsIntakecolumn = [
    { label: 'Name', fieldName: 'Name', type: 'text', wrapText: true},    
    { label: 'CPS Response Type', fieldName: 'CPS_Response_Type__c', type: 'text', wrapText: true}        
];*/

const intakeColumn = [
    { label: 'Intake', type:  'button',typeAttributes: { 
        variant :'base', name : 'name',
                 label:   { 
            fieldName: 'CaseNumber' 
        } }},
    { label: 'Purpose', fieldName: 'Origin', type: 'text', wrapText: true},
    { label: 'Jurisdiction', fieldName: 'Jurisdiction__c', type: 'text', wrapText: true}
];

/*const intakeColumn = [

    { label: 'Name', fieldName: 'CaseNumber', type: 'text', wrapText: true},
    { label: 'Purpose', fieldName: 'Origin', type: 'text', wrapText: true},
    { label: 'Jurisdiction', fieldName: 'Jurisdiction__c', type: 'text', wrapText: true}
];*/

const serviceCasecolumn = [
    { label: 'Name', type:  'button',typeAttributes: { 
        variant :'base', name : 'name',
                 label:   { 
            fieldName: 'Name' 
        } }},
    { label: 'Number of days', fieldName: 'Number_of_days__c', type: 'text'},
    { label: 'Status', fieldName: 'Status__c', type: 'text', wrapText: true}  
];

/*const serviceCasecolumn = [
    
    { label: 'Name', fieldName: 'Name', type: 'text', wrapText: true},
    { label: 'Number of days', fieldName: 'Number_of_days__c', type: 'text'},
    { label: 'Status', fieldName: 'Status__c', type: 'text', wrapText: true}  
];*/

export default class PersonSearchLWC extends NavigationMixin(UtilityBaseElement) {

    isLoading = false;
    @track searchInput = {};
    @track contactList =[];
    @track cpsIntakeList = [];
    @track intakeList = [];
    @track servicecaseList = [];
    
    personColumn = personColumn;
    cpsIntakecolumn = cpsIntakecolumn;
    intakeColumn = intakeColumn;
    serviceCasecolumn = serviceCasecolumn;

    showContactTable = false;
    showIntake = false;
    showCPSIntake = false;
    showServiceCase = false;

    @track visibleDataContact = [];
    @track visibleDataCPSIntake = [];
    @track visibleDataIntake = [];
    @track visibleDataServiceCase = [];
    @track setSelectedRows = [];
    numberOfPersonRecord;
    istoolTipRendered = false;
    tooltipData;
	top;
	left;
	customCss;

    @track sortBy;
    @track sortDirection;
    @track statePicklist = [];
    @track countyPicklist = [];

    connectedCallback() {

        this.isLoading = true;
        getPicklistValues()
        .then(result => {
            
            this.isLoading = false;
            let response = JSON.parse(result);
            this.statePicklist = response.statePicklist;
            this.countyPicklist = response.countyPicklist;
        }).catch(error => {

            this.isLoading = false;
            this.handleError(error);
        })
    }
    
    handleChange(event) { 

        if(event.target.name == 'ssn') {

            const y = event.target.value
                    .replace(/\D+/g, '')
                    .match(/(\d{0,3})(\d{0,2})(\d{0,4})/);

            event.target.value = !y[2] ? y[1] : `${y[1]}-${y[2]}` + (y[3] ? `-${y[3]}` : ``);
        } 
        this.searchInput[event.target.name] = event.target.value;
    }

    handleKeyPress(event) {
        
        if(event.keyCode === 13){
           
            if(event.target.value) {
                this.handleChange(event);
            }
            
            this.handleSearch();
        }  
    }


    handleSearch() {

        var objHasValue = false;
        for(const prop in this.searchInput) {
            if(this.searchInput[prop]) {
                objHasValue = true;
                break;
            }
        }
        
        if(!objHasValue) {

            this.isLoading = false;
            this.title = "Warning!";
            this.type = "warning";
            this.message = "Please enter atleast one input for search";
            this.fireToastMsg();

        } else {

            this.isLoading= true;
            this.setSelectedRows = [];
            this.handleRefresh();
            this.showContactTable = false;
            getContactDetail({searchJSON:JSON.stringify(this.searchInput)})   
                .then(result => {
                    this.isLoading= false;
                    if (result) {    

                        this.contactList = JSON.parse(result); 
                        this.numberOfPersonRecord = 'Persons ('+this.contactList.length+')';

                        if (this.contactList.length <= 0) {

                                this.title = "Info!";
                                this.type ="info";
                                this.message = "No records found";
                                this.fireToastMsg();
                        } else {

                            for(let i = 0; i < this.contactList.length; i++ ) {
                                this.contactList[i].recordUrl = '/lightning/r/'+this.contactList[i].Id+'/view';
                                if(this.contactList[i].SSN__c) {
                                    this.contactList[i].ssnIcon = 'utility:preview';
                                    this.contactList[i].ssnMaskValue = '***-**-****';
                                }
                            }
                            this.showContactTable = true;
                        }
                    }
                }).catch(error => {

                    this.isLoading = false;
                    this.handleError(error);
                })
        }    
    }

    handleClearSearch() {

        this.searchInput = {};
        this.handleRefresh();
        this.setSelectedRows = [];
        this.showContactTable = false;
    }

    handleContactRowAction (event) {

        var rowId = event.detail.row.Id;
        var currentPageRecords = [...this.visibleDataContact];
        for(let i = 0; i < currentPageRecords.length; i++ ) {
            if(currentPageRecords[i].Id == rowId && currentPageRecords[i].SSN__c) {
                let currentRec = Object.assign({}, currentPageRecords[i]);
                if(currentPageRecords[i].ssnIcon == 'utility:preview') {
                    currentRec.ssnIcon = 'utility:hide';
                    currentRec.ssnMaskValue = currentPageRecords[i].SSN__c;
                } else if(currentPageRecords[i].ssnIcon == 'utility:hide') {
                    currentRec.ssnIcon = 'utility:preview';
                    currentRec.ssnMaskValue = '***-**-****';
                } 
                currentPageRecords[i] = currentRec;
                break;
            }
        }
        this.visibleDataContact = currentPageRecords;
    }

    handleRowAction(event) {

        var rowId = event.detail.row.Id;
        this.navigateClick(rowId);
    }

    handleRowSelection(event) {
        
        var selectedRows = event.detail.selectedRows;
        var selectedPerson = selectedRows[0];

        if(selectedPerson) {

            this.refreshSubRecords();
            this.isLoading = true;
            getPersonsIntakeInvSC({ selectedPersonJSON : JSON.stringify(selectedPerson)})
            .then(result => {
                let response = JSON.parse(result);
                console.log('result',response);
                if(response.intake) {

                    this.intakeList = response.intake;
                    this.showIntake = true;
                }
                if(response.investigation) {

                    let investigations = [];
                    this.cpsIntakeList = response.investigation;
                    this.showCPSIntake = true;
                }
                if(response.serviceCase) {

                    let serviceCases = [];
                    this.servicecaseList = response.serviceCase;
                    this.showServiceCase = true;
                } 
                this.isLoading = false;     
            }).catch(error => {

                this.isLoading = false;  
                this.handleError(error);
            })
        }
    }

    handleRefresh() {

        this.contactList = [];
        this.refreshSubRecords();      
    }

    refreshSubRecords() {

        this.intakeList = [];
        this.cpsIntakeList = [];
        this.servicecaseList = [];
        this.showIntake = false;
        this.showCPSIntake = false;
        this.showServiceCase = false;
    }

    navigateClick(recordId) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    handleIconMouseOver(event) {

        let toolTipName = event.target.name;
        let rect = event.target.getBoundingClientRect();
        this.istoolTipRendered = true; 
        if (toolTipName == 'Name-Tooltip-PID')  {
          this.tooltipData = '<b><u>Casevault PID:</u></b><br><p> Search Term </p>1. PE-1<br>2. PE-12<br>3. PE-123'; 
        } else if(toolTipName == 'Name-Tooltip-SSN') {
            this.tooltipData = '<b><u>SSN</u></b></br><p> SSN Format </p> XXX-XX-XXXX ';
        }
        this.left = rect.left;
        this.left = this.left + 25;
        this.top = rect.top;
        this.top = this.top + 11;     
        this.customCss = {
      
          'position':'fixed',
          'top':this.top,
          'left':this.left
      };  
    }

    handleIconMouseLeave(event) {

        this.istoolTipRendered = false;
    }

    handleError(error) {

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
    }

    paginationHandlerContact(event) {

        this.visibleDataContact = [...event.detail.records];     
    }

    paginationHandlerCPSIntake(event) {

        this.visibleDataCPSIntake = [...event.detail.records];     
    }

    paginationHandlerIntake(event) {

        this.visibleDataIntake = [...event.detail.records];     
    }

    paginationHandlerServiceCase(event) {

        this.visibleDataServiceCase = [...event.detail.records];     
    }

    doSorting(event) {

        let sortbyField = event.detail.fieldName;
        if(sortbyField == 'recordUrl') {
            this.sortBy = 'LastName';
        } else {
            this.sortBy = event.detail.fieldName;
        }
        
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
        this.sortBy = sortbyField;
    }

    sortData(fieldname, direction) {

        let parseData = [...this.contactList];
        this.refreshSubRecords();
        this.setSelectedRows = [];
        
        let keyValue = (a) => {

            return a[fieldname];

        };

        let isReverse = direction === 'asc' ? 1: -1;

        parseData.sort((x, y) => {

            x = keyValue(x) ? keyValue(x) : '';

            y = keyValue(y) ? keyValue(y) : '';

            return isReverse * ((x > y) - (y > x));

        });
        this.contactList = parseData;
        this.template.querySelector('c-pagination-l-w-c').refreshCmp(this.contactList);
    }

}