import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getReceivableSummaryRec from '@salesforce/apex/CaseVaultCalloutHandler.getReceivableSummarySearch';
import getReceivableSummaryDetailsRec from '@salesforce/apex/CaseVaultCalloutHandler.getAllReceivableSummaryDetails';
import createReceiptdata from '@salesforce/apex/CaseVaultCalloutHandler.createReceipt';
import getReceiptSummaryRec from '@salesforce/apex/CaseVaultCalloutHandler.getAllReceiptSummary';

const receivableSummaryColumns = [
    { label: 'Receivable Summary Id', fieldName: 'receivableSummaryID', sortable: true },
    { label: 'Vendor Id', fieldName: 'vendorID', sortable: true },
    {
        label: 'Receivable Start Date', fieldName: 'receivableStartDate', type: 'date-local', sortable: true,
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    {
        label: "Receivable End Date", fieldName: "receivableEndDate", type: "date-local",
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    { label: 'Received Amount', fieldName: 'receivedAmount', type: 'number', typeAttributes: { formatStyle: "decimal", minimumFractionDigits: "2" }, sortable: true },
    { label: 'Final Receivable Balance Amount', fieldName: 'finalReceivableBalanceAmount', fixedWidth: 300,type: 'number', typeAttributes: { formatStyle: "decimal", minimumFractionDigits: "2" }, sortable: true }
];

const receivableSummaryDetailColumns = [
    { label: 'Receivable Detail Id', fieldName: 'receivableDetailID', sortable: true },
    { label: 'Vendor Id', fieldName: 'vendorID', sortable: true },
    {
        label: 'Receivable Start Date', fieldName: 'receivableStartDate', type: 'date-local', sortable: true,
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    {
        label: "Receivable End Date", fieldName: "receivableEndDate", type: "date-local",
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    { label: 'Received Amount', fieldName: 'receivedAmount', type: 'number', typeAttributes: { formatStyle: "decimal", minimumFractionDigits: "2" }, sortable: true },
    { label: 'Final Receivable Balance Amount', fieldName: 'finalReceivableBalanceAmount', type: 'number',fixedWidth: 300, typeAttributes: { formatStyle: "decimal", minimumFractionDigits: "2" }, sortable: true }
];

const receiptSummaryColumns = [
    { label: 'Receipt Summary ID', fieldName: 'receiptSummaryID', sortable: true },
    { label: 'Vendor Id', fieldName: 'vendorID', sortable: true },
    { label: 'Receipt Amount', fieldName: 'receiptAmount', type: 'number', typeAttributes: { formatStyle: "decimal", minimumFractionDigits: "2" }, sortable: true },
    { label: 'Receipt Type', fieldName: 'receiptType', sortable: true },
    { label: 'Comments', fieldName: 'comments', sortable: true },
    {
        label: "Receipt Date", fieldName: "receiptDate", type: "date-local",
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    { label: 'Reference Number', fieldName: 'referenceNo', sortable: true }
];
export default class CasevaultReceivableApiLwc extends LightningElement {

    receivableSummaryColumns = receivableSummaryColumns;
    receivableSummaryDetailColumns = receivableSummaryDetailColumns;
    receiptSummaryColumns = receiptSummaryColumns;
    @track receivableSummaryData = [];
    @track receiptSummaryData = [];
    @track receivableSummaryDetailData = [];
    @track receivableSummaryId;
    @track vendorId;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    isLoadingReceivableSummaryData = false;
    isLoadingReceiptSummaryData = false;
    isLoadingReceivableSummaryDetailData = false;
    @track enableButton = true;
    showModal = false;
    @track totalReceivableAmount;
    @track createReceiptRecord = {};
    sortedBy;
    @track isLoading = false;
    @track setSelectedRows1 = [];
    @track setSelectedRows2 = [];
    @track visibleData = [];
    @track visibleData1 = [];
    @track visibleData2 = [];
    showChild = false;
    showChild1 = false;
    showChild2 = false;
    get options() {
        return [
            { label: 'Check', value: 'check' },
            { label: 'Money Order', value: 'moneyorder' },
            { label: 'Cash', value: 'cash' },
        ];
    }
    sortBy(field, reverse, primer) {
        const key = primer ?

            function (x) {
                return primer(x[field]);
            } :
            function (x) {
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
        const cloneData = [...this.paymentSummaryData];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.paymentSummaryData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    handleKeyUp(evt) {
        this.setSelectedRows1 = [];
        this.setSelectedRows2 = [];
        const isEnterKey = evt.keyCode === 13;
        this.showChild = false;
        if (isEnterKey) {
            this.isLoadingReceivableSummaryData = true;
            getReceivableSummaryRec({ receivableSummaryId: parseInt(evt.target.value) })
                .then(result => {
                    let res = JSON.parse(result);
                    this.isLoadingReceivableSummaryData = false;
                    if (res.status == 'success') {
                        this.receivableSummaryData = res.data;
                        this.receivableSummaryDetailData = [];
                        this.receiptSummaryData = [];
                    } else if (res.status == 'error') {
                        this.receivableSummaryData = [];
                        this.receivableSummaryDetailData = [];
                        this.receiptSummaryData = [];
                        let errorMsg = res.error.message;
                        const event = this.onToastEvent('warning', 'Warning!', errorMsg);
                        this.dispatchEvent(event);
                        this.createReceiptRecord.vendorID = '';
                        this.totalReceivableAmount = '';
                    }
                    this.showChild = true;
                }).catch(error => {
                });
        }
    }

    handleRowClick(evt) {

        this.setSelectedRows2 = [];
        this.createReceiptRecord.vendorID = evt.detail.selectedRows[0].vendorID;
        this.totalReceivableAmount = evt.detail.selectedRows[0].finalReceivableBalanceAmount;
        this.receivableSummaryId = evt.detail.selectedRows[0].receivableSummaryID;
        this.showChild1 = false;
        if (this.receivableSummaryId) {
            getReceivableSummaryDetailsRec({ receivableSummaryId: this.receivableSummaryId })
                .then(result => {
                    let res = JSON.parse(result);
                    if (res.status == 'success') {
                        this.receivableSummaryDetailData = res.data;
                        this.receiptSummaryData = [];
                    } else if (res.status == 'error') {
                        this.receivableSummaryDetailData = [];
                        let errorMsg = res.error.message;
                        const event = this.onToastEvent('warning', 'Warning!', errorMsg);
                        this.dispatchEvent(event);
                    }
                    this.showChild1 = true;
                }).catch(error => {
                });
        }
       
    }

    handleRowClickReceiptrecord(evt) {

        let row = evt.detail.selectedRows[0];
        this.vendorId = row.vendorID;
        this.showChild2 = false;
        if (this.vendorId) {
            this.isLoading = true;
            getReceiptSummaryRec({ vendorId: this.vendorId })
                .then(result => {
                    let res = JSON.parse(result);

                    if (res.status == 'success') {
                        this.receiptSummaryData = res.data;
                    } else if (res.status == 'error') {
                        this.receiptSummaryData = [];
                        let errorMsg = res.error.message;
                        const event = this.onToastEvent('warning', 'Warning!', errorMsg);
                        this.dispatchEvent(event);
                    }
                    this.showChild2 = true;
                }).catch(error => {
                });
            this.isLoading = false;
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
    openModal(event) {
        this.showModal = true;
    }
    hideModal() {
        this.showModal = false;
        this.createReceiptRecord = {};
        this.enableButton = true;
    }
    handledata() {
        if (this.totalReceivableAmount > this.createReceiptRecord.receiptAmount) {
            createReceiptdata({ receiptAmount: this.createReceiptRecord.receiptAmount, receiptDate: this.createReceiptRecord.receiptDate, receiptType: this.createReceiptRecord.receiptType, referenceNo: this.createReceiptRecord.referenceNo, vendorID: this.createReceiptRecord.vendorID, comments: this.createReceiptRecord.comments })
                .then(() => {


                }).catch(error => {
                });
            this.showModal = false;
        } else {
            const event = this.onToastEvent('error', 'Error!', 'Receipt Amount is less than Total Receivable Amount');
            this.dispatchEvent(event);
        }
    }
    handleChange(event) {

        if (event.target.name == 'Receipt Amount') {
            this.createReceiptRecord.receiptAmount = event.target.value;
        } else if (event.target.name == 'Receipt Type') {
            this.createReceiptRecord.receiptType = event.target.value;

        } else if (event.target.name == 'Comment') {
            this.createReceiptRecord.comments = event.target.value;

        } else if (event.target.name == 'Receipt Date') {
            this.createReceiptRecord.receiptDate = event.target.value;

        } else if (event.target.name == 'Reference Number') {
            this.createReceiptRecord.referenceNo = event.target.value;

        }
        if (this.createReceiptRecord.receiptAmount && this.createReceiptRecord.receiptType && this.createReceiptRecord.comments && this.createReceiptRecord.receiptDate && this.createReceiptRecord.referenceNo) {
            this.enableButton = false;
        } else {
            this.enableButton = true;
        }
    }

    paginationHandler(event) {

        this.visibleData = [...event.detail.records];

    }

    paginationHandler1(event) {

        this.visibleData1 = [...event.detail.records];

    }
    paginationHandler2(event) {

        this.visibleData2 = [...event.detail.records];

    }
}