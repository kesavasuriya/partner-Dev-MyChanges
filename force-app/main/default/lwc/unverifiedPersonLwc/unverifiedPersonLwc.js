import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getRecords from '@salesforce/apex/UnverifiedPersonController.getUnverifiedPersons';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Contact_OBJECT from '@salesforce/schema/Contact';
import { deleteRecord } from 'lightning/uiRecordApi';
import { subscribe, onError } from 'lightning/empApi';
import getPersonsIntakeInvSC from '@salesforce/apex/PersonSearchController.personsIntakeInvSC';
import selectPerson from '@salesforce/apex/UnverifiedPersonController.selectPerson';
import { updateRecord } from 'lightning/uiRecordApi';





export default class UnverifiedPersonLwc extends NavigationMixin(UtilityBaseElement) {

    subscription = {};
    CHANNEL_NAME = '/event/Refresh_Person__e';
    @api recordId;
    @api objectApiName;
    @track unverifiedPersonsList = [];
    @track showAddButton = false;
    @track showModal = false;
    @track personList = [];
    @track action = '';
    @track selectedPersonId;
    @track warningMessage = '';
    @track showWarning = false;
    @track personRecord = {};
    @track unVerifiedPersonRecordId = '';
    @track personInvolvedRecordTypeId;
    @track unverifiedRecordTypeId;
    @track showWarning = false;
    @track cardtitle;
    @track searchInput = {};
    @track defaultValue = {};
    @track selectPersonRecordTypeId;

    get showpersontable() {
        if (this.unverifiedPersonsList.length > 0) {
            return true;
        } else {
            return false;
        }
    }

    get showSearchResults() {
        if (this.personList.length > 0) {
            return true;
        } else {
            return false;
        }
    }

    @wire(getObjectInfo, { objectApiName: Contact_OBJECT })
    objectInfo;

    get contactsRecordTypeId() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        if (this.recordTypeName) {
            return Object.keys(rtis).find(rti => rtis[rti].name === '');
        } else {
            return Object.keys(rtis).find(rti => rtis[rti].name === 'Persons Involved');
        }
    }

    connectedCallback() {

        subscribe(this.CHANNEL_NAME, -1, this.refreshList).then(response => {
            this.subscription = response;
        });
        onError(error => { });

        if (this.objectApiName == 'Case') {
            this.showAddButton = true;
        } else {
            this.showAddButton = false;
        }
        this.doInit();
    }

    refreshList = () => {

        this.doInit();

    }

    doInit() {

        this.loading = true;
        this.unverifiedPersonsList = [];
        getRecords({ recordId: this.recordId })
            .then(result => {
                let unverifiedLst = JSON.parse(result).unverifiedPersonRecords;
                if (unverifiedLst) {
                    this.unverifiedPersonsList = JSON.parse(result).unverifiedPersonRecords;
                }
                this.personInvolvedRecordTypeId = JSON.parse(result).personInvolvedRecordTypeId;
                this.unverifiedRecordTypeId = JSON.parse(result).unverifiedRecordTypeId;
                this.cardtitle = 'Unverified Persons (' + this.unverifiedPersonsList.length + ')';
                this.selectPersonRecordTypeId = JSON.parse(result).selectPersonRecordTypeId;
                console.log('selectpersonrectypeid',this.selectPersonRecordTypeId);
            }).catch(error => {
                this.handleError(error);
            })

    }

    handleAddNew() {

        let Jn_Object_Handler = this.recordId + ',' + this.objectApiName;
        const encodedValues = encodeDefaultFieldValues({
            Jn_Object_Handler__c: Jn_Object_Handler
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: encodedValues,
                recordTypeId: this.unverifiedRecordTypeId // Record Type Id
            }
        });
    }


    handleNavigate(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.currentTarget.dataset.id,
                objectApiName: 'Contact',
                actionName: 'view'
            },
        });
    }

    handleSearch(event) {

        this.refreshSubRecords();
        this.personList = [];
        this.unVerifiedPersonRecord = this.unverifiedPersonsList[event.currentTarget.dataset.index];
        this.showModal = true;
    }

    handleCancel() {

        this.showModal = false;
        this.showWarning = false;
        this.unVerifiedPersonRecord = {};
        this.personRecord = {};
        this.personList = [];
        this.message = '';
        this.action = '';
        this.showWarning = false;
        this.refreshSubRecords();
    }

    handleRowSelection(event) {

        let selectedRows = event.detail.selectedRows[0];
        this.personRecord = selectedRows;
        console.log(this.personRecord);
        var selectedPerson = selectedRows;

        if (selectedPerson) {

            this.refreshSubRecords();
            getPersonsIntakeInvSC({ selectedPersonJSON: JSON.stringify(selectedPerson) })
                .then(result => {
                    let response = JSON.parse(result);
                    if (response.intake) {

                        
                        this.intakeList = response.intake;
                        this.showIntake = true;
                    }
                    if (response.investigation) {

                        
                        this.cpsIntakeList = response.investigation;
                        this.showCPSIntake = true;
                    }
                    if (response.serviceCase) {

                        
                        this.servicecaseList = response.serviceCase;
                        this.showServiceCase = true;
                    }
                }).catch(error => {

                    this.handleError(error);
                })
        }
    }


    selectPerson(event) {

        this.refreshSubRecords();
        this.defaultValues = encodeDefaultFieldValues({
            Intake_Person_Role__c : this.unVerifiedPersonRecord.Person_Role__c,
        });
        const fields = {};
            fields.Id = this.selectedPersonId;
            fields.Jn_Object_Handler__c = this.recordId + ',' + this.objectApiName;
            fields.Jn_Id__c = this.unVerifiedPersonRecord.Id;

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
                            defaultFieldValues: this.defaultValues

                        }
                    });
                    this.showModal = false;

                })
       /* selectPerson({ unverifiedPersonId: this.unVerifiedPersonRecord.Id, selectedPersonId: this.selectedPersonId, recordId: this.recordId, objectApiName: this.objectApiName })
            .then(result => {

                this.type = 'success';
                this.title = 'Success!';
                this.message = 'Record Created Successfully!';
                this.fireToastMsg();
                this.showModal = false;
                this.handleCancel();
                this.doInit();

            }).catch(error => {

                this.handleError(error);
            })*/

    }

    handleDeleteRec(event) {

        this.handleDelete(event.currentTarget.dataset.id);

    }

    handleDelete(id) {

        deleteRecord(id)
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

   

    refreshSubRecords() {

        this.intakeList = [];
        this.cpsIntakeList = [];
        this.servicecaseList = [];
        this.showIntake = false;
        this.showCPSIntake = false;
        this.showServiceCase = false;
    }s

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

    navigateClick(recordId) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    handleAdd(event) {

        console.log('A12', event);
        this.action = event.detail.actionName;
        this.selectedPersonId = event.detail.selectedPerson;
        this.searchInput = event.detail.searchInput;
        console.log('inputs',this.searchInput);
        if (this.action == 'addNew') {
            this.warningMessage = 'You are adding a new person to the database do you want to proceed?';
        } else if (this.action == 'addPerson') {
            this.warningMessage = 'You have chosen client to add to the case, do you want to proceed?';
        }
        this.showWarning = true;

    }


    handleProcced(event) {

        if (this.action == 'addNew') {
            this.handleAddNavigate();
        } else if (this.action == 'addPerson') {
            this.selectPerson();
        }
        this.showWarning = false;
    }

    handleAddNavigate() {

        //let recordIdPrefix = this.recordId.slice(0,3);
        let inputs = this.searchInput;
        let Jn_Object_Handler = this.recordId + ',' + this.objectApiName;
        if (this.objectApiName == 'Home_Approval__c') {
            this.isLoading = true;
            getProviderId({ homeApprovalId: this.recordId })
                .then(result => {
                    this.isLoading = false;
                    this.defaultValues = encodeDefaultFieldValues({
                        Home_Approval__c: this.recordId,
                        AccountId: result
                    });
                    this[NavigationMixin.Navigate]({
                        type: 'standard__objectPage',
                        attributes: {
                            objectApiName: 'Contact',
                            actionName: 'edit',
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

            /*if (this.objectApiName == 'Case') {
                this.defaultValue.Intake__c = this.recordId;
            }
            if (this.objectApiName == 'Service_Case__c') {
                this.defaultValue.Service_Case__c = this.recordId;
                //this.defaultValue.Program_Area__c = 'In-Home Services/Family Preservation';

            }
            if (this.objectApiName == 'Investigation__c') {
                // this.defaultValue.Program_Area__c = 'CPS/IR';
                this.defaultValue.Investigation__c = this.recordId;
            }
            if(inputs.firstName) {
                this.defaultValue.FirstName = inputs.firstName;
            } else {
                this.defaultValue.FirstName = this.unVerifiedPersonRecord.FirstName;
            }
            if(inputs.lastName) {
                this.defaultValue.LastName = inputs.lastName;
            } else {
                this.defaultValue.LastName = this.unVerifiedPersonRecord.LastName;
            }
            this.defaultValue.Date_of_Birth__c = inputs.dob;
            this.defaultValue.State_Id_Drivers_License__c = inputs.stateId;
            this.defaultValue.SSN__c = inputs.ssn;
            this.defaultValue.Jn_Object_Handler__c = Jn_Object_Handler;

            this.defaultValues = encodeDefaultFieldValues(this.defaultValue);
            console.log('defaultvalue', this.defaultValues);*/

            console.log('handler========',this.unVerifiedPersonRecord.Jn_Object_Handler__c);
            if(this.unVerifiedPersonRecord.Jn_Object_Handler__c) {

                const fields = {};
                fields.Id = this.unVerifiedPersonRecord.Jn_Object_Handler__c;
                fields.Is_convert_to_select_person__c = true;
                
                const recordInput = { fields };
                updateRecord(recordInput)
                .then(() => {
                   
                    this[NavigationMixin.Navigate]({
                        type: 'standard__objectPage',
                        attributes: {
                            objectApiName: 'Contact',
                            actionName: 'edit',
                            recordId: this.unVerifiedPersonRecord.Id
                        },
                        state: {
                            recordTypeId: this.selectPersonRecordTypeId,
                            //defaultFieldValues: this.defaultValues
                        }
                    });
                    console.log('addnew');
                    this.handleCancel();
                })

            } 
            
            
            
            /*this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Contact',
                    actionName: 'edit',
                    recordId: this.unVerifiedPersonRecord.Id
                },
                state: {
                    recordTypeId: this.selectPersonRecordTypeId,
                    //defaultFieldValues: this.defaultValues
                }
            });
            console.log('addnew');
            this.handleCancel();*/
        }
    }

}