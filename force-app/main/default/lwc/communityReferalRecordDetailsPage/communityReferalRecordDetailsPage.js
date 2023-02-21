import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
const fields = [Name, Referal_status__c, Converted__c];

export default class CommunityReferalRecordDetailsPage extends LightningElement {
    @api referralId = 'a095w000011LOnrAAG';
    fields = fields;

    @wire(getRecord, {
        recordId: this.referralId,
        fields
      })
      refferal;
    
      /*renderedCallback() {
      }*/
}