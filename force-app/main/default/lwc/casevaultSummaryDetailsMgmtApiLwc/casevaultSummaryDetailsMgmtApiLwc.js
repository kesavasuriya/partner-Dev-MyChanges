import { LightningElement, track, api } from 'lwc';
import getSummaryDetailsRec from '@salesforce/apex/CaseVaultCalloutHandler.getAllSummaryDetails';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class CasevaultSummaryDetailsMgmtApiLwc extends UtilityBaseElement {

    @track paymentDetailData = [];
    @api summaryId;
    @track visibleData = [];
    showChild = false;

    connectedCallback() {

        this.doInitInfo();
    }

    renderedCallback() {
        this.doInitInfo();
    }
    doInitInfo() {

        this.showChild = false;
        getSummaryDetailsRec({summaryId: parseInt(this.summaryId)})
        .then(result => {
            let res = JSON.parse(result);
            this.paymentDetailData = res.data;
            this.showChild = true;
         }).catch(error => {

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
        }) 
    } 
    paginationHandler(event) {

        this.visibleData = [...event.detail.records];     
    }
}