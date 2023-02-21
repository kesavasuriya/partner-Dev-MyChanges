import { LightningElement, api, track } from 'lwc';
import initInfo from '@salesforce/apex/AssessmentController.getFamilyRiskReassessmentInfo';
import savefamilyRiskReassessment from '@salesforce/apex/AssessmentController.upsertfamilyRiskReassessment';
import submitSuperApproval from '@salesforce/apex/AssessmentController.onSubmitForApproval';
import deleteAssessment from '@salesforce/apex/AssessmentController.deleteAssessment';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import formatfordate from '@salesforce/resourceUrl/formatfordate';
import UtilityBaseElement from 'c/utilityBaseLwc';

const actions = [
     { label: 'Delete', name: 'delete'}   
];
const dataColumn = [{ label: 'Assessment Name', type:  'button',typeAttributes: { 
    variant :'base', name : 'name',
             label:   { 
        fieldName: 'Name' 
    } }},
    {label: 'Date Assessment Initiated', fieldName:'FRRE_Date_Assessment_Initiated__c',type:'date',typeAttributes:{day:"numeric",month:"numeric",year:"numeric",hour:"numeric",minute:"numeric",hour12:"true"}},
    {label:'Approval Status',fieldName:'Approval_Status__c'},
                    { type: 'action', typeAttributes: { rowActions: actions} }];
const columns = [ {label : 'Final Risk Level', fieldName : 'finalRiskLevel'},{label : 'Recommendation', fieldName : 'recommendation'}]
const childColumns = [ {label : 'Name' , fieldName : 'Name'},{label : 'DOB' , fieldName : 'Date_of_Birth__c'},{label : 'Age' , fieldName : 'Age__c'},{label : 'Relationship' , fieldName : ''},
                {label : ' ', type: 'button' , typeAttributes : {label :' ', iconName : 'utility:close' , name : 'close', disabled : { fieldName : 'disableCancel'}}}];

export default class FamilyriskAssessmentHeading extends UtilityBaseElement {

    @api recordId;
    @api objectApiName;
    columns = columns;
    childColumns = childColumns;
    dataColumn = dataColumn;
    @track familyRiskReassessmentRec = {};
    @track RR1options = [];
    @track RR2options = [];
    @track RR3options = [];
    @track RR4options = [];
    @track RR5options = [];
    @track RR6options = [];
    @track RR7options = [];
    @track RR7Yesoptions = [];
    @track RR8options = [];
    @track RR9options = [];
    @track riskLevelOptions = [];
    @track x1options = [];
    @track x2options = [];
    @track x3options = [];
    @track x4options = [];
    @track x5options = [];
    @track finalriskleveloptions = [];
    @track recommendedDecisionList = [{'id' : '1' , 'finalRiskLevel' : 'Low' , 'recommendation' : 'Close*'},{'id' : '2' , 'finalRiskLevel' : 'Moderate' , 'recommendation' : 'Close*'},{'id' : '3' , 'finalRiskLevel' : 'High' , 'recommendation' : 'Continue Services'},{'id' : '4' , 'finalRiskLevel' : 'Very High' , 'recommendation' : 'Continue Services'}];
    @track plannedActionOptions = [];
    @track approvalOptions = [];
    @track routeToSupervisorOptions = [];
    @track serviceCaseInvestigationRec = {};
    @track selectedRR4 = [];
    @track selectedValueRR4 = [];
    showRR7Yesoptions = false;
    @track selectedRR7Yesoptions = [];
    @track selectedValueRR7Yesoptions = [];
    showOverride = false;
    loading = false;
    formatedDateTime;
    childList = [];
    savedRec = false;
    showApprovalScreen = false;
    supervisorId = '';
    enableSubmit = true;
    readOnly = false;
    showList = true;
    @track assessmentList = [];
    showMsg = false;
    approvalRecordId;

    get heading() {
        if(this.assessmentList) {
            return 'FAMILY RISK REASSESSMENTS ('+this.assessmentList.length+')';
        } else {
            return 'FAMILY RISK REASSESSMENTS';
        }
    }

    connectedCallback() {

        loadScript(this, momentForTime),loadScript(this, formatfordate)
        .then( () => {
            this.doInit();
        })
        
    }

    doInit() {

        this.loading = true;
        initInfo({ recordId:this.recordId, objectApiName : this.objectApiName})
        .then(result => {

            let res = JSON.parse(result);
            this.RR1options = res.RR1options.splice(1);
            this.RR2options = res.RR2options.splice(1);
            this.RR3options = res.RR3options.splice(1);
            this.RR4options = res.RR4options;
            this.RR5options = res.RR5options.splice(1);
            this.RR6options = res.RR6options.splice(1);
            this.RR7options = res.RR7options.splice(1);
            this.RR7Yesoptions = res.RR7Yesoptions;
            this.RR8options = res.RR8options.splice(1);
            this.RR9options = res.RR9options.splice(1);
            this.riskLevelOptions = res.riskLevelOptions.splice(1);
            this.x1options = res.x1options.splice(1);
            this.x2options = res.x2options.splice(1);
            this.x3options = res.x3options.splice(1);
            this.x4options = res.x4options.splice(1);
            this.x5options = res.x5options.splice(1);
            this.finalriskleveloptions = res.finalriskleveloptions.splice(1);
            this.plannedActionOptions = res.plannedActionOptions.splice(1);
            this.approvalOptions = res.approvalOptions;
            this.routeToSupervisorOptions = res.routeToSupervisorOptions;
            if(this.objectApiName == 'Service_Case__c') {
                this.serviceCaseInvestigationRec = this.checkNamespaceApplicable(res.serviceCaseRec,false);
            } else if(this.objectApiName == 'Investigation__c') {
                this.serviceCaseInvestigationRec = this.checkNamespaceApplicable(res.investigationRec,false);
            }
            this.childList = this.checkNamespaceApplicable(res.conactList,false);
            if(this.childList.length>0) {
                for(let i=0;i<this.childList.length;i++){
                    this.childList[i].Date_of_Birth__c = moment(this.childList[i].Date_of_Birth__c).format('MM/DD/YYYY');
                }
            }
            if(this.serviceCaseInvestigationRec.Head_of_Household__c != null) {
                this.serviceCaseInvestigationRec.headOfHousehold = this.serviceCaseInvestigationRec.Head_of_Household__r.Name;
            }
            if(res.familyRiskReassessmentRec.length > 0) {
                this.assessmentList = this.checkNamespaceApplicable(res.familyRiskReassessmentRec,false);
                this.showMsg = false;
            } else if (res.familyRiskReassessmentRec.length <= 0) {
                this.assessmentList = [];
                this.showMsg = true;
            }

            if(this.assessmentList.length > 0 ) {
                for(let i =0; i < this.assessmentList.length ; i++) {
                    this.familyRiskReassessmentRec = this.assessmentList[i];
                   // this.familyRiskReassessmentRec.formatedDateTime = moment.tz(this.familyRiskReassessmentRec.FRRE_Date_Assessment_Initiated__c,"America/Los_Angeles").format('MM/DD/YYYY, hh:mm A');
                    
                }
            }
            
            
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

    handleChange(event) {

        let targetName = event.target.name;
        let targetValue = event.target.value;
        let targetType = event.target.type;
        //this.familyRiskReassessmentRec.FINAL_RISK_LEVEL__c = this.familyRiskReassessmentRec.RISK_LEVEL__c;   
        
        if(targetName != 'Characteristics_of_children_household__c' && targetName != 'Yes_problems_with_adult_r__c' && targetType != 'checkbox') {
            this.familyRiskReassessmentRec[targetName] = targetValue;
        }

        if(targetType == 'checkbox') {
            this.familyRiskReassessmentRec[targetName] = event.target.checked;
        }
        
        if(targetName == 'Household_previously_received_CPS__c') {

            if(targetValue == 'None(0)') {
                this.familyRiskReassessmentRec.RR1_Score__c = 0;
            } else if(targetValue == 'One(1)') {
                this.familyRiskReassessmentRec.RR1_Score__c = 1;
            }     
        }

        if(targetName == 'Prior_CPS_response_IR_AR__c') {

            if(targetValue == 'None(0)') {
                this.familyRiskReassessmentRec.RR2_Score__c = 0;
            } else if(targetValue == 'One(1)') {
                this.familyRiskReassessmentRec.RR2_Score__c = 1;
            } else if(targetValue == 'Two or More(2)') {
                this.familyRiskReassessmentRec.RR2_Score__c = 2;
            }      
        }

        if(targetName == 'Primary_caregiver_has_a_history_of_abuse__c') {

            if(targetValue == 'No(0)') {
                this.familyRiskReassessmentRec.RR3_Score__c = 0;
            } else if(targetValue == 'Yes(1)') {
                this.familyRiskReassessmentRec.RR3_Score__c = 1;
            }     
        }

        if(targetName == 'Characteristics_of_children_household__c') {
            this.selectedRR4 = targetValue;
            this.familyRiskReassessmentRec.RR4changed = true;
            if(this.selectedRR4.includes('None of the above (0)')) {
                this.selectedValueRR4 = ['None of the above (0)'];
                this.selectedRR4 = ['None of the above (0)'];
                this.familyRiskReassessmentRec.RR4_Score__c = 0;
            } else {
                this.familyRiskReassessmentRec.RR4_Score__c = this.selectedRR4.length;
            }
        }

        if(targetName == 'New_CPS_response_of_abuse_or_neglect__c') {

            if(targetValue == 'No(0)') {
                this.familyRiskReassessmentRec.RR5_Score__c = 0;
            } else if(targetValue == 'Yes(1)') {
                this.familyRiskReassessmentRec.RR5_Score__c = 1;
            }     
        }

        if(targetName == 'Primary_caregiver_alcohol_or_substance__c') {

            if(targetValue == 'Yes, alcohol or substance abuse problem; problem is not being addressed(1)') {
                this.familyRiskReassessmentRec.RR6_Score__c = 1;
            } else {
                this.familyRiskReassessmentRec.RR6_Score__c = 0;
            }     
        }

        if(targetName == 'Adult_relationships_since_the_MFIRA__c') {

            this.selectedRR7Yesoptions = targetValue;
            if(targetValue == 'Yes, problems with adult relationships (select all that apply) (1)') {
                this.showRR7Yesoptions = true;
            } else {
                this.showRR7Yesoptions = false;
                this.selectedRR7Yesoptions = [];
                this.selectedValueRR7Yesoptions = [];
                this.familyRiskReassessmentRec.RR7_Score__c = 0;
            }     
        }

        if(targetName == 'Yes_problems_with_adult_r__c') {

            this.selectedRR7Yesoptions = targetValue;
            this.familyRiskReassessmentRec.RR7changed = true;
            if(this.selectedRR7Yesoptions.length > 0) {
                this.familyRiskReassessmentRec.RR7_Score__c = 1;
            }       
        }

        if(targetName == 'Primary_caregiver_mental_health__c') {

            if(targetValue == 'Yes, mental health problem; problem is NOT being addressed (1)') {
                this.familyRiskReassessmentRec.RR8_Score__c = 1;
            } else {
                this.familyRiskReassessmentRec.RR8_Score__c = 0;
            }     
        }

        if(targetName == 'Primary_caregiver_provides_physical_care__c') {

            if(targetValue == 'Yes (0)') {
                this.familyRiskReassessmentRec.RR9_Score__c = 0;
            } else {
                this.familyRiskReassessmentRec.RR9_Score__c = 1;
            }     
        }

        if(this.familyRiskReassessmentRec.Does_not_Demonstrate_Primary_Caregiver__c == true || this.familyRiskReassessmentRec.Does_not_Demonstarte_Secondary_Caregiver__c == true) {

            this.familyRiskReassessmentRec.Does_not_demonstrate_Score__c = 1;
        } else if(!(this.familyRiskReassessmentRec.Does_not_Demonstrate_Primary_Caregiver__c == true || this.familyRiskReassessmentRec.Does_not_Demonstarte_Secondary_Caregiver__c == true)) {
            this.familyRiskReassessmentRec.Does_not_demonstrate_Score__c = 0;
        }

        this.familyRiskReassessmentRec.Total_Score__c = parseInt(this.familyRiskReassessmentRec.RR1_Score__c) + parseInt(this.familyRiskReassessmentRec.RR2_Score__c) + parseInt(this.familyRiskReassessmentRec.RR3_Score__c) + parseInt(this.familyRiskReassessmentRec.RR4_Score__c) + parseInt(this.familyRiskReassessmentRec.RR5_Score__c) +
                                                        parseInt(this.familyRiskReassessmentRec.RR6_Score__c) + parseInt(this.familyRiskReassessmentRec.RR7_Score__c) + parseInt(this.familyRiskReassessmentRec.RR8_Score__c) + parseInt(this.familyRiskReassessmentRec.RR9_Score__c) + parseInt(this.familyRiskReassessmentRec.RR10_Score__c) +
                                                        parseInt(this.familyRiskReassessmentRec.Does_not_demonstrate_Score__c) + parseInt(this.familyRiskReassessmentRec.No_Secondary_Score__c) ;

        if(this.familyRiskReassessmentRec.Total_Score__c >= 0) {
            if(this.familyRiskReassessmentRec.Total_Score__c >= 8) {
                this.familyRiskReassessmentRec.RISK_LEVEL__c = 'Very High';
            } else if(this.familyRiskReassessmentRec.Total_Score__c >= 5) {
                this.familyRiskReassessmentRec.RISK_LEVEL__c = 'High';
            } else if(this.familyRiskReassessmentRec.Total_Score__c >= 2) {
                this.familyRiskReassessmentRec.RISK_LEVEL__c = 'Moderate';
            } else {
                this.familyRiskReassessmentRec.RISK_LEVEL__c = 'Low';
            }
        }  
          
        
        if(targetName == 'X5_If_yes_override_risk_level__c') {
            if(targetValue == 'Yes') {
                this.showOverride = true;
            } else {
                this.familyRiskReassessmentRec.FINAL_RISK_LEVEL__c = this.familyRiskReassessmentRec.RISK_LEVEL__c;
                this.familyRiskReassessmentRec.FIRA_Discretionary_override_reason__c = ''; 
                this.showOverride = false;
            }
        }

    }

    handleSave() {

        this.familyRiskReassessmentRec[this.objectApiName] = this.recordId;
        this.familyRiskReassessmentRec.Assessment_Type__c = 'Family risk Reassessment';
        this.familyRiskReassessmentRec.Characteristics_of_children_household__c = this.familyRiskReassessmentRec.RR4changed == true ?  this.selectedRR4.join(';') : this.selectedValueRR4.join(';');
        this.familyRiskReassessmentRec.Yes_problems_with_adult_r__c =this.familyRiskReassessmentRec.RR7changed == true ? this.selectedRR7Yesoptions.join(';') : this.selectedValueRR7Yesoptions.join(';');
        this.savedRec = false;
        if(!this.onValidate()) {

            this.loading = true;
            savefamilyRiskReassessment({ familyRiskReassessmentJSON : JSON.stringify(this.checkNamespaceApplicable(this.familyRiskReassessmentRec,true))})
            .then( result => {
                this.loading = false;
                this.title = 'Success!';
                this.type = 'success';
                this.message = 'Record saved successfully';
                this.fireToastMsg();
                this.approvalRecordId = result;
                this.savedRec = true;
                this.doInit();
                this.showList = true;
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
            
        } else {

            this.title = "Error!";
            this.message = "Required fields are missing";
            this.type = "error";
            this.fireToastMsg();
        
        }

    }

    handleRowAction(event) {

        var selectedrow = event.detail.row;
        var row = this.childList.find(element => element.Id == selectedrow.Id);
        let rows = [...this.childList];
        rows.splice(this.childList.indexOf(row), 1);
        this.childList = rows;         
    }

    handleApproval() {

        if(this.familyRiskReassessmentRec.Approval_Status__c == 'Approved') {

            this.title = "Error!";
            this.message = "Family Risk Reassessment Already Approved";
            this.type = "error";
            this.fireToastMsg();
        } else if(this.familyRiskReassessmentRec.Approval_Status__c == 'Submit for Approval') {

            this.title = "Error!";
            this.message = "Family Risk Reassessment submitted for Approval";
            this.type = "error";
            this.fireToastMsg();
        } else {

            this.handleSave();
            setTimeout(() => {
                this.submit();
            }, 2000);
            
        }
    }

    submit() {

        if( this.savedRec == true) {
            this.showApprovalScreen = true;
        }
               
    }

    handleSelectRec(event) {

        this.supervisorId = event.detail.recordId;
        this.enableSubmit = this.supervisorId?false:true;

    }

    hideApprovalScreen() {

        this.showApprovalScreen = false;
    }

    submitApproval() {

        this.loading = true;
        submitSuperApproval({ assessmentRecId: this.approvalRecordId, selectedSupervisorUserId: this.supervisorId }).then(result => {
           
            this.loading = false;
            this.title = 'Success!';
            this.type = 'success';
            this.message = 'Family Risk Reassessment record submitted for approval';
            this.fireToastMsg();
            this.showApprovalScreen = false;
            this.doInit();

        }).catch(error => {

            let errorMsg;
            this.title = "Error!";
            this.type = "error";
            if (error) {
                let errors = this.reduceErrors(error);
                errorMsg = errors.join('; ');
            } else {
                errorMsg = 'Unknown Error';
            }
            this.loading = false;
            this.message = errorMsg;
            this.fireToastMsg();
        })
    }

    initializeValues() {

        this.familyRiskReassessmentRec = {};
        this.selectedRR4 = [];
        this.selectedValueRR4 = [];
        this.selectedRR7Yesoptions = [];
        this.selectedValueRR7Yesoptions = [];
        this.familyRiskReassessmentRec.RR1_Score__c = 0;
        this.familyRiskReassessmentRec.RR2_Score__c = 0;
        this.familyRiskReassessmentRec.RR3_Score__c = 0;
        this.familyRiskReassessmentRec.RR4_Score__c = 0;
        this.familyRiskReassessmentRec.RR5_Score__c = 0;
        this.familyRiskReassessmentRec.RR6_Score__c = 0;
        this.familyRiskReassessmentRec.RR7_Score__c = 0;
        this.familyRiskReassessmentRec.RR8_Score__c = 0;
        this.familyRiskReassessmentRec.RR9_Score__c = 0;
        this.familyRiskReassessmentRec.RR10_Score__c = 0;
        this.familyRiskReassessmentRec.Does_not_demonstrate_Score__c = 0;
        this.familyRiskReassessmentRec.No_Secondary_Score__c = 0;
        this.familyRiskReassessmentRec.Total_Score__c = 0;
        this.showRR7Yesoptions = false;
        this.showOverride = false;
        //this.familyRiskReassessmentRec.formatedDateTime = moment.tz(this.familyRiskReassessmentRec.FRRE_Date_Assessment_Initiated__c,"America/Los_Angeles").format();
    }

    handleNew() {

        this.initializeValues();
        for(let i =0 ; i< this.childList.length; i++) {
            this.childList[i].disableCancel = false;
        }
        this.showList = false;
    }

    handleCancel() {
        this.doInit();
        this.showList = true;
    }

    handleRow(event) {

        if(event.detail.action.name == 'name') {
            this.initializeValues();
            this.familyRiskReassessmentRec = event.detail.row;
            if(this.familyRiskReassessmentRec.Characteristics_of_children_household__c != null){
                this.selectedValueRR4 = this.familyRiskReassessmentRec.Characteristics_of_children_household__c.split(';');
            }
            if(this.familyRiskReassessmentRec.Yes_problems_with_adult_r__c != null) {
                this.selectedValueRR7Yesoptions = this.familyRiskReassessmentRec.Yes_problems_with_adult_r__c.split(';');
            }
            if(this.familyRiskReassessmentRec.Adult_relationships_since_the_MFIRA__c == 'Yes, problems with adult relationships (select all that apply) (1)') {
                this.showRR7Yesoptions = true;
            }
            if(this.familyRiskReassessmentRec.X5_If_yes_override_risk_level__c == 'Yes') {
                this.showOverride = true;
            }
            if(this.familyRiskReassessmentRec.Approval_Status__c == 'Approved') {
                this.readOnly = true;
                for(let i =0 ; i< this.childList.length; i++) {
                    this.childList[i].disableCancel = true;
                }
            } else if(this.familyRiskReassessmentRec.Approval_Status__c != 'Approved') {
                this.readOnly = false;
                for(let i =0 ; i< this.childList.length; i++) {
                    this.childList[i].disableCancel = false;
                }
            }
            this.showList = false;
        } /*else if(event.detail.action.name == 'view') {
            this.initializeValues();
            this.familyRiskReassessmentRec = event.detail.row;
            if(this.familyRiskReassessmentRec.Characteristics_of_children_household__c != null){
                this.selectedValueRR4 = this.familyRiskReassessmentRec.Characteristics_of_children_household__c.split(';');
            }
            if(this.familyRiskReassessmentRec.Yes_problems_with_adult_r__c != null) {
                this.selectedValueRR7Yesoptions = this.familyRiskReassessmentRec.Yes_problems_with_adult_r__c.split(';');
            }
            if(this.familyRiskReassessmentRec.Adult_relationships_since_the_MFIRA__c == 'Yes, problems with adult relationships (select all that apply) (1)') {
                this.showRR7Yesoptions = true;
            }
            if(this.familyRiskReassessmentRec.X5_If_yes_override_risk_level__c == 'Yes') {
                this.showOverride = true;
            }
            this.familyRiskReassessmentRec.formatedDateTime = moment.tz(this.familyRiskReassessmentRec.FRRE_Date_Assessment_Initiated__c,"America/Los_Angeles").format();
            for(let i =0 ; i< this.childList.length; i++) {
                this.childList[i].disableCancel = true;
            }
            this.readOnly = true;
            this.showList = false;
            
        }*/ else if(event.detail.action.name == 'delete') {
            this.initializeValues();
            this.familyRiskReassessmentRec = event.detail.row;
            if(this.familyRiskReassessmentRec.Approval_Status__c == 'Approved') {

                this.title = "Error!";
                this.message = "Family Risk Reassessment Already Approved";
                this.type = "error";
                this.fireToastMsg();
            } else {

                this.loading = true;
                deleteAssessment({recordId : event.detail.row.Id})
                .then(result => {
                    this.loading = false;
                    this.title = 'Success!';
                    this.type = 'success';
                    this.message = 'Family Risk Reassessment record deleted successfully';
                    this.fireToastMsg();
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
            
        }
    }
      
}