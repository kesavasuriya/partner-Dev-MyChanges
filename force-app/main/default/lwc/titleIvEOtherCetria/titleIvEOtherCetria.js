import { LightningElement, track, api } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class TitleIvEOtherCetria extends UtilityBaseElement {

    @api titleIvERec;
    isValid;

    onFormValidate() {

        this.isValid = this.onRequiredValidate();        
    }

    handleSubmit(event) {
        
        event.preventDefault();
        if(this.isValid) {
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
       
    }

    handleSuccess(event) {

        this.title ="Success!";
        this.type ="success";
        this.message = 'Record Updated Successfully';
        this.fireToastMsg();
        
    }

    handleError(event) {

        this.title ="Error!";
        this.type ="error";
        this.message = event.detail.detail;
        this.fireToastMsg();
    }
}