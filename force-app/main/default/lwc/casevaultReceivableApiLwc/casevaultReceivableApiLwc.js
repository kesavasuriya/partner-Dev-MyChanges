import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getReceivableSummaryRec from '@salesforce/apex/CaseVaultCalloutHandler.getReceivableSummarySearch';
import getReceivableSummaryDetailsRec from '@salesforce/apex/CaseVaultCalloutHandler.getAllReceivableSummaryDetails';
import UtilityBaseElement from 'c/utilityBaseLwc';

const receivableSummaryColumns = [
    { label: 'Receivable Summary Id', fieldName: 'receivableSummaryID', sortable: true },
    { label: 'Vendor Id', fieldName: 'vendorID',  sortable: true},
    { label: 'Receivable Start Date', fieldName: 'receivableStartDate', type: 'date-local', sortable: true, 
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    { label: "Receivable End Date", fieldName: "receivableEndDate", type: "date-local",
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    { label: 'Received Amount', fieldName: 'receivedAmount',type: 'number',typeAttributes: { formatStyle:"decimal",minimumFractionDigits:"2"},sortable: true },
    { label: 'Final Receivable Balance Amount', fieldName: 'finalReceivableBalanceAmount', fixedWidth: 300,type: 'number',typeAttributes: { formatStyle:"decimal",minimumFractionDigits:"2"},sortable: true }
];

const receivableSummaryDetailColumns = [
    { label: 'Receivable Detail Id', fieldName: 'receivableDetailID', sortable: true },
    { label: 'Vendor Id', fieldName: 'vendorID', sortable: true},
    { label: 'Receivable Start Date', fieldName: 'receivableStartDate', type: 'date-local', sortable: true, 
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    { label: "Receivable End Date", fieldName: "receivableEndDate", type: "date-local",
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    { label: 'Received Amount', fieldName: 'receivedAmount',type: 'number',typeAttributes: { formatStyle:"decimal",minimumFractionDigits:"2"},sortable: true },
    { label: 'Final Receivable Balance Amount', fieldName: 'finalReceivableBalanceAmount',fixedWidth: 300, type: 'number', type: 'number',typeAttributes: { formatStyle:"decimal",minimumFractionDigits:"2"},sortable: true }
];


export default class CasevaultReceivableApiLwc extends UtilityBaseElement {

    receivableSummaryColumns = receivableSummaryColumns;
    receivableSummaryDetailColumns = receivableSummaryDetailColumns;
    @track receivableSummaryData = [];
    @track receivableSummaryDetailData = [];
    @track ReceivableSummaryId = '';
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    isLoadingReceivableSummaryData=false;
    isLoadingReceivableSummaryDetailData=false;
    @track visibleData = [];
    showChild = false;
    @track visibleData1 = [];
    showChild1 = false;
    setSelectedRow = [];

    // Used to sort the 'Age' column
    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.paymentSummaryData];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.paymentSummaryData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        
        if (isEnterKey) {
        this.setSelectedRow = [];
        this.receivableSummaryDetailData = [];
        this.isLoadingReceivableSummaryData=true;
        this.showChild = false;
        getReceivableSummaryRec({receivableSummaryId: parseInt(evt.target.value)})
        .then(result => {
            this.isLoadingReceivableSummaryData=false;
           
            let res = JSON.parse(result);
            if (res.status == 'success') {
            this.receivableSummaryData = res.data;
            this.showChild = true;
            this.receivableSummaryDetailData = [];
            } else if (res.status == 'error') {
                this.receivableSummaryData = [];
                this.receivableSummaryDetailData = [];
                let errorMsg = res.error.message;
                const event = this.onToastEvent('warning', 'Warning!', errorMsg);
                this.dispatchEvent(event); 
            }
         }).catch(error => {

            this.isLoadingReceivableSummaryData=false;
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

    handleRowClick(evt) {

        //this.ReceivableSummaryId = evt.currentTarget.getAttribute('data-name');
        this.ReceivableSummaryId = evt.detail.selectedRows[0].receivableSummaryID;
        if (this.ReceivableSummaryId) {
            this.isLoadingReceivableSummaryDetailData=true;
            this.showChild1 = false;
            getReceivableSummaryDetailsRec({receivableSummaryId: parseInt(this.ReceivableSummaryId)})
        .then(result => {
            let res = JSON.parse(result);
            this.isLoadingReceivableSummaryDetailData=false;
            if (res.status == 'success') {
            this.receivableSummaryDetailData = res.data;
            this.showChild1 = true;
            } else if (res.status == 'error'){
                this.receivableSummaryDetailData = [];
                let errorMsg = res.error.message;
                const event = this.onToastEvent('warning', 'Warning!', errorMsg);
                this.dispatchEvent(event); 
            }
         }).catch(error => {

            this.isLoadingReceivableSummaryDetailData=false;
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
        for (let i=0; i<this.receivableSummaryData.length; i++) {
            this.receivableSummaryData[i].selectedRow = '';
            if ( parseInt(evt.currentTarget.getAttribute('data-label')) == i) {
                this.receivableSummaryData[i].selectedRow = 'selectedRowClass';
            }
        }
    } 

    onToastEvent(type, toastTitle, msg) {

        const toastEvent = new ShowToastEvent({
            variant: type,
            title: toastTitle,
            message: msg,
        });
        return toastEvent;
    }

    paginationHandler(event) {

        this.visibleData = [...event.detail.records];     
    }
    paginationHandler1(event) {

        this.visibleData1 = [...event.detail.records];     
    }
}