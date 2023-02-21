import { LightningElement, track } from 'lwc';
import getSummaryRec from '@salesforce/apex/CaseVaultCalloutHandler.getSummarySearch';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSummaryDetailsRec from '@salesforce/apex/CaseVaultCalloutHandler.getAllSummaryDetails';
import UtilityBaseElement from 'c/utilityBaseLwc';

const paymentSummarycolumns = [
    { label: 'Payment Id', fieldName: 'paymentSummaryID', sortable: true },
    { label: 'Vendor Name', fieldName: 'vendorID', sortable: true},
    { label: 'Period Start Date', fieldName: 'periodStartDate', type: 'date-local', sortable: true, 
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    { label: "Period End Date", fieldName: "periodEndDate", type: "date-local",
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    { label: 'Payment Amount', fieldName: 'paymentAmount', type:'number',typeAttributes: { formatStyle:"decimal",minimumFractionDigits:"2"}, sortable: true},
    { label: "Payment Date", fieldName: "paymentDate", type: "date-local",
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    { label: 'Payment Type', fieldName: 'paymentType',type: 'string', sortable: true },
    { label: 'Vendor Type', fieldName: 'vendorType', type: 'string',sortable: true }
];

const paymentDetailColumns = [

    { label: 'Client Id', fieldName: 'detailID', sortable: true },
    { label: 'Period Start Date', fieldName: 'periodStart', type: 'date-local', sortable: true, 
    typeAttributes: {
        month: "2-digit",
        day: "2-digit"
    }
    },
    { label: "Period End Date", fieldName: "periodEnd", type: "date-local",
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    { label: 'Service Type', fieldName: 'serviceType', type: 'string', sortable: true},
    { label: 'Days of Service', fieldName: 'daysOfService',  sortable: true},
    { label: 'Per Diem Rate', fieldName: 'perdiemRate',type:'number',typeAttributes: { formatStyle:"decimal",minimumFractionDigits:"2"}, sortable: true},
    { label: 'Payment Amount', fieldName: 'paymentAmount', type:'number',typeAttributes: { formatStyle:"decimal",minimumFractionDigits:"2"}, sortable: true},
    { label: 'Placement Id', fieldName: 'placementID', sortable: true },
    { label: 'Linked Payment Header', fieldName: 'linkedPaymentDetail', sortable: true },
    { label: 'Final Amount', fieldName: 'finalAmount', type:'number',typeAttributes: { formatStyle:"decimal",minimumFractionDigits:"2"}, sortable: true},
    { label: "Payment Date", fieldName: "paymentDate", type: "date-local",
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    }
];

export default class CasevaultPaymentMgmtApiLwc extends UtilityBaseElement {

    @track paymentSummaryData = [];
    paymentSummarycolumns = paymentSummarycolumns;
    paymentDetailColumns = paymentDetailColumns;
    @track paymentDetailData = [];
    @track summaryId;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    isLoadingPaymentSummaryData=false;
    isLoadingPaymentDetailData=false;
    @track visibleData = [];
    @track visibleData1 = [];
    showChild = false;
    showChild1 = false;
    setSelectedRows = [];
    @track fakeprovider = [];
    @track fakeclient = [];

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

        this.fakeprovider[51]='Steve Smith';
        this.fakeprovider[418]='John Doe';
        this.fakeprovider[425]='John Smith';
        this.fakeprovider[420]='James Simth';
        this.fakeprovider[423]='John Doe';
        this.fakeprovider[490]='Anthony S';
        this.fakeprovider[112]='William Doe';
        this.fakeprovider[419]='John Mitchel';
        this.fakeprovider[421]='Rose';

        this.fakeclient[3903]='Brown';
        this.fakeclient[428]='Smith';
        this.fakeclient[429]='Robert';
        this.fakeclient[430]='Wilson';
        this.fakeclient[431]='Thomas';
        this.fakeclient[428]='Harris';
        this.fakeclient[431]='Lewis';
        this.fakeclient[500]='David';
        this.fakeclient[435]='winter';

        if (isEnterKey) {
            this.showChild = false;
            this.isLoadingPaymentSummaryData=true;
            getSummaryRec({summaryId: parseInt(evt.target.value)})
            .then(result => {
                this.setSelectedRows = [];
                this.paymentDetailData = [];
                this.visibleData1 = [];
                this.isLoadingPaymentSummaryData=false;
                let res = JSON.parse(result);
                if (res.status == 'success') {
                    this.paymentSummaryData = res.data;
                    for(let i=0;i<this.paymentSummaryData.length;i++) {
                        this.paymentSummaryData[i].vendorID = this.fakeprovider[this.paymentSummaryData[i].paymentSummaryID];
                    }
                    this.showChild = true;
                } else if (res.status == 'error') {
                    this.paymentSummaryData = [];
                    this.paymentDetailData = [];
                    let errorMsg = res.error.message;
                    const event = this.onToastEvent('warning', 'Warning!', errorMsg);
                    this.dispatchEvent(event); 
                
                }
            }).catch(error => {

                this.isLoadingPaymentSummaryData=false;
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

        
        //this.summaryId = evt.currentTarget.getAttribute('data-name');
        let row = evt.detail.selectedRows[0];
        this.summaryId  = row.paymentSummaryID;
        if (this.summaryId) {
            this.showChild1 = false;
            this.isLoadingPaymentDetailData=true;
            getSummaryDetailsRec({summaryId: parseInt(this.summaryId)})
        .then(result => {
            let res = JSON.parse(result);
            this.isLoadingPaymentDetailData=false;
            if (res.status == 'success') {
                this.paymentDetailData = res.data;
                for(let i=0;i<this.paymentDetailData.length;i++) {
                    this.paymentDetailData[i].detailID = this.fakeclient[this.paymentDetailData[i].detailID];
                }
                this.showChild1 = true;
                } else if (res.status == 'error') {
                    this.paymentDetailData = [];
                    let errorMsg = res.error.message;
                    const event = this.onToastEvent('warning', 'Warning!', errorMsg);
                    this.dispatchEvent(event); 
                }
         }).catch(error => {

            this.isLoadingPaymentDetailData=false;
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
        for (let i=0; i<this.paymentSummaryData.length; i++) {
            this.paymentSummaryData[i].selectedRow = '';
            if ( parseInt(evt.currentTarget.getAttribute('data-label')) == i) {
                this.paymentSummaryData[i].selectedRow = 'selectedRowClass';
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