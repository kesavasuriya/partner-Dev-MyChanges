import { LightningElement, track, api } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';

const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];

const columns = [
    { label: 'Client Name', fieldName: 'petitionChildName', type: 'text', wrapText : true },
    { label: 'Type of Petition', fieldName: 'Type_of_Petition__c', type: 'text' , wrapText : true},
    { label: 'Child Attorney', fieldName: 'childAttorneyName', type: 'text', wrapText : true },
    { label: 'LDSS Attorney', fieldName: 'Name_of_LDSS_Attorney__c', type: 'text', wrapText : true },
    { label: 'Court Petition ID', fieldName: 'Court_Petition_ID__c', type: 'text', wrapText : true },
    { type: 'action', typeAttributes: { rowActions: actions } }

];
import UtilityBaseElement from 'c/utilityBaseLwc';
export default class PetitionRecordTableLwc extends UtilityBaseElement {

    @track columns = columns;
    @api petitionRecList = [];
    @track isSpinner = false;
    @track isShowOnly = false;
    @track visibleData = [];

    connectedCallback() {

    }

    handleRowAction(event) {

        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'show_details':
                /*this.petitionRec = row;
                this.isShowOnly = true;
                this.showPetitionModal = true;
                break;*/
                const petitionShowEvent = new CustomEvent('rowactionhandle', {
                    detail: {
                        petitionRec: row,
                        showPetitionModal: true,
                        isReadOnly: true,
                        showCINAPetDetail: (row.Type_of_Petition__c == 'CINA') ? true : false
                    }
                });
                this.dispatchEvent(petitionShowEvent);
                break;

            case 'edit':
                const petitionEditEvent = new CustomEvent('rowactionhandle', {
                    detail: {
                        petitionRec: row,
                        showPetitionModal: true,
                        isReadOnly: false,
                        showCINAPetDetail: (row.Type_of_Petition__c == 'CINA') ? true : false
                    }
                });
                this.dispatchEvent(petitionEditEvent);
                break;

            case 'delete':
                this.onDelPetition(row);
                break;
        }
    }

    onDelPetition(petitionRec) {

        let foundDelElement = this.petitionRecList.find(ele => ele.Id == petitionRec.Id);

        if (foundDelElement) {

            deleteRecord(foundDelElement.Id)
            //delPetitionRec({ petitionJSONStr: JSON.stringify(this.checkNamespaceApplicable(foundDelElement, true)) })
                .then(result => {
                    let res = result;
                    let rows = Object.assign([], this.petitionRecList);
                    const rowIndex = rows.indexOf(foundDelElement);
                    rows.splice(rowIndex, 1);
                    this.petitionRecList = rows;
                    const petitionDeleteEvent = new CustomEvent( 'deleteaction', {
                        detail : 'Courts (' + this.petitionRecList.length + ')'
                    });
                    this.dispatchEvent(petitionDeleteEvent);
                    
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
                    this.message = errorMsg;
                    this.fireToastMsg();
                })
        }
    }

    paginationHandler(event) {

        this.visibleData = [...event.detail.records];     
    }
}