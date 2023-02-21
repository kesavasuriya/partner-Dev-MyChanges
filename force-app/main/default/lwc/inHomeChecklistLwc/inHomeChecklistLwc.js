import { LightningElement,api,track } from 'lwc';
import getPersons from '@salesforce/apex/InHomeChecklistController.getChildRecords';
import getDetails from '@salesforce/apex/InHomeChecklistController.getTableDetails'

export default class InHomeChecklistLwc extends LightningElement {

    @api recordId;
    @track personList = [];
    @track assessmentRecord = {};
    @track notesRecord = {};
    @track servicecaseRecord = {};
    @track initialDate;
    @track riskAssessment = {};
    @track riskAssessmentInitialDueDate;
    @track safecNextDueDate;
    connectedCallback() {
        getPersons({recordId : this.recordId})
        .then(result =>{
            let res = JSON.parse(result);
            this.personList = res.personRecords;

        })
        
    }

    handleClick(event) {
        
        let childId = event.target.value;
        this.assessmentRecord = {};
        this.notesRecord = {};
        this.initialDate;
        this.riskAssessmentInitialDueDate;
        this.safecNextDueDate;

        getDetails({recordId : this.recordId,personId:childId})
        .then(result =>{
            let res = JSON.parse(result);
            this.servicecaseRecord = res.serviceCaseRecord;
            this.initialDate = res.initialDate;
            console.log('t',res.initialDate);
            let d = new Date(this.initialDate);
            this.riskAssessmentInitialDueDate = d.setDate(d.getDate()+30);
            this.safecNextDueDate = d.setDate(d.getDate()+180);

                if(res.notesRecord) {
                    this.notesRecord = res.notesRecord;
                    console.log('notes',res.notesRecord);
                    this.notesRecord.Contact_Date__c = this.notesRecord.Notes__r.Contact_Date__c;
                    this.notesRecord.ownerName = this.notesRecord.Notes__r.CreatedBy.Name
                    
                }
                if(res.assessmentRecord) {
                    this.assessmentRecord = res.assessmentRecord;
                    this.assessmentRecord.approver = res.assessmentRecord.Supervisor_Approver__r.Name;
                    
                }
                if(res.riskAssessmentRecord) {
                    this.riskAssessment = res.riskAssessmentRecord;
                }

        })

    }
}