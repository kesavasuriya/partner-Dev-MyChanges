import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import YTP_OBJECT from '@salesforce/schema/Youth_Participants__c';
import UtilityBaseElement from 'c/utilityBaseLwc';
import Service_CaseYP_FIELD from '@salesforce/schema/Youth_Participants__c.Service_Case__c';
import YTP_FIELD from '@salesforce/schema/Youth_Participants__c.Youth_Transition_Plan__c';
import Service_Case_FIELD from '@salesforce/schema/Youth_Transition_Plan__c.Service_Case__c';
const fields = [Service_Case_FIELD];


export default class YouthParticipants extends NavigationMixin(UtilityBaseElement) {

    @api recordId;
    @track youthTransitionPlan;
    @wire(getRecord, { recordId: '$recordId', fields })
    dataInfos(result) { 
        if(result) {
            this.youthTransitionPlan = result;
    
        }else if (result.error) {
        }
        
    }
    get serviceCaseId() {
        return getFieldValue(this.youthTransitionPlan.data, Service_Case_FIELD);
    }

   
    handleAddParticipant() {
        var serviceCaseYP = Service_CaseYP_FIELD.fieldApiName;
        var ytp = YTP_FIELD.fieldApiName;
        var obj = {};
        obj[serviceCaseYP] = this.serviceCaseId;
        obj[ytp] = this.recordId;
        const defaultValues = encodeDefaultFieldValues(obj);
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: YTP_OBJECT.objectApiName,
                actionName: 'new'
            },state: {
                defaultFieldValues: defaultValues
            }
        });
    }
       
}