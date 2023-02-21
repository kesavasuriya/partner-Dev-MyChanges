import { LightningElement,track, api } from 'lwc';
import getInit from '@salesforce/apex/AssessmentController.getActionInfo';
import saveAction from '@salesforce/apex/AssessmentController.upsertfamilyRiskReassessment';

import UtilityBaseElement from 'c/utilityBaseLwc';

export default class AssessmentActionTaken extends UtilityBaseElement {

    @api serviceCaseId;
    @api objectApiName;
    @api assessmentId;
    @api tableAction;
    @track actionRec = {};
    loading = false;
    readOnly = false;

    connectedCallback() {
        this.doInit();
    }

    doInit() {

        this.loading = true;
        getInit({recordId:this.assessmentId})
        .then(result => {

            let res = JSON.parse(result);
            if(res.assessmentRec != null) {
                this.actionRec = this.checkNamespaceApplicable(res.assessmentRec, false);
            }
            if(this.actionRec.Approval_Status__c == 'Approved') {
                this.readOnly = true;
            }else if(this.tableAction == 'view') {
                this.readOnly = true;
            } else if(this.tableAction == 'edit') {
                this.readOnly = false;
            }
            this.loading = false;
        }).catch(error => {

            this.errorMessage(error);
        });
    }

    handleSave() {

        this.actionRec.Department_is_unable_to_locate_child__c = true;
        this.actionRec[this.objectApiName] = this.serviceCaseId;
        this.actionRec.Assessment_Type__c = 'Family Initial Risk Assessment';
        if(!this.onValidate()) {
            this.loading = true;
            saveAction({ familyRiskReassessmentJSON : JSON.stringify(this.checkNamespaceApplicable(this.actionRec,true))})
            .then( result => {

                this.loading = false;
                this.title = 'Success!';
                this.type = 'success';
                this.message = 'Record saved successfully';
                this.fireToastMsg();
                this.doInit();
                const stageEvent = new CustomEvent('stage',{detail : { stage : 'action',assRecId : result}});
                this.dispatchEvent(stageEvent);
                
            }) .catch(error => {

                this.errorMessage(error);
            })
        }else {

            this.title = "Error!";
            this.message = "Required fields are missing";
            this.type = "error";
            this.fireToastMsg();
        
        }
    }

    handleChange(event) {
        this.actionRec[event.target.name] = event.target.value;
    }

    errorMessage(error) {

        this.loading = false;
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
    }
}