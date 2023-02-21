import { LightningElement, track, api, wire } from 'lwc';
//import findRecords from '@salesforce/apex/CustomLookUpController.findRecords';
import getSupervisors from '@salesforce/apex/CustomLookUpController.getSupervisors';
export default class CustomLookupComponent extends LightningElement {

    @track records;
    @track error;
    @track selectedRecord;
    @api index;
    @api relationshipfield;
    @api iconname = "standard:account";
    @api objectName = 'Account';
    @api searchfield = 'Name';
    userOptions = [];
    defaultValue;

    connectedCallback() {

        getSupervisors()
        .then(result => {

            let response = JSON.parse(result);
            this.userOptions = response.pickLists;
            if(response.defaultSupervisorId) {
                this.defaultValue = response.defaultSupervisorId;
                this.handleSelect(this.defaultValue);
            }

        }).catch(error => {
            console.log('error:::',error);
        })
    }

    handleChange(event) {
          
        let selectedId = event.detail.value;
        this.handleSelect(selectedId);

    }

    handleSelect(selectedId) {

        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail : { recordId : selectedId}
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    /*handleOnchange(event){
        //event.preventDefault();
        const searchKey = event.detail.value;
        //this.records = null;
        this.handleFindRecords(searchKey);*/

        /* Call the Salesforce Apex class method to find the Records */
       
    //}

    /*handleFindRecords(searchKey) {

        findRecords({
            searchKey : searchKey, 
            objectName : this.objectName, 
            searchField : this.searchfield
        })
        .then(result => {
            this.records = result;
            for(let i=0; i < this.records.length; i++){
                const rec = this.records[i];
                this.records[i].Name = rec[this.searchfield];
            }
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.records = undefined;
        });
    }*/


    /*handleSelect(event){

        const selectedRecordId = event.detail;
        this.selectedRecord = this.records.find( record => record.Id === selectedRecordId);
        //fire the event with the value of RecordId for the Selected RecordId 
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                //detail : selectedRecordId
                detail : { recordId : selectedRecordId, index : this.index, relationshipfield : this.relationshipfield}
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }*/



    /*handleRemove(event){

        event.preventDefault();
        this.selectedRecord = undefined;
        this.records = undefined;
        this.error = undefined;
        //fire the event with the value of undefined for the Selected RecordId 
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail : { recordId : undefined, index : this.index, relationshipfield : this.relationshipfield}
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }*/

}