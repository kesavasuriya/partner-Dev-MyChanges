import { LightningElement, track, api } from 'lwc';
import getRecords from '@salesforce/apex/PersonTileViewController.getPersons';
import UNKNOWN_LOGO from '@salesforce/resourceUrl/unknownpersonImg';
import { NavigationMixin } from 'lightning/navigation';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { deleteRecord } from 'lightning/uiRecordApi';


export default class PersonTileListLwc extends NavigationMixin(UtilityBaseElement) {

    @track subscription = {};
    @track subscription1 = {};
    contactChannel = '/event/Refresh_Person__e';
    @api recordId;
    @api objectApiName;
    @api personType;
    @api borderSize;
    @api activeColor;
    @api inactiveColor;
    @track personList=[];
    @track placementList=[];
    @track courtHearingList=[];
    @track programAssignmentList=[];
    @track activePersonList = [];
    @track inActivePersonList = [];
    @track childRemovalList = [];
    @track visibleDataList = [];
    @track legalCustodyRecords = [];
    @track titleIveRecords = [];
    unknownImg = UNKNOWN_LOGO;
    @track isIntake = false;
    @track loading = false;
    @track jnAction;
    @track contactAction;
    @track res;

    get showTielView() {
        if(this.visibleDataList.length != null && this.visibleDataList.length ) {
            return true;
        } else {
            return false;
        }
    }

    get showDelete() {
        if(this.objectApiName == 'Case') {
            return true;
        } else {
            return false;
        }
    }
    connectedCallback() {


        subscribe(this.contactChannel, -1, this.refreshValue).then(response => {
            this.subscription1 = response;
        });
        onError(error => {});

        if(this.objectApiName == 'Case') {
            this.isIntake = true;
        }
        document.documentElement.style.setProperty('--border',this.borderSize);
        document.documentElement.style.setProperty('--activecolor',this.activeColor);
        document.documentElement.style.setProperty('--inactivecolor',this.inactiveColor);
        this.doInit();
    }

    refreshValue = (res) => {

        this.doInit();

    }
   
    doInit() {

        this.loading = true;
        this.personList = [];
        this.visibleDataList = [];
        this.activePersonList = [];
        this.inActivePersonList = [];
        getRecords({recordId : this.recordId, objectApiName : this.objectApiName})
        .then(result =>{
            this.personList = JSON.parse(result).personRecords;
            this.placementList = JSON.parse(result).placementRecords;
            this.programAssignmentList = JSON.parse(result).programAssignmentRecords;
            this.childRemovalList = JSON.parse(result).childRemovalRecords;
            this.legalCustodyRecords = JSON.parse(result).legalCustodyRecords;
            this.courtHearingList = JSON.parse(result).courtHearingRecords;
            this.titleIveRecords = JSON.parse(result).titleIVeRecords;
            console.log('PersonList',this.personList);
            if(this.personList !=null) {

                if(this.isIntake == false) {
                for(let i=0;i<this.placementList.length;i++){
                    let foundelement = this.personList.find(ele => ele.Person__c == this.placementList[i].Child__c);
                        if (foundelement) {
                            foundelement.placementName = this.placementList[i].Name;
                            foundelement.placementStartDate = this.placementList[i].Begin_Date__c;
                            foundelement.placementId = this.placementList[i].Id;
                            foundelement.Placement_Structure__c = this.placementList[i].Placement_Structure__c;
                            if(foundelement.Provider__c != null && Provider__r.BillingAddress != null) {
                                foundelement.BillingState = this.placementList[i].Provider__r.BillingState;
                                foundelement.BillingCity = this.placementList[i].Provider__r.BillingCity;
                                foundelement.BillingCountry = this.placementList[i].Provider__r.BillingCountry;
                                foundelement.BillingStreet = this.placementList[i].Provider__r.BillingStreet;
                                foundelement.BillingPostalCode = this.placementList[i].Provider__r.BillingPostalCode;
                            }
                            this.personList = [...this.personList];
                        } 
                }
            }

                for(let i=0;i<JSON.parse(result).personRecords.length;i++){
                    if(this.personList[i].Person__r.Address_Line_1__c != null) {
                        this.personList[i].street = this.personList[i].Person__r.Address_Line_1__c;
                    }
                    if(this.personList[i].Person__r.Address_Line_2__c != null) {
                        this.personList[i].street += ' '+ this.personList[i].Person__r.Address_Line_2__c;
                    }
                    if(this.personList[i].Person__r.Person_Image_URL__c != null) {
                        this.personList[i].showImg = true;
                    } else {
                        this.personList[i].showImg = false;
                    }
                    if(this.isIntake == false) {
                        let pafoundelement = this.programAssignmentList.find(ele => ele.Contact__c == this.personList[i].Person__c);
                        let crfoundelement = this.childRemovalList.find(ele => ele.Child__c == this.personList[i].Person__c);
                        let lcfoundelement = this.legalCustodyRecords.find(ele => ele.Child_Name__c == this.personList[i].Person__c);
                        let chfoundelement = this.courtHearingList.find(ele => ele.Court__r.Petition_for_Child__c == this.personList[i].Person__c);
                        let Ivefoundelement = this.titleIveRecords.find(ele => ele.Child_Removal__r.Child__c == this.personList[i].Person__c);
                        if(chfoundelement) {
                            this.personList[i].courtDate = chfoundelement.Hearing_Date_and_Time__c;
                        }

                        if(lcfoundelement) {
                            this.personList[i].legalCustodytDate = lcfoundelement.Begin_Date__c;
                        }

                        if(Ivefoundelement) {
                            this.personList[i].titleIveStatus = Ivefoundelement.Status__c;
                        }
                        if (crfoundelement) {
                            this.personList[i].RemovalDate = crfoundelement.Removal_Date_of_DT_F__c;
                            this.personList[i].caregiver = crfoundelement.Primary_Caregiver__r.Name;
                            if(crfoundelement.Removal_End_Date_Time__c == null) {
                                this.personList[i].removalbadge = 'slds-badge slds-theme_success';
                                this.personList[i].removalStatus = 'Open';
                                this.personList[i].border = 'slds-box activecolor';
                                this.personList[i].RemovalEndDate = crfoundelement.Removal_End_Date_Time__c;

                            } else {
                                this.personList[i].removalbadge = 'slds-badge slds-theme_error';
                                this.personList[i].removalStatus = 'Closed';
                                this.personList[i].border = 'slds-box inActivecolor';
                            }
                        } else {
                            this.personList[i].border = 'slds-box inActivecolor';
                        }
                        if (pafoundelement) {
                            this.activePersonList.push(this.personList[i]);
                        } else {
                            this.personList[i].border = 'slds-box inActivecolor';
                            this.inActivePersonList.push(this.personList[i]);
                        }
                        pafoundelement={};
                        crfoundelement={};
                    } 
                    if(this.isIntake == true) {
                        this.personList[i].border = 'slds-box inActivecolor';
                    } 
                    if(this.personList[i].Person__r.Date_of_Death__c != null) {
                        this.personList[i].border = 'slds-box death';
                    }
    
                }
                if(this.personType == 'Inactive Persons' && this.isIntake == false) {
                    this.visibleDataList = this.inActivePersonList;
                } else if(this.personType == 'Active Persons' && this.isIntake == false) {

                    this.visibleDataList = this.activePersonList;
                }  else {
                    
                    this.visibleDataList = this.personList;
                }
        }
        const countEvent = new CustomEvent("count",{detail:this.visibleDataList.length});
                    this.dispatchEvent(countEvent);
            this.jnAction='';
            this.contactAction='';
            this.loading = false;
        })

    }

    handlePersonNavigate(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.currentTarget.dataset.id,
                objectApiName: 'Contact',
                actionName: 'view'
            },
        });
    }

    

    handleChildRemovalNavigate(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: event.currentTarget.dataset.id,
                objectApiName: 'Child_Removal__c',
                relationshipApiName: 'Child_Removals__r',
                actionName: 'view'
            },
        });
    }

    handleCourtNavigate(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: event.currentTarget.dataset.id,
                objectApiName: 'Court__c',
                relationshipApiName: 'Petitions__r',
                actionName: 'view'
            },
        });
    }

    handlePlacementNavigate(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.currentTarget.dataset.id,
                objectApiName: 'Placement__c',
                actionName: 'view'
            },
        });
    }

    handleLegalCustodyNavigate(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: event.currentTarget.dataset.id,
                objectApiName: 'Legal_Custody__c',
                relationshipApiName: 'Legal_Custodys__r',
                actionName: 'view'
            },
        });
    }

    handleProgramAreaNavigate(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: event.currentTarget.dataset.id,
                objectApiName: 'Program_Assignment__c',
                relationshipApiName: 'Program_Assignments__r',
                actionName: 'view'
            },
        });
    }

    handleDelete(event) {

        deleteRecord(event.currentTarget.dataset.id)
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
    handleRoleEdit(event) {

        this.handleRoleNavigation(event.currentTarget.dataset.id);
    }

    handleRoleNavigation(recId) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: 'Person__c',
                actionName: 'edit'
            },
        });
    }


}