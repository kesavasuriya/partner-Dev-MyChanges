import { LightningElement, track, api } from 'lwc';
import getPersons from '@salesforce/apex/DocumentsCtrl.getPersons';
import getDocuments from '@salesforce/apex/DocumentsCtrl.getDocuments';

const personColumns = [{label : 'Name', fieldName : 'Name'}, 
                        {label : 'Casevault PID', fieldName : 'Casevault_PID__c'}];
const fileColumns = [{label: 'Document Name', fieldName: 'docUrl', type: 'url', target: '_self', wrapText: 'true', typeAttributes: { label: { fieldName: 'docName' } } },
                    { label : 'File type', fieldName : 'docType', sortable: true},
                    { label : 'Uploaded by', fieldName : 'docUploadedBy', sortable: true},
                    {label : 'Uploaded Date', fieldName : 'docUploadedDate', type:'date', sortable: true, typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone : 'UTC'}}]                       

export default class PersonDocumentLWC extends LightningElement {

    @api recordId;

    @track persons = [];
    @track selectedRow = {};
    @track folders = [];
    @track documents = [];

    showPersons = false;
    showFolders = false;
    showFiles = false;
    isLoading = false;

    personColumns = personColumns;
    fileColumns = fileColumns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    personsTitle = 'Persons(0)';
    documentsTitle = 'Documents(0)';
    @track personFolders =[];

    @track educationDocuments = [];
    @track healthDocuments = [];
    @track profileDocuments = [];
    @track employmentDocuments = [];
    @track lifeSkillsDocuments = [];
    @track financeDocuments = [];


    get showHeader() {

        if(this.selectedRow && (this.showFolders || this.showFiles)) 
            return true;
        else    
            return false;
        
    }

    connectedCallback() {
        this.doInit();
    }

    doInit() {

        this.isLoading = true;
        this.showPersons = true;
        getPersons({ recordId : this.recordId})
        .then(result => {
            if(result) {
                this.persons = JSON.parse(result);
                this.personsTitle = 'Persons('+this.persons.length+')';   
                this.isLoading = false;
            }
        }).catch(error => {
            
            console.log('error:::',error);
            this.isLoading = false;
        })
    }

    handleRowSelection(event) {

        this.selectedRow = event.detail.selectedRows[0];
        if(this.selectedRow) {

            this.folders = [];
            /*for(let i = 0; i < this.personFolders.length; i++) {
                let folder = {};
                folder.Name = this.personFolders[i];
                this.folders.push(folder);
            }*/
            this.showPersons = false;
            this.getDocument(this.selectedRow.Id);
        }
        
    }

    handleClick() {

        if(this.showFolders) {

            this.showPersons = true;
            this.showFolders = false;
            this.showFiles = false;

        } else if(this.showFiles) {

            this.showFolders = true;
            this.showPersons = false;
            this.showFiles = false;
        }
    }

    getDocument(id) {

        
        getDocuments({ recordId : id})
        .then(result => {

            if(result) {
                let res = JSON.parse(result);
                /*this.documents = JSON.parse(result);
            
                this.documentsTitle = 'Documents('+this.documents.length+')';   */
                this.educationDocuments = res.educationDocuments;
                this.healthDocuments = res.healthDocuments;
                this.profileDocuments = res.profileDocuments;
                this.employmentDocuments = res.employmentDocuments;
                this.lifeSkillsDocuments = res.lifeSkillsDocuments;
                this.financeDocuments = res.financeDocuments;
                console.log('In');
                
            }
            this.personFolders = [{name : 'Profile',label:'Profile ('+this.profileDocuments.length+')'},
                {name : 'Health',label:'Health ('+this.healthDocuments.length+')'},
                {name : 'Education',label:'Education ('+this.educationDocuments.length+')'},
                {name : 'Employment',label:'Employment ('+this.employmentDocuments.length+')'},
                {name : 'Life Skills',label:'Life Skills ('+this.lifeSkillsDocuments.length+')'},
                {name : 'Finance',label:'Finance ('+this.financeDocuments.length+')'},
            ]
            console.log(this.personFolders);
            this.showFolders = true;
            this.isLoading = false;
        }).catch(error => {

            console.log('error:::',error);
            this.isLoading = false;
        })
       
    }

    sortBy(field, reverse, primer) {

        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };

    }

    onHandleSort(event) {

        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.documents];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.documents = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    handleFolder(event) {

        this.showPersons = false;
        this.showFolders = false;
        this.showFiles = true;
        let folderType = event.target.name;
        if(folderType == 'Profile') {
            this.documents = this.profileDocuments;
        } else if( folderType == 'Health') {
            this.documents = this.healthDocuments;
        } else if( folderType == 'Education') {
            this.documents = this.educationDocuments;
        } else if( folderType == 'Employment') {
            this.documents = this.employmentDocuments;
        } else if( folderType == 'Life Skills') {
            this.documents = this.lifeSkillsDocuments;
        } else if( folderType == 'Finance') {
            this.documents = this.financeDocuments;
        } 
        this.documentsTitle = 'Documents('+this.documents.length+')'; 
    }
}