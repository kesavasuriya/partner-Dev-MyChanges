import { LightningElement, track, api, wire } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getInitialInformation from '@salesforce/apex/FindingPersonController.getInitialInformation';
import getPersons from '@salesforce/apex/FindingPersonController.getPersons';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Contact_OBJECT from '@salesforce/schema/Contact';
import getProviderId from '@salesforce/apex/FindingPersonController.getProviderId';
import getPersonsIntakeInvSC from '@salesforce/apex/PersonSearchController.personsIntakeInvSC';
import getCollaterals from '@salesforce/apex/FindingPersonController.getCollaterals';
import { subscribe, onError } from 'lightning/empApi';
import addJnObj from '@salesforce/apex/FindingPersonController.addJnObj';
import { updateRecord } from 'lightning/uiRecordApi';




const collateralColumn = [

    { label : 'Name',  type:  'button',typeAttributes: { 
        variant :'base', name : 'name',
                 label:   { 
            fieldName: 'Name' 
        } }},
    { label : 'First Name', fieldName : 'First_Name__c', wrapText: true},
    { label : 'Middle Name', fieldName : 'Middle_Name__c', wrapText: true},
    { label : 'Last Name', fieldName : 'Last_Name__c', wrapText: true},

];

export default class FindPerson extends NavigationMixin(UtilityBaseElement) {

    @api recordId;
    @api objectApiName;
    @api recordTypeName;
    @api personType;
    @api borderSize;
    @api activeColor;
    @api inactiveColor;
    @track personTitle;
    @track objectInfo;
    @track currentStep = 'step1';
    @track isStep1 = true;
    @track isStep2 = false;
    @track genderPickOpt = [];
    @track statePickOpt = [];
    @track countryPickOpt = [];
    @track searchInput = {};
    @track personList = [];
    @track conRec = {};
    @track selectedPersonId = '';
    @track isLoading = false;
    @track showTable = true;
    @track HideSearchButton = false;
    @track disableButton = false;
    @track showWarning = false;
    @track message = '';
    @track action = '';
    numberOfPersonRecord;
    collateralColumn = collateralColumn;
    @track setSelectedRows = [];
    @track defaultValue = {};
    activePersonTitle;
    inactivePersonTitle;
    collateralsTitle;
    activeTabValue;
    showCustomTabs = false;
    @track collaterals = [];
    CHANNEL_NAME = '/data/Collateral__ChangeEvent';
    subscription = {};
    isLoading = false;
    searchInput={};
    @track selectPersonRecordTypeId;
    
    connectedCallback() {

        //loadScript(this, momentForTime)
       
        if (this.objectApiName != 'Home_Approval__c') {
            this.doInitInfo();
            if(this.objectApiName == 'Service_Case__c') {

                /*subscribe(this.CHANNEL_NAME, -1, this.refreshList).then(response => {
                    this.subscription = response;
                });
                onError(error => { console.log('error:::',error);});*/
                this.showCustomTabs = true;
                this.activeTabValue = 'Inactive_Person';
            }
        }
    }

    refreshList = () => {

        this.handleCollaterals();

    }


    @wire(getObjectInfo, { objectApiName: Contact_OBJECT })
    objectInfo;

    get contactsRecordTypeId() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        if (this.recordTypeName) {
            return Object.keys(rtis).find(rti => rtis[rti].name === this.recordTypeName);

        } else {
            return Object.keys(rtis).find(rti => rtis[rti].name === 'Persons Involved');

        }
    }

    doInitInfo() {
        getInitialInformation({}).then(result => {
            if (result) {
                let res = JSON.parse(result);
                this.genderPickOpt = res.genderPicklist;
                this.statePickOpt = res.statePicklist;
                this.countryPickOpt = res.countryPicklist;
                this.selectPersonRecordTypeId = res.selectPersonRecordTypeId;
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

    showSearchModal() {
        this.HideSearchButton = true;
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

    searchPerson() {

        //this.setSelectedRows = [];
        this.refreshSubRecords();
        this.isLoading = true;
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
                        this.isLoading = false;
                        let res = JSON.parse(result);
                        this.currentStep = 'step2';
                        this.isStep2 = true;
                        this.isStep1 = false;
                        this.personList = this.checkNamespaceApplicable(res, false);
                        let personListLength = this.personList.length;
                        this.numberOfPersonRecord = 'Persons ('+this.personList.length+')';
                        if (personListLength > 0) {
                            this.showTable = true;
                            this.disableButton = false;
                        } else {
                            this.showTable = false;
                            this.disableButton = true;
                        }
                    }

                }).catch(error => {
                    this.isLoading = false;
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

    handleRowAction1(event) {

        var selectedRows = event.detail.selectedRows;
        this.selectedPersonId = selectedRows[0].Id;
        var selectedPerson = selectedRows[0];
        this.setSelectedRows = selectedRows;

        if(selectedPerson) {

            this.refreshSubRecords();
            this.isLoading = true;
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
                this.isLoading = false;     
            }).catch(error => {

                this.isLoading = false;  
                this.handleError(error);
            })
        }

    }

    selectPerson(event) {

        this.isLoading = true;
        const fields = {};
            fields.Id = this.selectedPersonId;
            fields.Jn_Object_Handler__c = this.recordId + ',' + this.objectApiName;

            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__objectPage',
                        attributes: {
                            objectApiName: 'Contact',
                            actionName: 'edit',
                            recordId : this.selectedPersonId
                        },
                        state: {
                            recordTypeId: this.selectPersonRecordTypeId,
                        }
                    });
                    this.backToSearch();
                    this.handleCloseSearch();

                })

            
            
        /*if (this.selectedPersonId) {

            console.log('addperson',this.selectedPersonId,this.recordId,this.objectApiName);
            addJnObj({ contactId: this.selectedPersonId, recordId : this.recordId, objectApiName : this.objectApiName })
                .then(result => {
                    this.isLoading = false;
                    this.title = 'Success!';
                    this.type = 'success';  
                    this.message = 'Person added successfully';
                    this.selectedPersonId = '';
                    this.fireToastMsg();
                    this.backToSearch();
                    this.handleCloseSearch();

                    

                }).catch(error => {
                    this.isLoading = false;
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
        } else {
            this.isLoading = false;
            this.title = 'Info!';
            this.type = 'info';
            this.message = 'Select one person';
            this.fireToastMsg();
    }*/
    }
    paginationHandlerSearchContact(event) {

        this.refreshSubRecords();
        //this.setSelectedRows = [];
        this.visibleDataContact = [...event.detail.records];
        //this.refreshSubRecords();
        
        
    }

    backToSearch() {

        this.handleClearSearch();
        this.isStep1 = true;
        this.isStep2 = false;
        this.currentStep = 'step1';
        this.conRec = {};
    }

    handleClearSearch() {
        this.searchInput = {};
    }

    handleCloseSearch() {

        this.backToSearch();
        this.HideSearchButton = false;
    }

    handleNavigate() {

        //let recordIdPrefix = this.recordId.slice(0,3);
        let Jn_Object_Handler = this.recordId + ',' + this.objectApiName;
        if (this.objectApiName == 'Home_Approval__c') {
            this.isLoading = true;
            getProviderId({ homeApprovalId: this.recordId })
                .then(result => {
                    this.isLoading = false;
                    this.defaultValues = encodeDefaultFieldValues({
                        Home_Approval__c: this.recordId,
                        AccountId : result
                    });
                    this[NavigationMixin.Navigate]({
                        type: 'standard__objectPage',
                        attributes: {
                            objectApiName: 'Contact',
                            actionName: 'new',
                        },
                        state: {
                            recordTypeId: this.contactsRecordTypeId,
                            defaultFieldValues: this.defaultValues
                        }
                    });
                }).catch(error => {
                    this.isLoading = false;
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

        } else {

                 this.defaultValue.FirstName = this.searchInput.firstName;
                 this.defaultValue.LastName = this.searchInput.lastName;
                 this.defaultValue.Date_of_Birth__c = this.searchInput.dob;
                 this.defaultValue.State_Id_Drivers_License__c = this.searchInput.stateId;
                 this.defaultValue.SSN__c = this.searchInput.ssn;
                 this.defaultValue.Jn_Object_Handler__c = Jn_Object_Handler;

            this.defaultValues = encodeDefaultFieldValues(this.defaultValue);
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Contact',
                    actionName: 'new',
                },
                state: {
                    recordTypeId: this.contactsRecordTypeId,
                    defaultFieldValues: this.defaultValues
                }
            });
            this.personList = [];
            this.backToSearch();
            this.handleCloseSearch();
        }
    }

    handleAdd(event) {

        console.log('A12',event);
        this.action = event.detail.actionName;
        this.selectedPersonId = event.detail.selectedPerson;
        this.searchInput = event.detail.searchInput;
        if(this.action == 'addNew') {
            this.message = 'You are adding a new person to the database do you want to proceed?';
        } else if(this.action == 'addPerson') {
            this.message = 'You have chosen client to add to the case, do you want to proceed?';
        }
        this.showWarning = true;

    }

    handleProcced(event) {

        if(this.action == 'addNew') {
            this.handleNavigate();
        } else if(this.action == 'addPerson') {
            this.selectPerson();
        }
        this.showWarning = false;
    }

    handleCancel(event) {
        this.message = '';
        this.action = '';
        this.showWarning = false;
    }

    handlePersonCount(event) {
        this.personTitle = "Person's ("+event.detail+")";
    }

    handleActivePersonCount(event) {
        this.activePersonTitle = 'Active Persons (' + event.detail + ')';

    }

    handleInactivePersonCount(event) {

        this.inactivePersonTitle = 'Inactive Persons (' + event.detail + ')';
        if(this.collateralsTitle) {
            return;
        } else {
            this.activeTabValue = 'Collaterals';
            this.handleCollaterals();
        }
            
    }

    handleCollaterals() {

        this.handleCloseSearch();
        getCollaterals({ recordId : this.recordId}) 
        .then(result => {
            if(result) {
                this.collaterals = JSON.parse(result);
                this.collateralsTitle = 'Collaterals ('+this.collaterals.length+')';
            } else {
                this.collateralsTitle = 'Collaterals (0)';
            }
            if(this.activePersonTitle) {
                return;
            } else {
                this.activeTabValue = 'Active_Person';
            }
        }).catch(error => {
            this.handleError(error);
        })
    }

    handleNewCollateral() {

        this.defaultValues = encodeDefaultFieldValues({
            Service_Case__c : this.recordId
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Collateral__c',
                actionName: 'new',
            },
            state: {
                defaultFieldValues: this.defaultValues
            }
        });

    }

    refreshSubRecords() {

        this.intakeList = [];
        this.cpsIntakeList = [];
        this.servicecaseList = [];
        this.showIntake = false;
        this.showCPSIntake = false;
        this.showServiceCase = false;
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

    
}