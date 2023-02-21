import { LightningElement, track, api } from 'lwc';
import updateTPR from '@salesforce/apex/PermanacyPlanAdoptionController.updateTPR';
import deleteTPR from '@salesforce/apex/PermanacyPlanAdoptionController.deleteTPR';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PermanencyPlanTPR extends UtilityBaseElement {

@api permanencyRecId;
@track isLoading = false;
@track tprList = [];
@track showAddTPRModal = false;
@track readOnly = false;
TPRPicklist = [];
@track tprRec = {};
@track tprStatus = [];



handleAddTRPModal() {

    this.tprRec = {};
    this.showAddTPRModal = true;
}

closeAddTPRModal() {
    this.showAddTPRModal = false;
}

handleChange(event) {

    let fieldType = event.target.type;
    if (fieldType != 'checkbox') {
        this.tprRec[event.target.name] = event.target.value;

    } else {
        this.tprRec[event.target.name] = event.target.checked;
    }

}

handleSave() {

    if(!this.onValidate()) {
        this.isLoading = true;
        this.tprRec.Permanency_Plan__c = this.permanencyRecId;
        updateTPR({ tprJSON : JSON.stringify(this.checkNamespaceApplicable(this.tprRec,true))})
        .then(result => {

            this.isLoading = false;
            const evt = new ShowToastEvent({
                title : 'Success',
                message : 'TPR record updated',
                variant : 'success',
                mode : 'dismissable'

            });
            this.dispatchEvent(evt);
            this.doInit();
            const stageEvent = new CustomEvent('stage');
            this.dispatchEvent(stageEvent);
            this.showAddTPRModal = false;

        }).catch(error => {

            this.isLoading=false;
            this.showAddTPRModal = false;
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
        });
    } else {

        const evt = new ShowToastEvent({
            title : 'Error',
            message : 'Required fields are missing',
            variant : 'error',
            mode : 'dismissable'

        });
        this.dispatchEvent(evt);
    }

}

handleEdit(event) {

    this.tprRec = {};
    let id = event.target.dataset.id;
    for(let i=0; i<this.tprList.length;i++) {
       
        if(this.tprList[i].Id == id) {

            this.tprRec = this.tprList[i];
        }
    }
    this.showAddTPRModal = true;
}

handleDelete(event) {

    this.isLoading = true;
    let id = event.target.dataset.id;
    deleteTPR( { tprId : id})
    .then( result => {

        this.isLoading = false;
        if( result == 'Success') {

            const evt = new ShowToastEvent({
                title : 'Success',
                message : 'TPR record deleted',
                variant : 'success',
                mode : 'dismissable'

            });
            this.dispatchEvent(evt);
            this.doInit();
        }

    }).catch(error => {

        this.isLoading=false;
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
    });
}

onValidate(){

    const allValid = [
        ...this.template.querySelectorAll("lightning-input"),...this.template.querySelectorAll("lightning-combobox"),...this.template.querySelectorAll("lightning-textarea")
        ].reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
        }, true);
        return !allValid;

}
}