import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class YouthTransitionDocumentLwc extends UtilityBaseElement {

    @api assessmentList = [];
    @api assessmentRec = {};
    @track localList = [];
    @track localRec = {};
    @track changedList = [];
    @api createLists = [];
    @api updateLists = [];
    @api deleteLists;
    @track deleteLocalLists = [];
    @track list = [];

    connectedCallback() {

        this.list = [...this.assessmentList];
        this.localList = this.checkNamespaceApplicable(this.list,false);
        this.assessmentList = [];
        
        
    }
    handleChange(event) {

        let index = event.target.dataset.index;
        let name = event.target.name;
        let value = event.target.value;
        this.localList[index][name] = value;
        this.createUpdate();
       
    }

    createUpdate() {

        var checkedLists = [];
        this.createLists = [];
        this.updateLists = [];
        checkedLists = this.checkNamespaceApplicable(this.localList,true);
        for(let i =0 ; i< checkedLists.length; i++) {
            if(checkedLists[i].Id != null) {
                this.updateLists.push(checkedLists[i]);
            } else {
                this.createLists.push(checkedLists[i]);
            }
        }
        const attributeChangeEvent = new FlowAttributeChangeEvent('createLists', this.createLists);
        this.dispatchEvent(attributeChangeEvent);
        const attributeChangeEvent2 = new FlowAttributeChangeEvent('updateLists', this.updateLists);
        this.dispatchEvent(attributeChangeEvent2);
    }

    handleAdd() {

        let obj = Object.assign({}, this.checkNamespaceApplicable(this.assessmentRec,false));
        this.localList.push(obj);
        
    }

    handleDelete(event) {
        
       
        var selectedrow = event.target.dataset.rowname;
        var row = this.localList.find(element => element.Name == selectedrow);
        let rows = [...this.localList];
        rows.splice(this.localList.indexOf(row), 1);
        this.localList = rows; 
        var id = event.target.dataset.rowid;
        var deleterow = this.list.find(element => element.Id == id);
        if(deleterow != null) {

            this.deleteLocalLists.push(deleterow);
            const attributeChangeEventDelete = new FlowAttributeChangeEvent('deleteLists',this.deleteLocalLists);
            this.dispatchEvent(attributeChangeEventDelete);
        }
        this.createUpdate();
        
        
    }
}