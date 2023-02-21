import { LightningElement, api, track } from 'lwc';
import getDocuments from '@salesforce/apex/DocumentsCtrl.getCaseDocuments';

const fileColumns = [{label: 'Document Name', fieldName: 'docUrl', type: 'url', target: '_self', wrapText: 'true', typeAttributes: { label: { fieldName: 'docName' } } },
                    { label : 'File type', fieldName : 'docType', sortable: true},
                    { label : 'Uploaded by', fieldName : 'docUploadedBy', sortable: true},
                    {label : 'Uploaded Date', fieldName : 'docUploadedDate', type:'date', sortable: true, typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone : 'UTC'}}]; 

export default class ServiceCaseDocumentLWC extends LightningElement {

    @api recordId;
    @track documents = [];
    showFolders = true;
    //caseFolders = ['Contacts', 'Court', 'Case Plan','Services','Removal'];
    @track caseFolders =[];
    isLoading = false;
    showFiles = false;
    documentsTitle = 'Documents(0)';
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    fileColumns = fileColumns;

    @track contactsDocuments =[];
    @track courtDocuments =[];
    @track casePlanDocuments =[];
    @track servicesDocuments=[];
    @track removalDocuments=[];

    connectedCallback() {

        this.isLoading = true;
        getDocuments({ recordId : this.recordId})
        .then(result => {

            if(result) {
                let res = JSON.parse(result);
                /*this.documents = JSON.parse(result);
                this.documentsTitle = 'Documents('+this.documents.length+')';  */
                this.contactsDocuments = res.contactsDocuments;
                this.courtDocuments = res.courtDocuments;
                this.casePlanDocuments = res.casePlanDocuments;
                this.servicesDocuments = res.servicesDocuments;
                this.removalDocuments = res.removalDocuments;

            }

            this.caseFolders = [{name : 'Contacts',label:'Contacts ('+this.contactsDocuments.length+')'},
            {name : 'Court',label:'Court ('+this.courtDocuments.length+')'},
            {name : 'Case Plan',label:'Case Plan ('+this.casePlanDocuments.length+')'},
            {name : 'Services',label:'Services ('+this.servicesDocuments.length+')'},
            {name : 'Removal',label:'Removal ('+this.removalDocuments.length+')'},
        ]
            this.showFolders = true;
            this.isLoading = false;

        }).catch(error => {

            console.log('error:::',error);
            this.isLoading = false;
        })
       
    }

    handleClick() {

        this.showFolders = true;
        this.showFiles = false;
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

        this.showFolders = false;
        this.showFiles = true;
        let folderType = event.target.name;
        if(folderType == 'Contacts') {
            this.documents = this.contactsDocuments;
        } else if( folderType == 'Court') {
            this.documents = this.courtDocuments;
        } else if( folderType == 'Case Plan') {
            this.documents = this.casePlanDocuments;
        } else if( folderType == 'Services') {
            this.documents = this.servicesDocuments;
        } else if( folderType == 'Removal') {
            this.documents = this.removalDocuments;
        } 
        this.documentsTitle = 'Documents('+this.documents.length+')';
    }
}