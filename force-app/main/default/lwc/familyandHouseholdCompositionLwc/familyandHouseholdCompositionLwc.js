import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import formatfordate from '@salesforce/resourceUrl/formatfordate';
import getInit from '@salesforce/apex/AssessmentController.getFamilyAndHouseholdCompositionInfo';
import savefamilyRiskReassessment from '@salesforce/apex/AssessmentController.upsertfamilyRiskReassessment';
import UtilityBaseElement from 'c/utilityBaseLwc';

const childColumns = [ {label : 'Name' , fieldName : 'Name'},
{label : 'DOB' , fieldName : 'Date_of_Birth__c',type:'date',typeAttributes:{ month: 'numeric', day: 'numeric', year: 'numeric', timeZone:'UTC'}},
{label : 'Relationship' , fieldName : 'Intake_Person_Role__c'},{label : 'Primary Caregiver' , fieldName : ''},
                {label : ' ', type: 'button' , typeAttributes : {label :' ', iconName : 'utility:close' , name : 'close'}}];

export default class FamilyandHouseholdCompositionLwc extends UtilityBaseElement {

    @api serviceCaseId;
    @api objectApiName;
    @api assessmentId;
    @api tableAction;
    @track assessmentRec = {};
    @track childList = [];
    @track serviceCaseRec = {};
    childColumns = childColumns;
    readOnly = false;
    loading = false;
    

    connectedCallback() {

        this.loading = true;
        loadScript(this, momentForTime),loadScript(this, formatfordate)
        .then( () => {

            this.loading = false;
            this.doInit();
        }).catch(error => {

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
         })
    }

    doInit() {

        this.loading = true;
        getInit({serviceCaseId:this.serviceCaseId,assesmentRecId:this.assessmentId, objectApiName : this.objectApiName})
        .then(result => {

            let res = JSON.parse(result);
            this.childList = this.checkNamespaceApplicable(res.conactList, false);
            if(this.objectApiName == 'Service_Case__c') {
                this.serviceCaseRec = this.checkNamespaceApplicable(res.serviceCaseRec, false);
            } else if(this.objectApiName == 'Investigation__c') {
                this.serviceCaseRec = this.checkNamespaceApplicable(res.investigationRec, false);
            }
            if(this.serviceCaseRec.Head_of_Household__c != null) {
                this.serviceCaseRec.headOfHousehold = this.serviceCaseRec.Head_of_Household__r.Name;
            }
            if(res.assessmentRec != null) {
                this.assessmentRec = this.checkNamespaceApplicable(res.assessmentRec,false);
                if(this.assessmentRec.Approval_Status__c == 'Approved') {
                    this.readOnly = true;
                } else if(this.tableAction == 'view') {
                    this.readOnly = true;
                } else if(this.tableAction == 'edit') {
                    this.readOnly = false;
                }
            }
            //this.formatedDateTime = moment.tz(this.assessmentRec.FRRE_Date_Assessment_Initiated__c,"America/Los_Angeles").format('MM/DD/YYYY, h:mm a');
            
            this.loading = false;

        }).catch(error => {

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
         })
    }

    handleRowAction(event) {

        var selectedrow = event.detail.row;
        var row = this.childList.find(element => element.Id == selectedrow.Id);
        let rows = [...this.childList];
        rows.splice(this.childList.indexOf(row), 1);
        this.childList = rows;         
    }

    handleSave() {

        this.assessmentRec[this.objectApiName] = this.serviceCaseId;
        this.assessmentRec.Assessment_Type__c = 'Family Initial Risk Assessment';
        this.assessmentRec.FamilyInitialRiskAssessmentStage__c = '2';
        this.assessmentRec.Department_is_unable_to_locate_child__c = false;
        this.loading = true;
        savefamilyRiskReassessment({ familyRiskReassessmentJSON : JSON.stringify(this.checkNamespaceApplicable(this.assessmentRec,true))})
        .then( result => {

            this.loading = false;
            this.title = 'Success!';
            this.type = 'success';
            this.message = 'Record saved successfully';
            this.fireToastMsg();
            const stageEvent = new CustomEvent('stage',{detail : { stage : '2',assRecId : result}});
            this.dispatchEvent(stageEvent);
            this.doInit();
            
            
        }) .catch(error => {

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
        })
        

    }
    handleChange(event) {
        this.assessmentRec[event.target.name] = event.target.value;
    }
}