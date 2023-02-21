import { LightningElement, api, track } from 'lwc';
import getPicklist from '@salesforce/apex/AssessmentController.getScoringOverridesPicklist';
import getInit from '@salesforce/apex/AssessmentController.getScoringOverridesInfo';
import saveScoringOverrides from '@salesforce/apex/AssessmentController.upsertfamilyRiskReassessment';
import UtilityBaseElement from 'c/utilityBaseLwc';

const columns = [ { label : 'Neglect Score', fieldName : 'neglectScore'}, {label : 'Abuse Score', fieldName : 'abuseScore'}, {label : 'RiskLevel', fieldName : 'riskLevel'}];

export default class ScoringOverridesLWC extends UtilityBaseElement {

    @api serviceCaseId;
    @api assessmentId;
    @api tableAction;
    columns = columns;
    @track scoreList = [{ 'id' : '1' ,'neglectScore' : '0-1', 'abuseScore' : '0-1' , 'riskLevel' : 'Low'},{ 'id' : '2' ,'neglectScore' : '2-4', 'abuseScore' : '2-4' , 'riskLevel' : 'Moderate'},
                        { 'id' : '3' ,'neglectScore' : '5-8', 'abuseScore' : '5-8' , 'riskLevel' : 'High'},{ 'id' : '4' ,'neglectScore' : '9+', 'abuseScore' : '8+' , 'riskLevel' : 'Very High'}];


    readOnly = false;
    showOverride = false;
    @track scoringAndOverridesRec = {};
    @track x1options = [];
    @track x2options = [];
    @track x3options = [];
    @track x4options = [];
    @track x5options = [];
    @track finalriskleveloptions = [];
    loading = false;

    connectedCallback() {

        this.loading = true;
        getPicklist()
        .then(result => {

            let res = JSON.parse(result);
            this.x1options = res.x1options.splice(1);
            this.x2options = res.x2options.splice(1);
            this.x3options = res.x3options.splice(1);
            this.x4options = res.x4options.splice(1);
            this.x5options = res.x5options.splice(1);
            this.finalriskleveloptions = res.finalriskleveloptions.splice(1);
            this.loading = false;
            this.doInit();
        }).catch(error => {

            this.errorMessage(error);
        });
        
    }

    doInit() {

        this.loading = true;
        getInit( { recordId : this.assessmentId})
        .then( result => {

            let res = JSON.parse(result);
            if(res.assessmentRec != null) {
                this.scoringAndOverridesRec = this.checkNamespaceApplicable(res.assessmentRec,false);
                if(this.scoringAndOverridesRec.Approval_Status__c == 'Approved') {
                    this.readOnly = true;
                } else if(this.tableAction == 'view') {
                    this.readOnly = true;
                } else if(this.tableAction == 'edit') {
                    this.readOnly = false;
                }
            }
            if(this.scoringAndOverridesRec.X5_If_yes_override_risk_level__c == 'Yes') {
                this.showOverride = true;
            }
            this.loading = false;

        }).catch(error => {

            this.errorMessage(error);
        });

    }
   
    handleChange(event) {

        this.scoringAndOverridesRec[event.target.name] = event.target.value;
        if(event.target.name == 'X5_If_yes_override_risk_level__c') {
            if(event.target.value == 'Yes') {
                this.showOverride = true;
            } else {
                this.showOverride = false;
                this.scoringAndOverridesRec.FIRA_Discretionary_override_reason__c = null;
            }
        }
    }

    handleSave() {

        this.scoringAndOverridesRec.FamilyInitialRiskAssessmentStage__c = '4';
        this.scoringAndOverridesRec.Department_is_unable_to_locate_child__c = false;

        if(!this.onValidate()) {
            this.loading = true;
            saveScoringOverrides({ familyRiskReassessmentJSON : JSON.stringify(this.checkNamespaceApplicable(this.scoringAndOverridesRec,true))})
            .then( result => {

                this.loading = false;
                this.title = 'Success!';
                this.type = 'success';
                this.message = 'Record saved successfully';
                this.fireToastMsg();
                const stageEvent = new CustomEvent('stage',{detail : { stage : '4',assRecId : result}});
                this.dispatchEvent(stageEvent);
                this.doInit();
                
                
            }) .catch(error => {

                this.errorMessage(error);
            })
        } else {

            this.title = "Error!";
            this.message = "Required fields are missing";
            this.type = "error";
            this.fireToastMsg();
        
        }
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