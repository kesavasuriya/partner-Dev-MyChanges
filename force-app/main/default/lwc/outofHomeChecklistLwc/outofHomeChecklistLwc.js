import { LightningElement, api,track } from 'lwc';
import getPersons from '@salesforce/apex/OutOfHomeChecklistController.getChildRecords';
import getDetails from '@salesforce/apex/OutOfHomeChecklistController.getTableDetails'
import { NavigationMixin } from 'lightning/navigation';

export default class OutofHomeChecklistLwc extends NavigationMixin(LightningElement) {

    @api recordId;
    @track personList = [];
    @track childRemovalRec = {};
    @track assessmentRecord = {};
    @track initialDueDate;
    @track nextDueDate;
    @track initialExam = {};
    @track finalExam = {};
    @track comprehensiveExam = {};
    @track notesRecord = {};

    connectedCallback() {
        getPersons({recordId : this.recordId})
        .then(result =>{
            let res = JSON.parse(result);
            this.personList = res.personRecords;
            console.log('res',this.personList);

        });
    }

    handleClick(event) {
        
        let childId = event.target.value;
        this.assessmentRecord = {};
        this.initialDueDate = {};
        this.nextDueDate = {};
        this.initialExam = {};
        this.finalExam = {};
        this.comprehensiveExam = {};
        this.notesRecord = {};

        getDetails({recordId : this.recordId,personId:childId})
        .then(result =>{
            let res = JSON.parse(result);
            console.log('t',res);
                
                this.initialDueDate = res.initialDueDate;
                this.nextDueDate = res.nextDueDate;

                if(res.notesRecord) {
                    this.notesRecord = res.notesRecord;
                    this.notesRecord.ownerName = this.notesRecord.Notes__r.CreatedBy.Name;
                    this.notesRecord.Contact_Date__c = this.notesRecord.Notes__r.Contact_Date__c;

                    this.notesRecord.nextDueDate = res.lastDayOfMonth;
                }
                if(res.assessmentRecord) {
                    this.assessmentRecord = res.assessmentRecord;
                    this.assessmentRecord.approver = res.assessmentRecord.Supervisor_Approver__r.Name;
                }

                if(res.initialExamRecord) {
                    this.initialExam = res.initialExamRecord;
                    this.initialExam.ownerName = this.initialExam.CreatedBy.Name;
                }
                if(res.comprehensiveExamRecord) {
                    this.comprehensiveExam = res.comprehensiveExamRecord;
                    this.comprehensiveExam.ownerName = this.comprehensiveExam.CreatedBy.Name;
                }
                if(res.annualExamRecord) {
                    this.finalExam = res.annualExamRecord;
                    this.finalExam.ownerName = this.finalExam.CreatedBy.Name;
                }

        })

    }

    handleExamClick(event) {

        if(event.target.dataset.id)  {
        this[NavigationMixin.Navigate]({
            type : 'standard__recordPage',
            attributes : {
                recordId :  event.target.dataset.id,
                actionName : 'view'
            }
        });
    }
    }
}