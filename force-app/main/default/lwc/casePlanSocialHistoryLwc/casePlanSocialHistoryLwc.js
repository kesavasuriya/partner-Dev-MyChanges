import { LightningElement, api, track } from 'lwc';
import getSocialHistoryRec from '@salesforce/apex/CasePlanController.getSocialHistoryRecord';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class CasePlanSocialHistoryLwc extends UtilityBaseElement {

    @api recordId;
    @track socialHistoryRecord = {};
    @track loading = false;

    connectedCallback() {

        this.doInit();
    }

    doInit() {

        this.loading = true;
        getSocialHistoryRec({ casePlanVersionId: this.recordId })
            .then(result => {
                let res = JSON.parse(result);
                this.socialHistoryRecord = res;
                this.loading = false;
            }).catch(error => {

                this.loading = false;
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
            });


    }
}