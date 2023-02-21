import { LightningElement,api,track } from 'lwc';
import getPicklist from '@salesforce/apex/PaymentSummaryController.getPickvalues';
import getRate from '@salesforce/apex/PaymentSummaryController.getRatevalues';

export default class ProviderPaymentSummary extends LightningElement {

    @api provider;
    @api placementStructurePickvalue;
    options = [];
    @track rateRecord = {};

    connectedCallback() {
        getPicklist()
        .then(res=>{
            this.options = JSON.parse(res).placementStructurePicklist; 

        })

    }
    handleChange(event) {
        let value = event.target.value;
        getRate({providerId : this.provider.Id,structure:event.target.value})
        .then(res=>{
            let result = JSON.parse(res).rateRecord;
            if(result != null) {
                this.rateRecord = result;
            } else {
                this.rateRecord = {};
            }
        })
    }
}