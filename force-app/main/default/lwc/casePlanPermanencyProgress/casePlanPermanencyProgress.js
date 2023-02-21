import { LightningElement, api, track } from 'lwc';
import getPermanencyProgressRec from '@salesforce/apex/CasePlanController.getPermanencyProgressRecord';
import { updateRecord } from 'lightning/uiRecordApi';
import UtilityBaseElement from 'c/utilityBaseLwc';

const assessmentColumns = [
    { label: 'Assessment Type', fieldName: 'Assessment_Type__c',  wrapText: true, type:"text"},
    { label: 'Assessment Completion Date', fieldName: 'completedDate', type: 'date', wrapText: true,type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Outcome', fieldName: 'Outcome',  wrapText: true, type: "text"},

];

const initialExamColumns = [
    { label: 'Entry/Replacement', fieldName: 'Appointment_Date__c', type: 'date', wrapText: true,type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Type', fieldName: 'Nature_of_Exam__c',  wrapText: true, type: "text"},
    { label: 'Provider', fieldName: 'Physician_Name__c',  wrapText: true, type: "text"},
    { label: 'Date', fieldName: 'Appointment_Date__c', type: 'date', wrapText: true,type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },

];

const annualExamColumns = [
    { label: 'Type', fieldName: 'Nature_of_Exam__c',  wrapText: true, type: "text"},
    { label: 'Provider', fieldName: 'Physician_Name__c',  wrapText: true, type: "text"},
    { label: 'Date', fieldName: 'Appointment_Date__c', type: 'date', wrapText: true,type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },

];

const followupColumns = [
    { label: 'Type', fieldName: 'Nature_of_Exam__c',  wrapText: true, type: "text"},
    { label: 'Appt.Date', fieldName: 'Appointment_Date__c', type: 'date', wrapText: true,type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Provider', fieldName: 'Physician_Name__c',  wrapText: true, type: "text"},
    { label: 'Reason for Follow-Up', fieldName: 'Not_Kept_Reason__c',  wrapText: true, type: "text"},
    { label: 'Next Appt.Date', fieldName: 'Next_Appointment_Date__c', type: 'date', wrapText: true,type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },

];

const educationColumns = [
    { label: 'School Attended at Time of Placement Name', fieldName: '',  wrapText: true, type: "text"},
    { label: 'Type of Class', fieldName: 'Type_of_Class__c', type: 'text', wrapText: true},
    { label: 'Address', fieldName: '',  wrapText: true, type: "text"},
    { label: 'Telephone Number of School', fieldName: 'Work_Phone_Number__c',  wrapText: true, type: "number"},
    { label: 'School Setting', fieldName: 'School_Setting__c', type: 'text', wrapText: true},
    { label: 'Grade', fieldName: 'Current_Grade__c',  wrapText: true, type: "text"},
    { label: 'Date Last attended', fieldName: 'Date_Last_Attended__c', type: 'date', wrapText: true,type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'School Exit Date', fieldName: 'Education_End_Date__c', type: 'date', wrapText: true,type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },

];

const medicationColumns = [
    { label: 'Is Child Taking Medications', fieldName: 'Is_Client_Prescribed_Medication__c',  wrapText: true, type: "text"},
    { label: 'Medication Name', fieldName: 'Medication_Name__c', type: 'text', wrapText: true},
    { label: 'Dose Frequency', fieldName: 'Frequency__c',  wrapText: true, type: "text"},
    { label: 'Date Started', fieldName: 'Start_Date__c', type: 'date', wrapText: true,type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Date Stopped', fieldName: 'End_Date__c', type: 'date', wrapText: true,type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Ordering Physician', fieldName: '',  wrapText: true, type: "number"},
    { label: 'Pharmacy Name/Phone', fieldName: '', type: 'text', wrapText: true},
    { label: 'Reason/Purpose for Medication', fieldName: 'Reason_Prescribed__c',  wrapText: true, type: "text"},
    
];

const incomeColumns = [
    { label: 'Date', fieldName: 'Entry_Date__c', type: 'date', wrapText: true,type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Type', fieldName: 'Income_Source__c',  wrapText: true, type: "text"},
    { label: 'Amount', fieldName: 'Monthly_Income__c',  wrapText: true, type: "text"},


];

const assetColumns = [
    { label: 'Date', fieldName: 'Entry_Date__c', type: 'date', wrapText: true,type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Type', fieldName: 'Asset_Type__c',  wrapText: true, type: "text"},
    { label: 'Amount', fieldName: 'Market_Value__c',  wrapText: true, type: "text"},


];

export default class CasePlanPermanencyProgress extends UtilityBaseElement {

    assessmentColumns = assessmentColumns;
    initialExamColumns = initialExamColumns;
    annualExamColumns = annualExamColumns;
    followupColumns = followupColumns;
    educationColumns = educationColumns;
    medicationColumns = medicationColumns;
    incomeColumns = incomeColumns;
    assetColumns = assetColumns;

    @api recordId;
    @track permanencyProgressRecord = {};
    @track permanencyPlanRecord = {};
    @track childRemovalRec = {};

    @track AssessmentRecords = [];
    @track incomeRecord = [];
    @track assetRecord = [];
    @track initialExamRecords = [];
    @track finalExamRecords = [];
    @track followupExamRecords = [];
    @track assessmentCompletedDates = [];
    @track educationRecords = [];
    @track faceToFaceRecords = [];
    @track medicationRecords = [];

    @track locationAddress;
    @track showPermanencyProgress = false;
    @track isLoading = false;

    showAssessmentTable = false;
    showInitialExamTable = false;
    showFinalExamTable = false;
    showFollowupExamTable = false;
    showEducationTable = false;
    showMedicationTable = false;
    showAssetTable = false;
    showIncomeTable = false;

    Child_Support_Referral_Date = '';
    @track updatePermanencyPlanRec = {};

    @track placementRec = {};
    @track childRec = {};
    @track servicecaseRec = {};
    @track intakeRec = {};
    @track providerRec = {};
    @track primaryCaregiver = {};

    get PickList() {

        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    connectedCallback() {

        this.isLoading = true;
        getPermanencyProgressRec({ casePlanVersionId: this.recordId })
            .then(result => {

                let res = JSON.parse(result);
                this.permanencyProgressRecord = this.checkNamespaceApplicable(res.permanencyProgressRecord, false);
                this.permanencyPlanRecord = this.checkNamespaceApplicable(res.permanencyPlanRecord, false);
                this.AssessmentRecords = this.checkNamespaceApplicable(res.assessmentRecordList, false);
                this.childRemovalRec = this.checkNamespaceApplicable(res.childRemovalRecord, false);
                this.incomeRecord = this.checkNamespaceApplicable(res.incomeRecord, false);
                this.assetRecord = this.checkNamespaceApplicable(res.assetRecord, false);
                this.initialExamRecords = this.checkNamespaceApplicable(res.initialExamList, false);
                this.finalExamRecords = this.checkNamespaceApplicable(res.finalExamList, false);
                this.followupExamRecords = this.checkNamespaceApplicable(res.followupExamList, false);
                this.educationRecords = this.checkNamespaceApplicable(res.educationRecords, false);
                this.faceToFaceRecords = this.checkNamespaceApplicable(res.faceToFaceVisitsList, false);
                this.medicationRecords = this.checkNamespaceApplicable(res.medicationRecords, false);
                this.assessmentCompletedDates = res.assessmentRecordCompletedDate;
                this.Child_Support_Referral_Date = this.permanencyProgressRecord.Child_Support_Referral_Date__c;

                if(this.childRemovalRec != null && this.childRemovalRec.Primary_Caregiver__c != null) {

                    this.primaryCaregiver = this.childRemovalRec.Primary_Caregiver__r;
                }

                if (this.permanencyProgressRecord.Placement__c != null) {

                    this.placementRec = this.permanencyProgressRecord.Placement__r;

                    if (this.placementRec.Placement_Structure__c.includes("Treatment Fostercare Care")) {
                    
                        this.permanencyProgressRecord.TreatmentFostercare = "Yes";
    
                    } else {
    
                        this.permanencyProgressRecord.TreatmentFostercare = "No";
                    }

                    if (this.placementRec.Child__c != null) {

                        this.childRec = this.placementRec.Child__r;
                    }

                    if (this.placementRec.Provider__c != null) {

                        this.providerRec = this.placementRec.Provider__r;
                    }

                    if (this.placementRec.Service_Case__c != null) {

                        this.servicecaseRec = this.placementRec.Service_Case__r;
                        if (this.servicecaseRec.Intake__c != null) {

                            this.intakeRec = this.servicecaseRec.Intake__r;
                        }
                    }
                }

                if (this.AssessmentRecords.length) {

                    this.showAssessmentTable = true;
                }

                if (this.initialExamRecords.length) {

                    this.showInitialExamTable = true;
                }

                if (this.finalExamRecords.length) {

                    this.showFinalExamTable = true;
                }

                if (this.followupExamRecords.length) {

                    this.showFollowupExamTable = true;
                }

                if (this.educationRecords.length) {
                    
                    this.showEducationTable = true;
                }

                if (this.incomeRecord.length) {

                    this.showIncomeTable = true;
                }

                if (this.assetRecord.length) {

                    this.showAssetTable = true;
                }

                if (this.medicationRecords.length) {

                    this.showMedicationTable = true;
                }

                this.showPermanencyProgress = true;


                if (this.permanencyPlanRecord.If_the_Permanency_plan_is_to_return_home__c) {

                    this.permanencyPlanRecord.If_the_Permanency_plan_is_to_return_home__c = "Yes";

                } else {

                    this.permanencyPlanRecord.If_the_Permanency_plan_is_to_return_home__c = "No";
                }

                for (let i = 0; i < this.AssessmentRecords.length; i++) {

                    if (this.AssessmentRecords[i].Assessment_Type__c == 'SAFE-C') {

                        if (this.AssessmentRecords[i].SAFEC_Child_is_conditionally_Safe__c) {

                            this.AssessmentRecords[i].Outcome = "Child is Safe (Influences 1-18 Marked No)";

                        } else if (this.AssessmentRecords[i].SAFEC_Child_is_Conditionally_Safe_17_16__c) {

                            this.AssessmentRecords[i].Outcome = "Child is Conditionally Safe (Any Influences 17-18 is Checked Yes All Actions in A Required Case     Staffing Have Been Implemented)";

                        } else if (this.AssessmentRecords[i].SAFEC_Child_is_Safe_Influences_1_18__c) {

                            this.AssessmentRecords[i].Outcome = "Child is conditionally Safe (Any Influences 1-16 is Checked And There is A completed Safety Plan That is Signed by All Parties)";

                        } else if (this.AssessmentRecords[i].SAFEC_Child_is_UnSafe__c) {

                            this.AssessmentRecords[i].Outcome = "Child is UnSafe";

                        }

                    } else if (this.AssessmentRecords[i].Assessment_Type__c == 'SAFE-C-OHP') {

                        if (this.AssessmentRecords[i].OHP_Child_is_Unsafe_Any_Influence_1_12__c) {

                            this.AssessmentRecords[i].Outcome = "Child is Unsafe (Any Influence 1-12 Was checked 'NO')";

                        } else if (this.AssessmentRecords[i].OHP_Child_is_Safe_Influences_1_12_Marked__c) {

                            this.AssessmentRecords[i].Outcome = "Child is Safe (Influences 1-12 Marked 'YES')";
                        }

                    } else if (this.AssessmentRecords[i].Assessment_Type__c == 'Family risk Reassessment') {

                        this.AssessmentRecords[i].Outcome = this.AssessmentRecords[i].RISK_LEVEL__c;

                    } else if (this.AssessmentRecords[i].Assessment_Type__c == 'Family Initial Risk Assessment') {

                        this.AssessmentRecords[i].Outcome = this.AssessmentRecords[i].FINAL_RISK_LEVEL__c
                    }
                }

                this.isLoading = false;
            }).catch(error => {

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
            });
    }

    handleChange(event) {

        let fieldType = event.target.type;

        if (fieldType != 'checkbox') {

            this.permanencyProgressRecord[event.target.name] = event.target.value;
            this.updatePermanencyPlanRec[event.target.name] = event.target.value;

        } else {

            this.permanencyProgressRecord[event.target.name] = event.target.checked;
            this.updatePermanencyPlanRec[event.target.name] = event.target.checked;
        }
    }

    handleSave() {

        this.loading = true;
        this.updatePermanencyPlanRec.Id = this.permanencyProgressRecord.Id;
        const fields = this.updatePermanencyPlanRec;
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {

                this.loading = false;
                this.title = "Success!";
                this.type = "success";
                this.message = "Record Updated Successfully!";
                this.fireToastMsg();
                this.updatePermanencyPlanRec = {};

            })
            .catch(error => {

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

            });
    }
}