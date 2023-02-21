import { LightningElement,track,api } from 'lwc';
import getAllPersons from '@salesforce/apex/RelationshipController.getAllPersons';
import getRelationRecord from '@salesforce/apex/RelationshipController.getRelationRecord';
import saveRelationship from '@salesforce/apex/RelationshipController.saveRelationship';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const personTable= [{label: 'Name', fieldName: 'Name', type: 'string', wrapText: true},
{label: 'DOB', fieldName: 'Date_of_Birth__c', type: 'date', wrapText: true,typeAttributes : {day:"numeric",month:"numeric",year:"numeric",timeZone:"UTC"}},
{label: 'Age', fieldName: 'Age__c', type: 'string', wrapText: true},
{label: 'Gender', fieldName: 'Gender__c', type: 'string', wrapText: true},
{label: 'Casevault PID', fieldName: 'Casevault_PID__c', type: 'string', wrapText: true},
{label: 'Caregiver', fieldName: 'Is_Caregiver__c', type:'boolean'},
{label: 'Relationship', fieldName: 'relationship', type: 'string', wrapText: true},
{ label: 'Actions', type:'button',typeAttributes: { 
   iconName:'utility:edit', name:'edit', label:'Edit', variant: 'brand'},cellAttributes: { class: { fieldName: 'hideEdit' }}},
];

export default class RelationshipLwc extends UtilityBaseElement {
    
 personTable = personTable;
 @track personRecordList = [];
 @api recordId;
 @api objectApiName;
 @track selectedRow = {};
 showModal = false;
 @track relationshipRecord = {};
 relationshipValues = [];
 loading = false;
 relationRecords = [];
 @track defaultSelectedRow = [];
 @track jnObjectRecords =[];

 connectedCallback() {

     this.doInit();
    
 }

 doInit() {

     this.loading = true;
    getAllPersons({recordId:this.recordId})
    .then(result=> {
        this.loading = false;
        let res = JSON.parse(result);
        if(res.contactList) {
            
            this.personRecordList = this.checkNamespaceApplicable(res.contactList, false);
            this.relationshipValues = res.relationshipPicklist;
            this.jnObjectRecords = res.jnObjectRecords;
            console.log('this.jnObjectRecords',this.jnObjectRecords);
            if( this.personRecordList && this.personRecordList.length > 0) {

            for(let i=0; i<this.personRecordList.length;i++) {
                let foundelement = this.jnObjectRecords.find(ele => ele.Person__c == this.personRecordList[i].Id);
                if(foundelement) {
                    console.log('found',foundelement);
                    this.personRecordList[i].Is_Caregiver__c = foundelement.Is_Caregiver__c;
                }

            }

                this.selectedRow = this.personRecordList[0];
                let lst = [];
                lst.push(this.personRecordList[0].Id);
                this.defaultSelectedRow = lst;
                this.handleRelation();
            }
        }
        
    }).catch(error => {
        this.loading=false;
        this.handleError(error); 
    })
 }

 handleRowSelection(event) {

    var selectedRows = event.detail.selectedRows;
    let length = selectedRows.length - 1;
    this.selectedRow = selectedRows[length];
    this.handleRelation(); 
}

handleRelation() {
    this.loading = true;
    let personList = [];
    getRelationRecord({personId:this.selectedRow.Id})
    .then(result=>{
        this.loading = false;
        if(result) {
            let res = this.checkNamespaceApplicable(JSON.parse(result),false);
            this.relationRecords = res;
            if(res.length > 0) {
                let relationshipMap = {};
                let caregiverMap = {};
                for(let i = 0;i<res.length;i++) {
                    relationshipMap[res[i].Person_Related_To__c] = res[i].Relationship_Values__c;
                    //caregiverMap[res[i].Person_Related_To__c] = res[i].Is_Caregiver__c;
                }
                for(let i = 0; i<this.personRecordList.length;i++){
                    let obj = {};
                    obj = this.personRecordList[i];
                    if(this.selectedRow.Id == this.personRecordList[i].Id){
                        obj.relationship = 'Self';
                        //obj.IsCaregiver = false;
                        obj.hideEdit = 'slds-hide';
                        personList.push(obj);
                    } else if(relationshipMap.hasOwnProperty(this.personRecordList[i].Id)) {
                        obj.hideEdit = false;
                        if(relationshipMap[this.personRecordList[i].Id]) {
                            obj.relationship = relationshipMap[this.personRecordList[i].Id];
                        } else {
                            obj.relationship = 'Unknown';
                        }
                        /*if(caregiverMap[this.personRecordList[i].Id]) {
                            obj.IsCaregiver = caregiverMap[this.personRecordList[i].Id];
                        } else {
                            obj.IsCaregiver = false;
                        }*/
                        personList.push(obj);
                    } else {
                        obj.relationship = 'Unknown';
                        //obj.IsCaregiver = false;
                        obj.hideEdit = false;
                        personList.push(obj);
                    }
                }
                this.personRecordList = personList;
            } else {
                for(let i = 0; i<this.personRecordList.length;i++){
                    let obj = {};
                    obj = this.personRecordList[i];
                    if(this.selectedRow.Id == this.personRecordList[i].Id){
                        obj.relationship = 'Self';
                        //obj.IsCaregiver = false;
                        obj.hideEdit = 'slds-hide';
                        personList.push(obj);
                    } else {
                        obj.relationship = 'Unknown';
                        //obj.IsCaregiver = false;
                        obj.hideEdit = false;
                        personList.push(obj);
                    }
                }
                this.personRecordList = personList;
            }
        }
       
    }).catch(error => {
        this.loading=false;
        this.handleError(error); 
    })
}

handleChange(event){
    if(event.target.name == 'Relationship_Values__c') {
        this.relationshipRecord[event.target.name] = event.target.value;
    } else {
        this.relationshipRecord[event.target.name] = event.target.checked;
    }
}

hideModal() {
    this.relationshipRecord = {};
    this.showModal = false;
}

handleRowAction(event) {

    var rowAction = event.detail.action.name;
    var row = event.detail.row;
    let foundelement = this.relationRecords.find(ele => ele.Person_Related_To__c == row.Id);
    if(rowAction == 'edit') {
        if(foundelement) {
            this.relationshipRecord = foundelement;
        } else {
            this.relationshipRecord = {};
        }
        let foundCaregiverelement = this.personRecordList.find(ele => ele.Id == row.Id);
        if(foundCaregiverelement) {
            this.relationshipRecord.Is_Caregiver__c = foundCaregiverelement.Is_Caregiver__c;
        }
        this.showModal = true;
        
    }
    this.relationshipRecord.Person_Related_To__c = row.Id;
    
}

handleSave() {
    this.relationshipRecord.Person__c = this.selectedRow.Id;
    if(this.objectApiName == 'Case') {
        this.relationshipRecord.Victim__c = this.recordId;
    } else {
        this.relationshipRecord[this.objectApiName] = this.recordId;
    }
    //this.relationshipRecord.Service_Case__c =  this.recordId;
    this.loading = true;
    saveRelationship({relationshipJSON:JSON.stringify(this.checkNamespaceApplicable(this.relationshipRecord,true)), recordId : this.recordId})
    .then(result => {
        this.loading = false;
        this.handleRelation(); 
        this.showModal = false;
        this.title = 'Success!';
        this.type = 'success';
        this.message = 'Relationship saved';
        this.fireToastMsg();
        this.doInit();
    }).catch(error => {
        this.loading=false;
        this.handleError(error); 
    })
}

handleError(error) {
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
}

}