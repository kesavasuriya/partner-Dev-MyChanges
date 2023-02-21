import { LightningElement, api, track, wire } from 'lwc';
import getRecord from '@salesforce/apex/RelatedListController.getRecords';
import getpicklist from '@salesforce/apex/RelatedListController.getPicklistinfo';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import {createRecord} from 'lightning/uiRecordApi';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { updateRecord } from 'lightning/uiRecordApi';

const fields = ['Id','Name','Does_the_person_have_disabilities__c','Autism_Spectrum_Disorder__c','Cognitive_Development_Delay__c','Emotionally_Disturbed__c','Hearing_Disability__c','Intellectual_Disability__c',
                'Other_Disability__c','Physical_Disability__c','Visual_Disability__c','Autism_Diagnosed_Diability__c', 'Autism_End_Resolution_Date__c', 'Autism_Comments__c', 'Autism_Evaluation_Date__c', 'Autism_Evaluator_Clinician_Name__c', 
                'Autism_Personal_Hygiene__c', 'Autism_Special_Needs__c', 'Autism_Start_Diagnosis_Date__c','Cognitive_Comments__c', 'Cognitive_Developmental_Delay__c', 'Cognitive_Diagnosed_Diability__c', 'Cognitive_End_Resolution_Date__c', 'Cognitive_Evaluation_Date__c', 
                'Cognitive_Evaluator_Clinician_Name__c', 'Cognitive_Personal_Hygiene__c', 'Cognitive_Special_Needs__c', 'Cognitive_Start_Diagnosis_Date__c', 
                'Emotionally_Comments__c', 'Emotionally_Diagnosed_Diability__c', 'Emotionally_End_Resolution_Date__c', 'Emotionally_Evaluation_Date__c', 'Emotionally_Evaluator_Clinician_Name__c', 
                'Emotionally_Personal_Hygiene__c', 'Emotionally_Special_Needs__c', 'Emotionally_Start_Diagnosis_Date__c', 'Hearing_Comments__c', 'Hearing_Diagnosed_Diability__c', 'Hearing_End_Resolution_Date__c', 'Hearing_Evaluation_Date__c', 
                'Hearing_Evaluator_Clinician_Name__c', 'Hearing_Personal_Hygiene__c', 'Hearing_Special_Needs__c', 'Hearing_Star_Diagnosis_Date__c', 'Intellectual_Comments__c', 'Intellectual_Diagnosed_Diability__c', 'Intellectual_End_Resolution_Date__c', 'Intellectual_Evaluation_Date__c', 'Intellectual_Evaluator_Clinician_Name__c', 
                'Intellectual_Special_Needs__c', 'Intellectual_Start_Diagnosis_Date__c', 'Other_Comments__c', 'Other_Diagnosed_Diability__c', 'Other_End_Resolution_Date__c', 'Other_Evaluation_Date__c', 'Other_Evaluator_Clinician_Name__c', 'Other_Personal_Hygiene__c', 'Other_Special_Needs__c', 'Other_Start_Diagnosis_Date__c', 'Physical_Address_From_Where_Child__c',
                 'Physical_Address_Verified__c', 'Physical_Comments__c', 'Physical_Diagnosed_Diability__c', 'Physical_End_Resolution_Date__c', 'Physical_Evaluation_Date__c', 'Physical_Evaluator_Clinician_Name__c', 'Physical_Personal_Hygiene__c', 'Physical_Special_Needs__c', 'Physical_Start_Diagnosis_Date__c', 'Visual_Comments__c', 'Visual_Diagnosed_Diability__c', 
                 'Visual_End_Resolution_Date__c', 'Visual_Evaluation_Date__c', 'Visual_Evaluator_Clinician_Name__c', 'Intellectual_Personal_Hygiene__c','Visual_Personal_Hygiene__c', 'Visual_Special_Needs__c', 'Visual_Start_Diagnosis_Date__c' ];

const queryDetail = {
    fieldValue: fields,
    objectApiName: 'Disabilities_Special_Needs__c',
    filterValue: 'Contact__c='
};

const actions = [{ label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

const columns = [
    // {label: 'Name', fieldName:'Name', wrapText: true,type:'string'},
   { label: 'Name',type: 'button', typeAttributes:{label:{fieldName:'Name'}, variant: 'base',name: 'edit'} },
   { label: 'Does the person have disabilities', fieldName: 'Does_the_person_have_disabilities__c',  wrapText: true,type: 'string' },
   { type: 'action', typeAttributes: { rowActions: actions } }
];

export default class DisabilityDetailsLwc extends UtilityBaseElement {

    @track showModal = false;
    @api recordId;
    @track  disabilityRecord = {};
    @track showAddModal = false;
    @track fieldApiNames = {};
    @track disabilityRec = {};
    @track disabilityRecordList = {};
    columns = columns;
    @track response = [];
    @track specialNeedsPickvalue =[];
    @track personHygienePickvalue =[];

    @track queryDetails = JSON.stringify(queryDetail);
    @wire(getRecord, { recordId: '$recordId', queryDetails: '$queryDetails' })
    relateRecords(response) {
        this.response = response;
        if (response.data) {
            this.disabilityRecordList = JSON.parse(JSON.stringify(response.data));

        } else if (response.error) {
            this.loading = false;
            this.title = "Error!";
            this.type = "error";
            this.message = response.error;
            this.fireToastMsg();
        }
    }

    connectedCallback() {
        getpicklist({objectName  : 'Disabilities_Special_Needs__c',fieldName : 'Autism_Special_Needs__c',isMultiPicklist : false})
        .then(res=>{
            this.specialNeedsPickvalue = JSON.parse(res);
        })
        getpicklist({objectName  : 'Disabilities_Special_Needs__c',fieldName : 'Autism_Personal_Hygiene__c',isMultiPicklist : false})
        .then(res=>{
            this.personHygienePickvalue = JSON.parse(res);
        })
    }

    get option(){
            return[{label:"Yes",value:'Yes'},
                   {label:'No',value:'No'}]
    }
    get options(){
        return[{label:"Yes",value:'Yes'},
               {label:'No',value:'No'},
               {label:'Unknown',value:'Unknown'}]
    }

    handleCancel() {
        
        this.showModal = false;
        this.disabilityRecord = {};
    }

    handleNew() {

        this.showModal = true;
    }

    handleClose() {

        this.showAddModal = false;
        this.disabilityRec = {};
        this.showModal = true;

    }

    handleChange(event) {

        let fieldName = event.target.name;

        if(event.target.name == 'Does_the_person_have_disabilities__c') {

            if(event.target.value == 'No') {

                this.disabilityRecord.Does_the_person_have_disabilities__c = event.target.value;
                this.disabilityRecord.Autism_Spectrum_Disorder__c = event.target.value;
                this.disabilityRecord.Cognitive_Development_Delay__c = event.target.value;
                this.disabilityRecord.Emotionally_Disturbed__c = event.target.value;
                this.disabilityRecord.Hearing_Disability__c = event.target.value;
                this.disabilityRecord.Intellectual_Disability__c = event.target.value;
                this.disabilityRecord.Other_Disability__c = event.target.value;
                this.disabilityRecord.Physical_Disability__c = event.target.value;
                this.disabilityRecord.Visual_Disability__c = event.target.value;

            } else if(event.target.value == 'Yes') {

                this.disabilityRecord = {};
                this.disabilityRecord[event.target.name] = event.target.value;
            }
            
        } else {

            this.disabilityRecord[event.target.name] = event.target.value;

        if(event.target.value == 'Yes') {

            this.showModal = false;

        switch(fieldName) {
                case 'Autism_Spectrum_Disorder__c':
                    this.fieldApiNames = {
                        DiagnosedDisablity : { label : 'Autism_Diagnosed_Diability__c', value : this.disabilityRecord.Autism_Diagnosed_Diability__c	},
    
                        StartDiagnosis:{ label : 'Autism_Start_Diagnosis_Date__c', value : this.disabilityRecord.Autism_Start_Diagnosis_Date__c}
    
                        ,EndResolution: { label : 'Autism_End_Resolution_Date__c', value : this.disabilityRecord.Autism_End_Resolution_Date__c},
    
                        EvaluationDate:{ label : 'Autism_Evaluation_Date__c', value : this.disabilityRecord.Autism_Evaluation_Date__c},
    
                        EvalutorClinicanName:{ label : 'Autism_Evaluator_Clinician_Name__c', value : this.disabilityRecord.Autism_Evaluator_Clinician_Name__c},
    
                        PersonalHygiene:{ label : 'Autism_Personal_Hygiene__c', value : this.disabilityRecord.Autism_Personal_Hygiene__c},
    
                        SpecialNeeds : { label : 'Autism_Special_Needs__c', value : this.disabilityRecord.Autism_Special_Needs__c},
    
                        Comments:{ label : 'Autism_Comments__c', value : this.disabilityRecord.Autism_Comments__c}};
                    this.showAddModal = true;
                    break;

                 case 'Cognitive_Development_Delay__c':


                    this.fieldApiNames = {
                        DiagnosedDisablity : { label : 'Cognitive_Diagnosed_Diability__c', value : this.disabilityRecord.Cognitive_Diagnosed_Diability__c},
    
                        StartDiagnosis:{ label : 'Cognitive_Start_Diagnosis_Date__c', value : this.disabilityRecord.Cognitive_Start_Diagnosis_Date__c},
    
                        EndResolution: { label : 'Cognitive_End_Resolution_Date__c', value : this.disabilityRecord.Cognitive_End_Resolution_Date__c},
    
                        EvaluationDate:{ label : 'Cognitive_Evaluation_Date__c', value : this.disabilityRecord.Cognitive_Evaluation_Date__c},
    
                        EvalutorClinicanName:{ label : 'Cognitive_Evaluator_Clinician_Name__c', value : this.disabilityRecord.Cognitive_Evaluator_Clinician_Name__c},
    
                        PersonalHygiene:{ label : 'Cognitive_Personal_Hygiene__c', value : this.disabilityRecord.Cognitive_Personal_Hygiene__c},
    
                        SpecialNeeds : { label : 'Cognitive_Special_Needs__c', value : this.disabilityRecord.Cognitive_Special_Needs__c},
    
                        Comments:{ label : 'Cognitive_Comments__c', value : this.disabilityRecord.Cognitive_Comments__c}};                    
                    this.showAddModal = true;
                    break;   

                case 'Emotionally_Disturbed__c':

                    
                    this.fieldApiNames = {
                    DiagnosedDisablity : { label : 'Emotionally_Diagnosed_Diability__c', value : this.disabilityRecord.Emotionally_Diagnosed_Diability__c},

                    StartDiagnosis:{ label : 'Emotionally_Start_Diagnosis_Date__c', value : this.disabilityRecord.Emotionally_Start_Diagnosis_Date__c}

                    ,EndResolution: { label : 'Emotionally_End_Resolution_Date__c', value : this.disabilityRecord.Emotionally_End_Resolution_Date__c},

                    EvaluationDate:{ label : 'Emotionally_Evaluation_Date__c', value : this.disabilityRecord.Emotionally_Evaluation_Date__c},

                    EvalutorClinicanName:{ label : 'Emotionally_Evaluator_Clinician_Name__c', value : this.disabilityRecord.Emotionally_Evaluator_Clinician_Name__c},

                    PersonalHygiene:{ label : 'Emotionally_Personal_Hygiene__c', value : this.disabilityRecord.Emotionally_Personal_Hygiene__c},

                    SpecialNeeds : { label : 'Emotionally_Special_Needs__c', value : this.disabilityRecord.Emotionally_Special_Needs__c},

                    Comments:{ label : 'Emotionally_Comments__c', value : this.disabilityRecord.Emotionally_Comments__c}};
                    this.showAddModal = true;
                    break;

                case 'Hearing_Disability__c':

                    
                    this.fieldApiNames = {
                        DiagnosedDisablity : { label : 'Hearing_Diagnosed_Diability__c', value : this.disabilityRecord.Hearing_Diagnosed_Diability__c},
    
                        StartDiagnosis:{ label : 'Hearing_Star_Diagnosis_Date__c', value : this.disabilityRecord.Emotionally_Diagnosed_Diability__c}
    
                        ,EndResolution: { label : 'Hearing_End_Resolution_Date__c', value : this.disabilityRecord.Hearing_End_Resolution_Date__c},
    
                        EvaluationDate:{ label : 'Hearing_Evaluation_Date__c', value : this.disabilityRecord.Hearing_Evaluation_Date__c},
    
                        EvalutorClinicanName:{ label : 'Hearing_Evaluator_Clinician_Name__c', value : this.disabilityRecord.Hearing_Evaluator_Clinician_Name__c},
    
                        PersonalHygiene:{ label : 'Hearing_Personal_Hygiene__c', value : this.disabilityRecord.Hearing_Personal_Hygiene__c},
    
                        SpecialNeeds : { label : 'Hearing_Special_Needs__c', value : this.disabilityRecord.Hearing_Special_Needs__c},
    
                        Comments:{ label : 'Hearing_Comments__c', value : this.disabilityRecord.Hearing_Comments__c}};
                    this.showAddModal = true;
                    break;

                case 'Intellectual_Disability__c':

                    
                    this.fieldApiNames = {
                        DiagnosedDisablity : { label : 'Intellectual_Diagnosed_Diability__c', value : this.disabilityRecord.Intellectual_Diagnosed_Diability__c},
    
                        StartDiagnosis:{ label : 'Intellectual_Start_Diagnosis_Date__c', value : this.disabilityRecord.Intellectual_Start_Diagnosis_Date__c}
    
                        ,EndResolution: { label : 'Intellectual_End_Resolution_Date__c', value : this.disabilityRecord.Intellectual_End_Resolution_Date__c},
    
                        EvaluationDate:{ label : 'Intellectual_Evaluation_Date__c', value : this.disabilityRecord.Intellectual_Evaluation_Date__c},
    
                        EvalutorClinicanName:{ label : 'Intellectual_Evaluator_Clinician_Name__c', value : this.disabilityRecord.Intellectual_Evaluator_Clinician_Name__c},
    
                        PersonalHygiene:{ label : 'Intellectual_Personal_Hygiene__c', value : this.disabilityRecord.Intellectual_Personal_Hygiene__c},
    
                        SpecialNeeds : { label : 'Intellectual_Special_Needs__c', value : this.disabilityRecord.Intellectual_Special_Needs__c},
    
                        Comments:{ label : 'Intellectual_Comments__c', value : this.disabilityRecord.Intellectual_Comments__c}};
                    this.showAddModal = true;
                    break;

                case 'Other_Disability__c':

                    
                    this.fieldApiNames = {
                        DiagnosedDisablity : { label : 'Other_Diagnosed_Diability__c', value : this.disabilityRecord.Other_Diagnosed_Diability__c},
    
                        StartDiagnosis:{ label : 'Other_Start_Diagnosis_Date__c', value : this.disabilityRecord.Other_Start_Diagnosis_Date__c}
    
                        ,EndResolution: { label : 'Other_End_Resolution_Date__c', value : this.disabilityRecord.Other_End_Resolution_Date__c},
    
                        EvaluationDate:{ label : 'Other_Evaluation_Date__c', value : this.disabilityRecord.Other_Evaluation_Date__c},
    
                        EvalutorClinicanName:{ label : 'Other_Evaluator_Clinician_Name__c', value : this.disabilityRecord.Other_Evaluator_Clinician_Name__c},
    
                        PersonalHygiene:{ label : 'Other_Personal_Hygiene__c', value : this.disabilityRecord.Other_Personal_Hygiene__c},
    
                        SpecialNeeds : { label : 'Other_Special_Needs__c', value : this.disabilityRecord.Other_Special_Needs__c},
    
                        Comments:{ label : 'Other_Comments__c', value : this.disabilityRecord.Other_Comments__c}};
                    this.showAddModal = true;
                    break;

                case 'Physical_Disability__c':

                    
                    this.fieldApiNames = {
                        DiagnosedDisablity : { label : 'Physical_Diagnosed_Diability__c', value : this.disabilityRecord.Physical_Diagnosed_Diability__c},
    
                        StartDiagnosis:{ label : 'Physical_Start_Diagnosis_Date__c', value : this.disabilityRecord.Physical_Start_Diagnosis_Date__c},
    
                        EndResolution: { label : 'Physical_End_Resolution_Date__c', value : this.disabilityRecord.Physical_End_Resolution_Date__c},
    
                        EvaluationDate:{ label : 'Physical_Evaluation_Date__c', value : this.disabilityRecord.Physical_Evaluation_Date__c},
    
                        EvalutorClinicanName:{ label : 'Physical_Evaluator_Clinician_Name__c', value : this.disabilityRecord.Physical_Evaluator_Clinician_Name__c},
    
                        PersonalHygiene:{ label : 'Physical_Personal_Hygiene__c', value : this.disabilityRecord.Physical_Personal_Hygiene__c},
    
                        SpecialNeeds : { label : 'Physical_Special_Needs__c', value : this.disabilityRecord.Physical_Special_Needs__c},
    
                        Comments:{ label : 'Physical_Comments__c', value : this.disabilityRecord.Physical_Comments__c}};
                    this.showAddModal = true;
                    break;

                case 'Visual_Disability__c':

                   
                    this.fieldApiNames = {
                        DiagnosedDisablity : { label : 'Visual_Diagnosed_Diability__c', value : this.disabilityRecord.Visual_Diagnosed_Diability__c},
    
                        StartDiagnosis:{ label : 'Visual_Start_Diagnosis_Date__c', value : this.disabilityRecord.Visual_Start_Diagnosis_Date__c}
    
                        ,EndResolution: { label : 'Visual_End_Resolution_Date__c', value : this.disabilityRecord.Visual_End_Resolution_Date__c},
    
                        EvaluationDate:{ label : 'Visual_Evaluation_Date__c', value : this.disabilityRecord.Visual_Evaluation_Date__c},
    
                        EvalutorClinicanName:{ label : 'Visual_Evaluator_Clinician_Name__c', value : this.disabilityRecord.Visual_Evaluator_Clinician_Name__c},
    
                        PersonalHygiene:{ label : 'Visual_Personal_Hygiene__c', value : this.disabilityRecord.Visual_Personal_Hygiene__c},
    
                        SpecialNeeds : { label : 'Visual_Special_Needs__c', value : this.disabilityRecord.Visual_Special_Needs__c},
    
                        Comments:{ label : 'Visual_Comments__c', value : this.disabilityRecord.Visual_Comments__c}};
                    this.showAddModal = true;
                    break;
        }
    }
    }
    }

    handleAdd() {

    this.disabilityRecord[this.fieldApiNames.DiagnosedDisablity.label] = this.disabilityRec[this.fieldApiNames.DiagnosedDisablity.label];
    this.disabilityRecord[this.fieldApiNames.StartDiagnosis.label] = this.disabilityRec[this.fieldApiNames.StartDiagnosis.label]; 
    this.disabilityRecord[this.fieldApiNames.EndResolution.label] = this.disabilityRec[this.fieldApiNames.EndResolution.label]; 
    this.disabilityRecord[this.fieldApiNames.EvaluationDate.label] = this.disabilityRec[this.fieldApiNames.EvaluationDate.label]; 
    this.disabilityRecord[this.fieldApiNames.EvalutorClinicanName.label] = this.disabilityRec[this.fieldApiNames.EvalutorClinicanName.label]; 
    this.disabilityRecord[this.fieldApiNames.PersonalHygiene.label] = this.disabilityRec[this.fieldApiNames.PersonalHygiene.label]; 
    this.disabilityRecord[this.fieldApiNames.SpecialNeeds.label] = this.disabilityRec[this.fieldApiNames.SpecialNeeds.label];
    this.disabilityRecord[this.fieldApiNames.Comments.label] = this.disabilityRec[this.fieldApiNames.Comments.label];
    
    this.disabilityRec = {};
    this.showAddModal = false;
    this.showModal = true;
  }

  handleDisablityChange(event) {
    this.disabilityRec[event.target.name] = event.target.value;
  }

  handlecreate() {
    this.disabilityRecord.Contact__c = this.recordId;
    const FIELDS = this.disabilityRecord;
    const record  = {apiName:'Disabilities_Special_Needs__c', fields: FIELDS};
    createRecord(record)
    .then(res=>{
        this.title = 'Success!';
        this.type = 'success';
        this.message = 'Record created successfully!';
        this.fireToastMsg();
        this.disabilityRecord = {};
        this.showModal = false;
        refreshApex(this.response);
    })
  }

  handleUpdate() {
    delete this.disabilityRecord.Name;
    const fields = this.disabilityRecord;
    const recordInput = { fields };

    updateRecord(recordInput)
                .then(() => {
                        this.type = 'success';
                        this.title = 'Success!';
                        this.message = 'Record update successfully!';
                        this.fireToastMsg();
                        refreshApex(this.response);
                });
  }

  handleSave() {

    if(!this.onValidate()) {
        this.showModal = false;
        if(this.disabilityRecord.Id == null) {
            this.handlecreate();
        } else {
            this.handleUpdate();
        }
    } else {
        this.title = "Error!";
        this.type = "error";
        this.message = "Please complete the required fields!";
        this.fireToastMsg();
    }
    
  }

  handleRowAction(event) {
    const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'edit':
                this.disabilityRecord = row;
                this.showModal = true;
                break;
            case 'delete':
                deleteRecord(row.Id)
                    .then(() => {
                        this.type = 'success';
                        this.title = 'Success!';
                        this.message = 'Record Deleted Successfully!';
                        this.fireToastMsg();
                        refreshApex(this.response);

                    })
                    .catch(error => {

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
                    })

                break;
        };
}

}