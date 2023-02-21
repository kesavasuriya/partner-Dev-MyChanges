import { LightningElement, api, track } from 'lwc';
import getPicklist from '@salesforce/apex/TitleIvEController.getPlacementPickList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { NavigationMixin } from 'lightning/navigation';

export default class TitlePlacementLWC extends NavigationMixin(UtilityBaseElement) {
    @api titleIvERec;
    @track loading = false;
    @track placementrecord={};
    @track placementProvider={};
    
    
    connectedCallback() {

        this.loading = true;
        getPicklist()
        .then(result =>{
            this.picklist = JSON.parse(result);
        })
        this.placementrecord.Id=this.titleIvERec.Placement__c;
        if(this.titleIvERec.Placement__c != null && this.titleIvERec.Placement__r.Provider__c !=null) {
            this.placementProvider = this.titleIvERec.Placement__r.Provider__c;
        }
        this.loading = false;
    }
    handlePlacementNavigate() {

        this[NavigationMixin.Navigate]({
            type : 'standard__recordPage',
            attributes : {
                recordId : this.titleIvERec.Placement__c ,
                actionName : 'view'
            }
        });
    }
    handleSuccess(event) {
        if(this.placementrecord.Id != null) { 
        this.title = "Success!";
        this.type = "success";
        this.message = "Placement updated successfully!";
        this.fireToastMsg();
        }
    }
   
}