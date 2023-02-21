import { LightningElement, track, api } from 'lwc';
import getInit from '@salesforce/apex/ContactResourceConsultReviewController.getResourceConsultReviewRecord';
import saveRecord from '@salesforce/apex/ContactResourceConsultReviewController.saveResource';
import deleteResource from '@salesforce/apex/ContactResourceConsultReviewController.deleteResource';
import UtilityBaseElement from 'c/utilityBaseLwc';
import TIME_ZONE from '@salesforce/i18n/timeZone';

const actions = [{label:'View',name:'View'},{label:'Edit',name:'Edit'},{label:'Delete',name:'Delete'}];
const columns = [{label:'Name',fieldName:'User_Name_Type__c',wrapText:true},
            {label:'Review Date',fieldName:'Review_Date_Time__c',type:'date',typeAttributes:{
                day:"numeric",
                month:"numeric",
                year:"numeric",
                hour:"2-digit",
                minute:"2-digit",
                hour12:"true",timeZone : TIME_ZONE
            }},
            {label:'Meeting Notes',fieldName:'meetingnotes',type:'text'},
                    {type:'action',typeAttributes:{rowActions:actions}}];

export default class ContactResourceConsultReviewlwc extends UtilityBaseElement {

    @api recordId;
    @api objectApiName;
    @track resourceRec = {};
    @track resourceRecords = [];
    @track userOptions = [];
    showModal = false;
    columns = columns;
    @track saveRec = {};
    readOnly = false;
    loading = false;
    showNorecordMsg = false;
    showUserMsg = false;
    get reviewTitle() {
        if(this.resourceRecords) {
            return 'Resource Consult Review ('+this.resourceRecords.length+')';
        } else{
            return 'Resource Consult Review';
        }
    }

    connectedCallback() {

        this.doInit();
    }

    doInit() {

        this.loading = true;
        getInit({recordId:this.recordId})
        .then(result => {
            let res = JSON.parse(result);
            this.userOptions = res.userTypePicklist;
            if(res.resourceRecords.length > 0) {
                this.showNorecordMsg = false;
                this.resourceRecords = this.checkNamespaceApplicable(res.resourceRecords, false);
                for(let i = 0;i<this.resourceRecords.length;i++) {
                    if(this.resourceRecords[i].Meeting_Notes__c != null) {
                        this.resourceRecords[i].meetingnotes = this.resourceRecords[i].Meeting_Notes__c.replace(/<[^>]+>/g, '');
                    }
                }
            } else {
                this.showNorecordMsg = true;
            }
            this.loading = false;
        }).catch(error => {
            this.loading = false;
            this.errorMessage(error);
         })
    }

    handleAdd() {

        this.resourceRec = {};
        this.resourceRec.userList = [];
        this.readOnly = false;
        this.showUserMsg = true;
        this.showModal = true;
    }

    hideModal() {
        this.showModal = false;
    }

    handleChange(event) {
        this.resourceRec[event.target.name] = event.target.value;
    }

    handleAddUser() {

        if((this.resourceRec.UserName == null || this.resourceRec.UserName == '') || this.resourceRec.Select_User_Type__c == null) {
            this.title = 'Error!';
            this.type = 'error';
            this.message = 'Name & User Type should not be empty';
            this.fireToastMsg();
        } else {

            let obj = {};
            obj.id =this.resourceRec.userList.length;
            obj.username = this.resourceRec.UserName;
            obj.usertype = this.resourceRec.Select_User_Type__c;
            this.resourceRec.userList.push(obj);
            this.resourceRec.UserName = '';
        }
        if(this.resourceRec.userList.length > 0) {
            this.showUserMsg = false;
        } else if(this.resourceRec.userList.length < 0) {
            this.showUserMsg = true;
        }
        
    }

    handleDeleteUser(event) {

        let rowId = event.target.dataset.id;
        let row = this.resourceRec.userList.find(element => element.id == rowId);
        if(row) {
            let index = this.resourceRec.userList.indexOf(row);
            this.resourceRec.userList.splice(index,1);
        }
        if(this.resourceRec.userList.length > 0) {
            this.showUserMsg = false;
        } else if(this.resourceRec.userList.length < 0) {
            this.showUserMsg = true;
        }

    }

    handleSave() {

        if(this.resourceRec.Review_Date_Time__c == null || this.resourceRec.Meeting_Notes__c == null) {
            this.title = 'Error!';
            this.type = 'error';
            this.message = 'Please complete the required fields';
            this.fireToastMsg();
        } else if(this.resourceRec.userList.length == 0) {

            this.title = 'Error!';
            this.type = 'error';
            this.message = 'Add atleast one user';
            this.fireToastMsg();
        } else if(this.resourceRec.userList.length > 0) {

            var userNameType = [];
            for(let i = 0; i<this.resourceRec.userList.length;i++) {
                
                let name = this.resourceRec.userList[i].username;
                let type = this.resourceRec.userList[i].usertype;
                let nameType = name + ' - ' +type;
                userNameType.push(nameType);
            }

            this.saveRec[this.objectApiName] = this.recordId;
            this.saveRec.Id = this.resourceRec.Id != null ? this.resourceRec.Id : null;
            this.saveRec.Review_Date_Time__c = this.resourceRec.Review_Date_Time__c;
            this.saveRec.Meeting_Notes__c = this.resourceRec.Meeting_Notes__c;
            this.saveRec.User_Name_Type__c = userNameType.join(';');

            this.loading = true;
            saveRecord({resourceJSON:JSON.stringify(this.checkNamespaceApplicable(this.saveRec,true))})
            .then(result => {
                this.loading = false;
                this.title = 'Success!';
                this.type = 'success';
                this.message = 'Record saved successfully';
                this.fireToastMsg();
                this.showModal = false;
                
                this.doInit();
            }).catch(error => {

                this.loading=false;
                this.errorMessage(error);
            })
        }
        
    }

    handleRowaction(event) {

        var selectedRow = event.detail.row;
        var action = event.detail.action.name;
        if(action == 'Delete') {
            this.loading = true;
            deleteResource({recordId:selectedRow.Id})
            .then(result => {
                this.loading = false;
                if(result == 'Success') {
                    this.title = 'Success!';
                    this.type = 'success';
                    this.message = 'Record deleted successfully';
                    this.fireToastMsg();
                    this.doInit();
                }
            }).catch(error => {
                this.loading = false;
                this.errorMessage(error);
            })
        } else {

            this.resourceRec = this.resourceRecords.find(element => element.Id == selectedRow.Id);
            let getuserList = [];
            getuserList = this.resourceRec.User_Name_Type__c.split(';');
            let assignList = [];
            for(let i =0;i<getuserList.length;i++) {
                let nameType = getuserList[i].split(' - ');
                let obj = {};
                obj.id = i;
                obj.username = nameType[0];
                obj.usertype = nameType[1];
                assignList.push(obj);
            }
            this.resourceRec.userList = assignList;
            if(action == 'Edit') {
                this.readOnly = false;
                this.showModal = true;
            }
            if(action == 'View') {
                this.readOnly = true;
                this.showModal = true;
            }
        }
        
    }

    errorMessage(error) {

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