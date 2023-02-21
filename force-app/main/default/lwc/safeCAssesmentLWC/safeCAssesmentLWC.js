import { LightningElement, track, api } from 'lwc';
import getInitiInfo from '@salesforce/apex/AssessmentController.getSAFECInitialInformation';
import saveSAFC from '@salesforce/apex/AssessmentController.createSAFEC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitSuperApproval from '@salesforce/apex/AssessmentController.onSubmitForApproval';
import ApprovalStatus from '@salesforce/apex/AssessmentController.onSubmitStatus';
import getChoosenAssessmentRec from '@salesforce/apex/AssessmentController.getAssessment';
import { loadScript } from 'lightning/platformResourceLoader';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import formatfordate from '@salesforce/resourceUrl/formatfordate';
const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Delete', name: 'delete' }
];

const columns = [
    { label: 'ChildName', fieldName: 'ChidName', type: "string" },
    { label: 'Age', fieldName: 'age', type: 'number', initialWidth: 80, cellAttributes: { alignment: 'left' } },
    { label: 'Client ID', fieldName: 'childId', type: 'string' },
    { type: 'action', initialWidth: 300, typeAttributes: { rowActions: actions, menuAlignment: 'left' } }

];
const columnlist = [
    { label: 'Assessment Name', type:  'button',typeAttributes: { 
        variant :'base', name : 'name',
                 label:   { 
            fieldName: 'name' 
        } }},
    { label: 'Safety Assessment Completion Date Time', fieldName: 'completionDate', type: 'string',wrapText: true },
    { label: 'Approval Status', fieldName: 'approvalStatus', type: 'string', wrapText: true}
    
];

const childcolumn = [
    { label: 'Child Name', fieldName: 'chidName' },
    { label: 'Age', fieldName: 'age',cellAttributes: { alignment: 'left' } },
    { label: 'Client ID', fieldName: 'clientId' },
    { label: 'Close', type: 'button' , typeAttributes: { 
         name : 'close', iconName : 'utility:close'}
    }

];

const safetyListColumn = [
    { label : 'DANGER INFLUENCE Number from the SAFE_C', fieldName:'Question_Name__c', type:'text',wrapText:'true'},
    { label : 'Specific DANGER INFLUENCE (Specifically Identify individuals and the issue)', fieldName:'Specific_Danger_Influence__c', type:'text',wrapText:'true',editable: true},
    { label : 'Action Required (Clearly identify resourrces/individuals and/or actions that need to occur in order to help address the Danger influences)', fieldName:'Action_Required__c', type:'text',wrapText:'true',editable: true},
    { label : 'Date to be completed', fieldName:'Date_to_be_Completed__c', type:'date', typeAttributes:{day:"numeric",month:"numeric",year:"numeric",hour:"numeric",minute:"numeric",hour12:"true"},editable: true},
    { label : 'Responsible Parties', fieldName:'Responsible_Parties__c', type:'text',wrapText:'true',editable: true},
    { label : 'Re-evaluation Date', fieldName:'Re_evaluation_Date__c',type:'date', typeAttributes:{day:"numeric",month:"numeric",year:"numeric",hour:"numeric",minute:"numeric",hour12:"true"},editable: true }
];

const safetyDecisionCmtFields = ['SAFEC_Caregiver_fails_to_protect__c', 'SAFEC_Caregiver_made_a_plausible_threat__c',
    'SAFEC_There_has_been_current_act__c', 'SAFEC_Child_sexual_abuse_is_suspected__c',
    'SAFEC_Caregiver_describes_the_child__c', 'SAFEC_Cargiver_s_suspected_or_observed__c',
    'SAFEC_Caregiver_s_emotional_instability__c', 'SAFEC_Caregiver_s_explanation__c',
    'SAFEC_Caregivers_justification_or_denial__c', 'SAFEC_Caregiver_does_not_or_refuse__c',
    'SAFEC_Domestic_violence_exists__c', 'SAFEC_Caregiver_does_not_meet_the_childs__c',
    'SAFEC_The_childs_whereabouts_are_unknown__c', 'SAFEC_The_child_has_special_needs__c',
    'SAFEC_The_child_is_extremely_anxious__c', 'SAFEC_The_child_is_unable_to_protect__c',
    'SAFEC_Previous_services_to_the_caregiver__c', 'SAFEC_There_have_been_multiple_reports__c'
];
const Influence1to16Fields = ['SAFEC_Caregiver_fails_to_protect__c', 'SAFEC_Caregiver_made_a_plausible_threat__c',
    'SAFEC_There_has_been_current_act__c', 'SAFEC_Child_sexual_abuse_is_suspected__c',
    'SAFEC_Caregiver_describes_the_child__c', 'SAFEC_Cargiver_s_suspected_or_observed__c',
    'SAFEC_Caregiver_s_emotional_instability__c', 'SAFEC_Caregiver_s_explanation__c',
    'SAFEC_Caregivers_justification_or_denial__c', 'SAFEC_Caregiver_does_not_or_refuse__c',
    'SAFEC_Domestic_violence_exists__c', 'SAFEC_Caregiver_does_not_meet_the_childs__c',
    'SAFEC_The_childs_whereabouts_are_unknown__c', 'SAFEC_The_child_has_special_needs__c',
    'SAFEC_The_child_is_extremely_anxious__c', 'SAFEC_The_child_is_unable_to_protect__c'
];

const Influence17to18Fields = ['SAFEC_Previous_services_to_the_caregiver__c', 'SAFEC_There_have_been_multiple_reports__c'];

const influenceCommentsMap = {
    'SAFEC_Caregiver_fails_to_protect__c': 'SAFEC_Caregiver_fails_Comments__c',
    'SAFEC_Caregiver_made_a_plausible_threat__c': 'SAFEC_Caregiver_made_a_Comments__c',
    'SAFEC_There_has_been_current_act__c': 'SAFEC_There_has_been_current_actComments__c',
    'SAFEC_Child_sexual_abuse_is_suspected__c': 'SAFEC_Child_sexual_abuse_Comments__c',
    'SAFEC_Caregiver_describes_the_child__c': 'SAFEC_Caregiver_describes_Comments__c',
    'SAFEC_Cargiver_s_suspected_or_observed__c': 'SAFEC_Cargiver_s_suspected_Comments__c',
    'SAFEC_Caregiver_s_emotional_instability__c': 'SAFEC_Caregiver_s_emotional_Comments__c',
    'SAFEC_Caregiver_s_explanation__c': 'SAFEC_Caregiver_s_explanation_Comments__c',
    'SAFEC_Caregivers_justification_or_denial__c': 'SAFEC_Caregivers_justification_Comments__c',
    'SAFEC_Caregiver_does_not_or_refuse__c': 'SAFEC_Caregiver_does_not_Comments__c',
    'SAFEC_Domestic_violence_exists__c': 'SAFEC_Domestic_violence_Comments__c',
    'SAFEC_Caregiver_does_not_meet_the_childs__c': 'SAFEC_Caregiver_does_not_meet_Comments__c',
    'SAFEC_The_childs_whereabouts_are_unknown__c': 'SAFEC_The_childs_whereabouts_Comments__c',
    'SAFEC_The_child_has_special_needs__c': 'SAFEC_The_child_has_special_Comments__c',
    'SAFEC_The_child_is_extremely_anxious__c': 'SAFEC_The_child_is_extremely_Comments__c',
    'SAFEC_The_child_is_unable_to_protect__c': 'SAFEC_The_child_is_unable_Comments__c',
    'SAFEC_Previous_services_to_the_caregiver__c': 'SAFEC_Previous_services_Comments__c',
    'SAFEC_There_have_been_multiple_reports__c': 'SAFEC_There_have_been_multiple_Comments__c'
}

import UtilityBaseElement from 'c/utilityBaseLwc';
export default class SafeCAssesmentLWC extends UtilityBaseElement {
    @api recordId;
    @api objectApiName;
    readOnly = false;
    safetyDecisionCmtFieldNames = safetyDecisionCmtFields;
    influenceCommentFieldsMap = influenceCommentsMap;
    influence1to16Fields = Influence1to16Fields;
    influence17to18Fields = Influence17to18Fields;
    @track safecRec = {};
    @track safecCommentsObj = {};
    value = '';
    @track caregiverDescribesTheChildPicklist;
    @track chlidList = [];
    @track requiredFields = false;
    @track columns;
    @track safetyPlanQesList = [];
    @track safetyPlanNoQuesList = [];
    deletingSafetyPlanQuesList = [];
    indexList = [];
    @track submitforApprovalPickList;
    @track safetyDecisionList = [];
    showModal = false;
    @track safeCheck = false; 
    @track unSafeCheck = false;
    @track conditionsafeCheck1 = false;
    @track conditionsafeCheck2 = false;
    supervisorId;
    assessmentId;
    showingErrorModal = false;
    showErrorMsg = '';
    enableSubmit = true;
    headofhousehold;
    serviceCaseName;
    caregiverList;
    servicecaseStatus;
    @track cargiverNamesPicklist;
    @track assessmentList = [];
    showCmp = false;
    showSubmitModal = false;
    
    assessmentListLength;
    ShowAssessmentTable = false;
    loading = false;
    hideNewBtn = true;
    @track visibleData = [];
    showChild = false;
    @track visibleData1 = [];
    showChild1 = false;
    columnlist = columnlist;
    childcolumn = childcolumn;
    safetyListColumn = safetyListColumn;
    draftValues = [];
    // @track fieldsObjList = ['SAFEC_Caregiver_fails_to_protect__c','SAFEC_Caregiver_made_a_plausible_threat__c', 'SAFEC_There_has_been_current_act__c', 'SAFEC_Child_sexual_abuse_is_suspected__c', 'SAFEC_Caregiver_describes_the_child__c', 'SAFEC_Cargiver_s_suspected_or_observed__c', 'SAFEC_Caregiver_s_emotional_instability__c', 'SAFEC_Caregiver_s_explanation__c', 'SAFEC_Caregivers_justification_or_denial__c', 'SAFEC_Caregiver_does_not_or_refuse__c', 'SAFEC_Domestic_violence_exists__c', 'SAFEC_Caregiver_does_not_meet_the_childs__c', 'SAFEC_The_childs_whereabouts_are_unknown__c', 'SAFEC_The_child_has_special_needs__c', 'SAFEC_The_child_is_extremely_anxious__c', 'SAFEC_The_child_is_unable_to_protect__c', 'SAFEC_Previous_services_to_the_caregiver__c', 'SAFEC_There_have_been_multiple_reports__c'];

    get options() {
        return [
            { label: ' Child is Safe (Influences 1-18 Marked No)', value: 'option1' },
            { label: 'Child is conditionally Safe (Any Influences 1-16 is Checked And There is A completed Safety Plan That is Signed by All Parties)', value: 'option2' },
            { label: 'Child is Conditionally Safe (Any Influences 17-18 is Checked Yes All Actions in A Required Case Staffing Have Been Implemented)', value: 'option3' },
            { label: 'Child is UnSafe', value: 'option4' },
        ];

    }

    get safectitle() {
        if(this.assessmentList) {
            return 'SAFE-C ('+this.assessmentList.length+')';
        } else {
            return 'SAFE-C';
        }
    }

    connectedCallback() {

        loadScript(this, momentForTime)
        this.loading = true;
        Promise.all([
            loadScript(this, momentForTime),loadScript(this, formatfordate)
        ]).then(()=> {

            let typeValue = 'SAFE-C';
            this.safecRec[this.objectApiName] = this.recordId;
        
            this.safecRec['Type_c'] = typeValue;
            this.safecRec['Assessment_Type__c'] = typeValue;
            this.doInitInfo();
        }).catch(error => {
            this.loading = false;
        })
        
        /*setTimeout(()=> {
            this.doInitInfo();
            
        },3000); */ 
        
    }

  
    showNew(event) {

        this.loading = true;
        this.readOnly = false;
        this.safecRec = {};
        this.safecCommentsObj = {};
        this.safetyPlanQesList = [];
        this.safetyPlanNoQuesList = [];
        this.deletingSafetyPlanQuesList = [];
   
        let typeValue = 'SAFE-C';
        this.safecRec[this.objectApiName] = this.recordId;
        
        this.safecRec['Type_c'] = typeValue;
        this.safecRec['Assessment_Type__c'] = typeValue;
        //readOnly = false;
        this.showCmp = true;
        this.doInitInfo();
        //readOnly = false;
        //this.showCmp = true;
        
    }

    getAssessmetRecord(selectedrow) {

        this.safecCommentsObj = {}; // for click each first set empty
        this.safetyPlanNoQuesList = [];
        this.deletingSafetyPlanQuesList = [];
        let assessmentId = selectedrow.id;
        this.loading = true;
        getChoosenAssessmentRec({ assessmentRecordId: assessmentId })
            .then(result => {
                this.loading = false;
                this.safecRec = {};
                this.safecRec = this.checkNamespaceApplicable(JSON.parse(result).assessmentRec, false);
                this.safetyDecisionCmtFieldNames.forEach((fieldName) => {
                this.safecCommentsObj[fieldName] = this.safecRec[fieldName] == 'Yes' ? true : false;
                });
                this.safetyPlanQesList = this.checkNamespaceApplicable(JSON.parse(result).assessmentSafetyPlanList, false);
                this.safetyPlanQesList.sort((a, b) => (a.Index__c > b.Index__c) ? 1 : (a.Index__c === b.Index__c) ? ((a.size > b.size) ? 1 : -1) : -1);
                this.showCmp = true;
                if (this.safecRec.Approval_Status__c == 'Approved') {
                    this.readOnly = true;
                } else {
                    this.readOnly = false;
                }
                this.conditionsafeCheck2  = this.safecRec.SAFEC_Child_is_Conditionally_Safe_17_16__c;
                this.safeCheck = this.safecRec.SAFEC_Child_is_Safe_Influences_1_18__c;
                this.conditionsafeCheck1 = this.safecRec.SAFEC_Child_is_conditionally_Safe__c ;
                this.unSafeCheck = this.safecRec.SAFEC_Child_is_UnSafe__c  ;
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

    doInitInfo() {

        this.showChild = false;
        this.showChild1 = false;
        getInitiInfo({ recordId: this.recordId })

        .then(result => {
            this.loading = false;
            let res = JSON.parse(result);
            this.caregiverDescribesTheChildPicklist = res.caregiverDescribesTheChildPicklist;
            this.columns = columns;
            this.assessmentList = this.checkNamespaceApplicable(res.assessmentList, false);
            

            this.assessmentListLength = this.assessmentList.length;

            if (this.assessmentListLength) {
                this.ShowAssessmentTable = true;
            }
            this.chlidList = res.childInputWarpList;
            this.cargiverNamesPicklist = res.caregiverNames;

            if (res.statusService) {
                this.servicecaseStatus = this.checkNamespaceApplicable(res.statusService, false);
                if (this.servicecaseStatus.Status__c == 'Close') {
                    this.hideNewBtn = false;
                }
            }
            this.submitforApprovalPickList = res.submitforApprovalPickList;
            if (res.cpsCaseName != '') {
                this.safecRec.SAFEC_CPS_Case_ID__c = res.cpsCaseName;
            }
            this.safecRec.SAFEC_Head_of_Household__c = res.headofHouseholdName;
            /*if (res.headofHouseholdName != '') {
                this.safecRec.SAFEC_Head_of_Household__c = res.headofHouseholdName;
            }*/
            this.showChild = true;
            this.showChild1 = true;
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

    handleSelection(event) {

        
        let row = event.target.name;
        let rows = this.chlidList;
        rows.splice(row, 1);
        //this.showChild1 = false;
        this.chlidList = rows;
        //this.showChild1 = true;

    }

    commentsOnChange(event) {

        let fieldName = event.target.name;
        let checkedfields = event.target.checked;
        let Value = event.target.value;
        let fieldType = event.target.type;
        if (fieldType != 'checkbox') {
            let currentQes = this.qesList[event.target.name];
            currentQes[currentQes.fieldApiName] = event.target.value;
            if (event.target.value == 'Yes') {
                currentQes.commentRequired = true;
            } else if (event.target.value == 'No') {
                currentQes.commentRequired = false;
            }

            this.qesList.splice(event.target.name, 1, currentQes);
        }
    }

    handleSelectRec(event) {

        this.supervisorId = event.detail.recordId;
        this.enableSubmit = this.supervisorId ? false : true;
    }

    cancelSubmitModal(event) {

        this.showCmp = true;
        this.showSubmitModal = false;
    }

    submitApproval(event) {

        submitSuperApproval({ assessmentRecId: this.assessmentId, selectedSupervisorUserId: this.supervisorId }).then(result => {
            const event = this.onToastEvent('success', 'Success!', 'Assessment record Send to Supervisor Approval');
            this.dispatchEvent(event);
            this.showCmp = false;
            this.showSubmitModal = false;
            this.doInitInfo();
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

    handleCommentChange(event) {

        this.safecRec[event.target.name] = event.target.value;
    }

    handleChange(event) {

        let fieldName = event.target.name;
        let checkedfields = event.target.checked;
        let Value = event.target.value;
        let fieldType = event.target.type;
        if (fieldType != 'checkbox') {

            this.conditionsafeCheck1 = false;
            this.conditionsafeCheck2 = false;
            this.safeCheck = false;
            this.unSafeCheck = false;

            this.safecRec[fieldName] = Value;

            //this.safecCommentsObj[fieldName] = false;
            if (Value == '') {

                let foundSafetyDecision = this.safetyDecisionList.find(ele => ele.index == event.target.dataset.index);
                if (foundSafetyDecision) {
                    const rowIndex = this.safetyDecisionList.indexOf(foundSafetyDecision);
                    this.safetyDecisionList.splice(rowIndex, 1);
                }
            } else {
                if (Value == 'Yes') {

                    //currentQes.commentRequired = true;
                    this.safecCommentsObj[fieldName] = true;
                    let safetyPlanQesListData = Object.assign([], this.safetyPlanQesList);
                    
                    safetyPlanQesListData.push({
                        Danger_Influence_Qeustion__c: fieldName,
                        Question_Name__c: event.target.label,
                        Index__c: event.target.dataset.index
                    });
                    this.safetyPlanQesList = safetyPlanQesListData;
                }
                let foundelement = this.safetyDecisionList.find(ele => ele.name == event.target.name);

                if (!foundelement) {
                    this.safetyDecisionList.push({
                        name: event.target.name,
                        value: event.target.value,
                        index: event.target.dataset.index
                    })
                } else {
                    foundelement.value = event.target.value;
                    this.safetyDecisionList = [...this.safetyDecisionList];
                }
            }

            if (Value == 'No' || Value == '') {

                this.safecRec[this.influenceCommentFieldsMap[fieldName]] = '';
                this.safecCommentsObj[fieldName] = false;
                let safetyplanqes = Object.assign([], this.safetyPlanQesList);
                let foundSafetyPlan = safetyplanqes.find(ele => ele.Danger_Influence_Qeustion__c == fieldName);
                if (foundSafetyPlan) {
                    const rowIndex = safetyplanqes.indexOf(foundSafetyPlan);
                    safetyplanqes.splice(rowIndex, 1);
                    this.safetyPlanQesList = safetyplanqes;
                    if (foundSafetyPlan.Id) {
                        this.deletingSafetyPlanQuesList.push(foundSafetyPlan);
                    }
                }

            }
            let influenceYesList = [];
            let influenceNoList = [];
            let influence1t16YesList = [];
            let influence17t18YesList = [];

            this.safetyDecisionCmtFieldNames.forEach((fieldName) => {

                if (this.safecRec[fieldName] == 'Yes') {
                    influenceYesList.push(this.safecRec[fieldName]);
                } else if (this.safecRec[fieldName] == 'No') {
                    influenceNoList.push(this.safecRec[fieldName]);
                }
            });
            this.influence1to16Fields.forEach((fieldName) => {

                if (this.safecRec[fieldName] == 'Yes' && influence1t16YesList.length == 0) {
                    influence1t16YesList.push(this.safecRec[fieldName]);
                }
            });

            this.influence17to18Fields.forEach((fieldName) => {

                if (this.safecRec[fieldName] == 'Yes' && influence17t18YesList.length == 0) {
                    influence17t18YesList.push(this.safecRec[fieldName]);
                }
            });

            if (influenceYesList.length == 18) {
                this.conditionsafeCheck1 = false;
                this.conditionsafeCheck2 = false;
                this.safeCheck = false;
                this.unSafeCheck = true;
            } else if (influenceNoList.length == 18) {
                this.conditionsafeCheck1 = false;
                this.conditionsafeCheck2 = false;
                this.safeCheck = true;
                this.unSafeCheck = false;
            } else if (influence17t18YesList.length) {
                this.conditionsafeCheck1 = false;
                this.conditionsafeCheck2 = true;
                this.safeCheck = false;
                this.unSafeCheck = false;
            } else if (influence1t16YesList.length) {
                this.conditionsafeCheck1 = true;
                this.conditionsafeCheck2 = false;
                this.safeCheck = false;
                this.unSafeCheck = false;
            }

            //event.target.dataset.index
        
            this.safetyPlanQesList.sort((a, b) => (a.Index__c > b.Index__c) ? 1 : (a.Index__c === b.Index__c) ? ((a.size > b.size) ? 1 : -1) : -1);

        } else {
            this.safecRec[event.target.name] = checkedfields;
        }

    }

    safetyPlanOnChange(event) {

        let safetyPlanQes = this.safetyPlanQesList;
        let currentRowIndex = event.currentTarget.dataset.id;
        safetyPlanQes[currentRowIndex][event.target.name] = event.target.value;
        this.safetyPlanQesList = safetyPlanQes;
    }

    checkSubmitStatus() {

        let assessmentRec;
        ApprovalStatus({ assessmentRecId: this.assessmentId }).then(result => {
            assessmentRec = JSON.parse(result);
            if (assessmentRec.Approval_Status__c == 'Submit for Approval') {
                this.showingErrorModal = true;
                this.showErrorMsg = 'This Assessment record already in approval process.';
                //const event = this.onToastEvent('error', 'Error!', 'This assesment record already in approval process.');
                //this.dispatchEvent(event);
            } else if (assessmentRec.Approval_Status__c == 'Approved') {
                this.showingErrorModal = true;
                this.showErrorMsg = 'This Assessment record is already approved.';
                //const event = this.onToastEvent('error', 'Error!', 'This assesment record already approved.');
                //this.dispatchEvent(event);
            } else {
                this.showingErrorModal = false;
                this.showErrorMsg = '';
            }
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

    handleSave(event) {

        if (!this.onValidate() && this.checkSafetyListRequired()) {
            let saveQesList = [];
            this.safecRec.SAFEC_Child_is_Conditionally_Safe_17_16__c = this.conditionsafeCheck2 
            this.safecRec.SAFEC_Child_is_Safe_Influences_1_18__c = this.safeCheck
            this.safecRec.SAFEC_Child_is_conditionally_Safe__c = this.conditionsafeCheck1
            this.safecRec.SAFEC_Child_is_UnSafe__c = this.unSafeCheck
            this.loading = true;
            saveSAFC({ assessmentSAFECDataJSON: JSON.stringify(this.checkNamespaceApplicable(this.safecRec, true)), safetyPlanQesDataJSON: JSON.stringify(this.checkNamespaceApplicable(this.safetyPlanQesList, true)), deletingSafetyPlanJSON: JSON.stringify(this.checkNamespaceApplicable(this.deletingSafetyPlanQuesList, true)) }).then(result => {
                const toastMsg = this.assessmentId ? 'Assessment record updated successfully.' : 'Assessment record created successfully.';
                const event = this.onToastEvent('success', 'Success!', toastMsg);
                this.dispatchEvent(event);
                this.loading = false;
                this.assessmentId = result;
                this.safecRec['Id'] = result;
                this.showCmp = false;
                this.doInitInfo();
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
        } else if(this.onValidate()) {
            const event = this.onToastEvent('error', 'Error!', 'Complete the required field(s).');
            this.dispatchEvent(event);
        } else if(!this.checkSafetyListRequired()) {
            const event = this.onToastEvent('error', 'Error!', 'Complete the Safety Plan required field(s).');
            this.dispatchEvent(event);
        }

    }

    onValidate() {
        const allValid = [
            ...this.template.querySelectorAll("lightning-input"), ...this.template.querySelectorAll("lightning-combobox"), ...this.template.querySelectorAll("lightning-textarea")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return !allValid;
    }

    onToastEvent(type, toastTitle, msg) {

        const toastEvent = new ShowToastEvent({
            variant: type,
            title: toastTitle,
            message: msg,
        });
        return toastEvent;
    }

    compareValues(key, order = 'asc') {
        return function innerSort(a, b) {
            if (!a.hasOwnProperty(key) || !b.hasOwnProperty(key)) {
                // property doesn't exist on either object
                return 0;
            }

            const varA = (typeof a[key] === 'string') ?
                a[key].toUpperCase() : a[key];
            const varB = (typeof b[key] === 'string') ?
                b[key].toUpperCase() : b[key];

            let comparison = 0;
            if (varA > varB) {
                comparison = 1;
            } else if (varA < varB) {
                comparison = -1;
            }
            return (
                (order === 'desc') ? (comparison * -1) : comparison
            );
        };
    }

    onSumbitforApproval(event) {

        if (!this.onValidate() && this.checkSafetyListRequired()) {
            let saveQesList = [];
            this.loading = true;
            this.safecRec.SAFEC_Child_is_Conditionally_Safe_17_16__c = this.conditionsafeCheck2 
            this.safecRec.SAFEC_Child_is_Safe_Influences_1_18__c = this.safeCheck
            this.safecRec.SAFEC_Child_is_conditionally_Safe__c = this.conditionsafeCheck1
            this.safecRec.SAFEC_Child_is_UnSafe__c = this.unSafeCheck
            saveSAFC({ assessmentSAFECDataJSON: JSON.stringify(this.checkNamespaceApplicable(this.safecRec, true)), safetyPlanQesDataJSON: JSON.stringify(this.checkNamespaceApplicable(this.safetyPlanQesList, true)), deletingSafetyPlanJSON: JSON.stringify(this.checkNamespaceApplicable(this.deletingSafetyPlanQuesList, true)) }).then(result => {
                this.loading = false;
                const toastMsg = this.assessmentId ? 'Assessment record updated successfully.' : 'Assessment record created succesfully.';
                const event = this.onToastEvent('success', 'Success!', toastMsg);
                this.dispatchEvent(event);
                this.assessmentId = result;
                this.safecRec['Id'] = result;
                this.checkSubmitStatus();
                this.showCmp = false;
                this.showSubmitModal = true;
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
        } else if(this.onValidate()) {
            const event = this.onToastEvent('error', 'Error!', 'Complete the required field(s).');
            this.dispatchEvent(event);
        } else if(!this.checkSafetyListRequired()) {
            const event = this.onToastEvent('error', 'Error!', 'Complete the Safety Plan required field(s).');
            this.dispatchEvent(event);
        }
    }

    closeEventModal(event) {

        this.showCmp = false;
        this.showSubmitModal = false;
    }
    paginationHandler(event) {

        this.visibleData = [...event.detail.records];     
    }
    paginationHandler1(event) {

        this.visibleData1 = [...event.detail.records];     
    }

    handleRowAction(event) {

        var actionName = event.detail.action.name;
        var selectedrow = event.detail.row;
        switch (actionName) {
            case 'name':
                this.getAssessmetRecord(selectedrow);
                break;
        }

    }

    handleDownload(row) {

        let id = this.safecRec.Id;
        var url = '/apex/SAFECPDF?id='+id;
        window.open(url, '_blank');
    }

    handleDraft(event) {
        let draftValues = event.detail.draftValues;

        let safetyPlanQesDataList = Object.assign([],  this.safetyPlanQesList);
        for(let i = 0; i < draftValues.length; i++) {
            let foundSafetyPlan = safetyPlanQesDataList.find(ele => ele.Question_Name__c == draftValues[i].Question_Name__c);

            if(foundSafetyPlan) {
                const rowIndex = safetyPlanQesDataList.indexOf(foundSafetyPlan);
                for (const item in draftValues[i]) {

                    safetyPlanQesDataList[rowIndex][item] = draftValues[i][item];
                }
            }
        }
        this.safetyPlanQesList =  safetyPlanQesDataList;  
        if(this.checkSafetyListRequired()) {
            this.draftValues = [];
        } else {
            const event = this.onToastEvent('error', 'Error!', 'Complete the Safety Plan required field(s).');
            this.dispatchEvent(event);
        }
           
    }

    checkSafetyListRequired() {
        let returnValue = true;
        if(this.safecRec.SAFEC_Any_Influences_1_18_was_checked__c == true || this.safecRec.SAFEC_Child_currently_has_Out_of_Home__c == true || this.safecRec.SAFEC_Caregiver_did_not_agree_to_safety__c == true || this.safecRec.SAFEC_Danger_cannot_be_addressed_via__c == true) {
            returnValue = true;
        } else if ( this.safetyPlanQesList.length == 0) {
            returnValue = true;
        } else {
            for(let i = 0 ; i < this.safetyPlanQesList.length; i++) {
                const currentIteration = this.safetyPlanQesList[i];
                if(returnValue == true && currentIteration.Question_Name__c && currentIteration.Specific_Danger_Influence__c && currentIteration.Action_Required__c &&
                    currentIteration.Date_to_be_Completed__c && currentIteration.Responsible_Parties__c && currentIteration.Re_evaluation_Date__c) {
                        returnValue = true;
                } else {
                    returnValue = false;   
                }
            }
        }
        
        return returnValue;
    }

}