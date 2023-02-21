import { LightningElement, track, api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class YouthTransitionPlanShortTermGoal extends UtilityBaseElement {

    @api goalList = [];
    @track parties = [];
    @api contact = [];
    @api createLists = [];
    @api updateLists = [];
    @api deleteLists;
    @api goalRec = {};
    @track lists = [];
    @track localList = [];
    @track deleteLocalLists = [];
    showTable = false;

    connectedCallback() {

        this.list = [...this.goalList];
        this.localList = this.checkNamespaceApplicable(this.list,false);
        var contactLists = [...this.contact];
        for(let i=0; i<contactLists.length; i++) {
            var strlength = contactLists[i].length;
            var contactId = contactLists[i].slice(-18);
            var contactname = contactLists[i].slice(0,strlength-18);
            var obj = { label : contactname, value: contactId};
            this.parties.push(obj);
        }
        if(this.localList.length > 0) {
            this.showTable = true;
        } else {
            this.showTable = false;
        }
        for(let j = 0; j<this.localList.length;j++) {
            var localobj = {...this.localList[j]};
            if(localobj.Plan_of_Action__c != null) {
                localobj.actionList = localobj.Plan_of_Action__c.split(';');
            }
            this.localList[j] = localobj;
        }

        
    }

    handleAddGoal() {

        let obj = Object.assign({}, this.checkNamespaceApplicable(this.goalRec,false));
        let emptyStr = ' ';
        if(obj.actionList == null) {
            obj.actionList = [];
        }
        obj.actionList.push(emptyStr);
        this.localList.push(obj);   
        this.showTable = true; 
    }

    handlePlanOfAction(event) {

        let index = event.target.dataset.index;
        let emptyString = ' ';
        let obj = this.localList[index];
        obj.actionList.push(emptyString);
    }

    handleChange(event) {

        if(event.target.name != 'Plan_of_Action__c') {

            let index = event.target.dataset.index;
            let name = event.target.name;
            let value = event.target.value;
            this.localList[index][name] = value;
        } else if(event.target.name == 'Plan_of_Action__c') {
            
            let goalIndex = event.target.dataset.index;
            let actionIndex = event.target.dataset.actionindex;
            let value = event.target.value;
            let actions = this.localList[goalIndex]['actionList'];
            actions[actionIndex] = value;
            this.localList[goalIndex].Plan_of_Action__c = actions.join(';');
        }
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

    handleActionDelete(event) {

        let goalIndex = event.target.dataset.index;
        let actionIndex = event.target.dataset.actionindex;
        let actionList = [...this.localList[goalIndex]['actionList']];
        actionList.splice(actionIndex,1);
        this.localList[goalIndex]['actionList'] = actionList;
        this.localList[goalIndex].Plan_of_Action__c = actionList.join(';');
        this.createUpdate();
    }

}