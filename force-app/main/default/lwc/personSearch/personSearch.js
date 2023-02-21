import { LightningElement,track,api } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getInitialInformation from '@salesforce/apex/FindingPersonController.getInitialInformation';
import getPersons from '@salesforce/apex/FindingPersonController.getPersons';
import { NavigationMixin } from 'lightning/navigation';
import getPersonsIntakeInvSC from '@salesforce/apex/PersonSearchController.personsIntakeInvSC';

const columns = [
    { label: 'First Name', fieldName: 'FirstName', type: 'string' },
    { label: 'Last Name', type: 'string', fieldName: 'LastName' },
    { label: 'DOB', fieldName: 'Date_of_Birth__c', type: 'date', typeAttributes: { month: "numeric", day: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Gender', fieldName: 'Gender__c', type: 'string' },
    { label: 'SSN', fieldName: 'SSN__c', type: 'string' },
    { label: 'Address', fieldName: 'Address_Line_1__c', type: 'string' },
    { label: 'Casevault ID', fieldName: 'Casevault_PID__c', type: 'string' },
    { label: 'Source', fieldName: '', type: 'string' },
    { label: 'Prior History', fieldName: '', type: 'string' }
];

const intakeColumn = [
    { label: 'Intake', type:  'button',typeAttributes: { 
        variant :'base', name : 'name',
                 label:   { 
            fieldName: 'CaseNumber' 
        } }},
    { label: 'Purpose', fieldName: 'Origin', type: 'text', wrapText: true},
    { label: 'Jurisdiction', fieldName: 'Jurisdiction__c', type: 'text', wrapText: true}
];


const cpsIntakecolumn = [
    { label: 'Name', type:  'button',typeAttributes: { 
        variant :'base', name : 'name',
                 label:   { 
            fieldName: 'Name' 
        } }},
    { label: 'CPS Response Type', fieldName: 'CPS_Response_Type__c', type: 'text', wrapText: true}        
];



const serviceCasecolumn = [
    { label: 'Name', type:  'button',typeAttributes: { 
        variant :'base', name : 'name',
                 label:   { 
            fieldName: 'Name' 
        } }},
    { label: 'Number of days', fieldName: 'Number_of_days__c', type: 'text'},
    { label: 'Status', fieldName: 'Status__c', type: 'text', wrapText: true}  
];
export default class PersonSearch extends NavigationMixin(UtilityBaseElement) {

    @api recordId;
    @track currentStep = 'step1';
    @track isStep1 = true;
    @track isStep2 = false;
    @api contactRec;
    genderPickOpt = [];
    statePickOpt = [];
    countryPickOpt = [];
    @track conRec = {};
    @track personList = [];
    @track showTable = true;
    @track setSelectedRows = [];
    @track message = '';
    @track action = '';
    @track selectedPersonId = '';
    @track searchInput ={};

    showIntake = false;
    showCPSIntake = false;
    showServiceCase = false;
    allowAdd = true;
    disableButton = true;

    @track visibleDataContact = [];
    @track visibleDataCPSIntake = [];
    @track visibleDataIntake = [];
    @track visibleDataServiceCase = [];

    columns = columns;
    cpsIntakecolumn = cpsIntakecolumn;
    intakeColumn = intakeColumn;
    serviceCasecolumn = serviceCasecolumn;
    

    connectedCallback() {
        if(this.contactRec.FirstName) {
            this.searchInput.firstName = this.contactRec.FirstName;
        }
        if(this.contactRec.LastName) {
            this.searchInput.lastName = this.contactRec.LastName;
        }
        if(this.contactRec.Date_of_Birth__c) {
            this.searchInput.dob = this.contactRec.Date_of_Birth__c;
        }
        this.doInitInfo();
    }

    doInitInfo() {
        getInitialInformation({}).then(result => {
            if (result) {
                let res = JSON.parse(result);
                this.genderPickOpt = res.genderPicklist;
                this.statePickOpt = res.statePicklist;
                this.countryPickOpt = res.countryPicklist;
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
            this.message = errorMsg;
            this.fireToastMsg();
        })
    }


    backToSearch() {

        this.handleClearSearch();
        this.isStep1 = true;
        this.isStep2 = false;
        this.currentStep = 'step1';
        this.conRec = {};
        this.allowAdd = true;
    }

    handleClearSearch() {
        this.searchInput = {}; 
        this.selectedPersonId = '';
        this.searchPerson = {};
        this.disableButton = true;
    }

    handleCloseSearch() {

       const closeSearchEvent = new CustomEvent('closesearch',{
        detail : true
       });
       this.dispatchEvent(closeSearchEvent);
       this.allowAdd = true;
    }
    
    handleChange(event) {

        let name = event.target.name;
        let value = event.target.value;
        if (name == 'firstName') {
            this.searchInput.firstName = value;
        }
        if (name == 'lastName') {
            this.searchInput.lastName = value;
        }
        if (name == 'dob') {
            this.searchInput.dob = value;
        }
        if (name == 'ssn') {
            // this.searchInput.ssn = value;

            const y = event.target.value
                .replace(/\D+/g, '')
                .match(/(\d{0,3})(\d{0,2})(\d{0,4})/);

            event.target.value = !y[2] ? y[1] : `${y[1]}-${y[2]}` + (y[3] ? `-${y[3]}` : ``);
            this.searchInput[event.target.name] = event.target.value;
        }
        if (name == 'casevaultPId') {
            this.searchInput.casevaultPId = value;
        }
        if (name == 'stateId') {
            this.searchInput.stateId = value;
        }
        if (name == 'gender') {
            this.searchInput.gender = value;
        }
        if (name == 'approxAge') {
            this.searchInput.approxAge = value;
        }
        if (name == 'addLine1') {
            this.searchInput.addLine1 = value;
        }
        if (name == 'addLine2') {
            this.searchInput.addLine2 = value;
        }
        if (name == 'zipCode') {
            this.searchInput.zipCode = value;
        }
        if (name == 'state') {
            this.searchInput.state = value;
        }
        if (name == 'country') {
            this.searchInput.country = value;
        }
        if (name == 'city') {
            this.searchInput.city = value;
        }
        //this.searchInput[name] = value;
    }

    handleRowAction(event) {

        var rowId = event.detail.row.Id;
        this.navigateClick(rowId);
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

    searchPerson() {

        //this.setSelectedRows = [];
        this.refreshSubRecords();
        if (Object.keys(this.searchInput).length === 0) {
            this.isLoading = false;
            this.title = "Warning!";
            this.type = "warning";
            this.message = "Please enter atleast one input for search";
            this.fireToastMsg();
        } else {

            getPersons({ searchJSON: JSON.stringify(this.searchInput), recordId : this.recordId })
                .then(result => {
                    if (result) {
                        let res = JSON.parse(result);
                        this.currentStep = 'step2';
                        this.isStep2 = true;
                        this.isStep1 = false;
                        this.personList = this.checkNamespaceApplicable(res, false);
                        let personListLength = this.personList.length;
                        this.numberOfPersonRecord = 'Persons ('+this.personList.length+')';
                        if (personListLength > 0) {
                            this.showTable = true;
                        } else {
                            this.showTable = false;
                        }
                    }
                    this.allowAdd = false;

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
                    this.message = errorMsg;
                    this.fireToastMsg();
                })
        }
    }

    paginationHandlerSearchContact(event) {

        this.refreshSubRecords();
        //this.setSelectedRows = [];
        this.visibleDataContact = [...event.detail.records];
        //this.refreshSubRecords();
        
        
    }

    refreshSubRecords() {

        this.intakeList = [];
        this.cpsIntakeList = [];
        this.servicecaseList = [];
        this.showIntake = false;
        this.showCPSIntake = false;
        this.showServiceCase = false;
    }

    handleRowAction1(event) {

        var selectedRows = event.detail.selectedRows;
        this.selectedPersonId = selectedRows[0].Id;
        var selectedPerson = selectedRows[0];
        this.setSelectedRows = selectedRows;
        this.disableButton = false;

        if(selectedPerson) {

            this.refreshSubRecords();
            getPersonsIntakeInvSC({ selectedPersonJSON : JSON.stringify(selectedPerson)})
            .then(result => {
                let response = JSON.parse(result);
                if(response.intake) {

                    //let intakes = [];
                    //intakes.push(response.intake);
                    this.intakeList = response.intake;
                    this.showIntake = true;
                }
                if(response.investigation) {

                    //let investigations = [];
                    //investigations.push(response.investigation);
                    this.cpsIntakeList = response.investigation;
                    this.showCPSIntake = true;
                }
                if(response.serviceCase) {

                    //let serviceCases = [];
                    //serviceCases.push(response.serviceCase);
                    this.servicecaseList = response.serviceCase;
                    this.showServiceCase = true;
                } 
            }).catch(error => {

                this.handleError(error);
            })
        }

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

    handleAdd(event) {
        this.action = event.currentTarget.dataset.action;
        let input = this.searchInput;
        const addpersonEvent = new CustomEvent("handleadd",{
            detail:{selectedPerson : this.selectedPersonId,
            actionName : this.action,
            searchInput : input
            }
        });
        this.dispatchEvent(addpersonEvent);
    }
}