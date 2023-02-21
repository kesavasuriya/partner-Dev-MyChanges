import { LightningElement,  api, wire, track } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import Total_Goals_FIELD from '@salesforce/schema/Service_Plan__c.Total_Goals__c';
import Achieved_FIELD from '@salesforce/schema/Service_Plan__c.Achieved__c';
import Achieved_goals_FIELD from '@salesforce/schema/Service_Plan__c.Achieved_goals__c';
import In_Progress_FIELD from '@salesforce/schema/Service_Plan__c.In_Progress__c';
import In_Progress_goals_FIELD from '@salesforce/schema/Service_Plan__c.In_Progress_goals__c';
import Not_Achieved_FIELD from '@salesforce/schema/Service_Plan__c.Not_Achieved__c';
import Not_Achieved_goals_FIELD from '@salesforce/schema/Service_Plan__c.Not_Achieved_goals__c';

const fields = [Achieved_FIELD, Achieved_goals_FIELD, In_Progress_FIELD, In_Progress_goals_FIELD, Not_Achieved_FIELD, Not_Achieved_goals_FIELD, Total_Goals_FIELD];

export default class ServicePlanGoalProgressLWC extends UtilityBaseElement {
    @api recordId;
    @track goal;
   @wire(getRecord, { recordId: '$recordId', fields })
   dataInfos(result) { 
    if(result) {
        this.goal = result;

    }else if (result.error) {

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
    }
    
   }
    get achieved() {
        return getFieldValue(this.goal.data, Achieved_FIELD);
    }

    get totAchieved() {
        return getFieldValue(this.goal.data, Achieved_goals_FIELD);
    }

    get inProgress() {
        return getFieldValue(this.goal.data, In_Progress_FIELD);
    }

    get totInProgress() {
        return getFieldValue(this.goal.data, In_Progress_goals_FIELD);
    }
    get notAchieved() {
        return getFieldValue(this.goal.data, Not_Achieved_FIELD);
    }
    get totNotAchieved() {
        return getFieldValue(this.goal.data, Not_Achieved_goals_FIELD);
    }
    get totGoal() {
        return getFieldValue(this.goal.data, Total_Goals_FIELD);
    }

}