import { LightningElement, api, track } from 'lwc';
import getPlacementTableRec from '@salesforce/apex/CasePlanController.getPlacementTableRecords';
import getPlacement from '@salesforce/apex/CasePlanController.getPlacementRecords';

import UtilityBaseElement from 'c/utilityBaseLwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';


const actions = [
    { label: 'Delete', name: 'delete' }
];

const gridColumns = [{ label: 'Name', fieldName: 'recordUrl', type: 'url', target: '_self', wrapText: 'true', typeAttributes: { label: { fieldName: 'Name' } } },
    { label: 'Child Name', fieldName: 'child', type: 'text', wrapText: 'true' },
    {
        label: 'From Date',
        fieldName: 'From_Date__c',
        type: 'date',
        wrapText: 'true',
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric",
            timeZone: "UTC"
        }
    },
    {
        label: 'To Date',
        fieldName: 'To_Date__c',
        type: 'date',
        wrapText: 'true',
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric",
            timeZone: "UTC"
        }
    },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
        cellAttributes: {
            class: { fieldName: 'cssClass' }
        }
    }
];

const casePlanVersionFilterColumns = [{ label: 'Period Range', fieldName: 'PeriodRange', type: 'string', wrapText: true },
    { label: 'Timeframe', fieldName: 'Timeframe', type: 'string', wrapText: true },
    {
        label: 'From Date',
        fieldName: 'FromDate',
        type: 'date',
        wrapText: true,
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric",
            timeZone: "UTC"
        }
    },
    {
        label: 'To Date',
        fieldName: 'ToDate',
        type: 'date',
        wrapText: true,
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric",
            timeZone: "UTC"
        }
    },
    { label: 'Completed', fieldName: '', type: 'string', wrapText: true }
];

export default class CaseplanUnderPlacement extends UtilityBaseElement {

    gridColumns = gridColumns;
    gridData = [];
    @api recordId;
    @track PlacementRecordList = [];
    @track showCasePlanFilterModal = false;
    casePlanVersionFilterColumns = casePlanVersionFilterColumns;
    @track placementPicklist = [];
    @track placementId;
    @track filterRecord = {};
    @track casePlanFilterList = [];
    @track Periodrange = {};
    @track days = {};
    @track timeFrame = {};
    @track casePlanVersionRecord = {};
    @track showConfirmationModal = false;
    @track removaldate;

    @track showFilterTable = false;

    get options() {
        return [
            { label: 'Period Range', value: 'PeriodRange' },
            { label: 'Date Range', value: 'DateRange' },
        ];
    }

    connectedCallback() {

        this.doInit();
    }

    doInit() {
        this.Periodrange[1] = '0 - 60 days';
        this.Periodrange[2] = '60 - 180 days';
        this.Periodrange[3] = '180 - 360 days';
        this.Periodrange[4] = '360 - 540 days';
        this.Periodrange[5] = '540 - 720 days';
        this.Periodrange[6] = '720 - 900 days';
        this.Periodrange[7] = '900 + days';

        this.timeFrame[1] = '0-2 months';
        this.timeFrame[2] = '2-6 months';
        this.timeFrame[3] = '6-12 months';
        this.timeFrame[4] = '12-18 months';
        this.timeFrame[5] = '18-24 months';
        this.timeFrame[6] = '24-30 months';
        this.timeFrame[7] = '30+ months';

        this.days[1] = 0;
        this.days[2] = 60;
        this.days[3] = 180;
        this.days[4] = 360;
        this.days[5] = 540;
        this.days[6] = 720;
        this.days[7] = 900;

        getPlacementTableRec({ serviceCaseId: this.recordId })
            .then(result => {
                let caseDataList = [];
                let caseLst = [];
                this.placementPicklist = JSON.parse(result).placementPicklist;
                let placementRecordList = this.checkNamespaceApplicable(JSON.parse(result).placementRecordList, false);
                let caseRecordList = this.checkNamespaceApplicable(JSON.parse(result).casePlanRecords, false);

                if (placementRecordList.length > 0) {
                    for (let i = 0; i < placementRecordList.length; i++) {
                        caseLst = [];
                        placementRecordList[i].cssClass = 'slds-hide';
                        placementRecordList[i].recordUrl = '/lightning/r/' + placementRecordList[i].Id + '/view';
                        if (placementRecordList[i].Child__r) {
                            placementRecordList[i].child = placementRecordList[i].Child__r.Name;
                        }
                        for (let j = 0; j < caseRecordList.length; j++) {
                            if (caseRecordList[j].Placement__c == placementRecordList[i].Id) {
                                caseRecordList[j].recordUrl = '/lightning/r/' + caseRecordList[i].Id + '/view';
                                caseRecordList[j].cssClass = 'slds-show';
                                caseRecordList[j].child = placementRecordList[i].Child__r.Name;
                                caseLst.push(caseRecordList[j]);
                            }
                        }
                        placementRecordList[i]._children = caseLst;
                        caseDataList.push(placementRecordList[i]);
                    }
                    this.gridData = caseDataList;
                }
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

    handleRowAction(event) {

        var selectedRow = event.detail.row;
        deleteRecord(selectedRow.Id)
            .then(() => {
                this.title = "Success!";
                this.type = "success";
                this.message = 'CasePlan record deleted successfully!';
                this.fireToastMsg();
                this.doInit();
            })
            .catch(error => {
                this.handleError(error);
            });
    }

    handleNew() {

        this.showCasePlanFilterModal = true;
    }

    closeCasePlanFilterModal() {

        this.showCasePlanFilterModal = false;
        this.casePlanFilterList = [];
        this.showFilterTable = false;
        this.showFilterTable = false;
    }

    handleChildChange(event) {

        if (event.target.name == 'Type') {
            if (event.target.value == 'PeriodRange') {
                this.showFilterTable = false;
            } else {
                this.showFilterTable = true;
            }

        } else if (event.target.name == 'Placement__c') {
            this.placementId = event.target.value;
            getPlacement({ placementId: event.target.value })
                .then(res => {
                    this.generateCasePlanVersionFilter(JSON.parse(res).placementRecord);
                })
                .catch(error => {
                    this.handleError(error);
                });
        } else {
            this.casePlanVersionRecord[event.target.name] = event.target.value;
        }
    }

    handleError(error) {

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
    }

    generateCasePlanVersionFilter(row) {

        let filterList = [];
        for (let i = 0; i < 7; i++) {

            this.removaldate = row.Child_Removal__r.Removal_Date_of_DT_F__c;
            this.filterRecord.PeriodRange = this.Periodrange[i + 1];
            this.filterRecord.Timeframe = this.timeFrame[i + 1];
            this.filterRecord.FromDate = new Date(this.removaldate);
            this.filterRecord.FromDate = new Date(this.filterRecord.FromDate.setDate(this.filterRecord.FromDate.getDate() + this.days[i + 1]));
            if (i != 6) {
                this.filterRecord.ToDate = new Date(this.removaldate);
                this.filterRecord.ToDate = new Date(this.filterRecord.ToDate.setDate(this.filterRecord.ToDate.getDate() + this.days[i + 2]));
            }
            this.filterRecord.FromDate = this.filterRecord.FromDate;
            this.filterRecord.ToDate = this.filterRecord.ToDate;
            filterList.push(this.filterRecord);
            this.filterRecord = {};
        }
        this.casePlanFilterList = filterList;
    }

    handleCasePlanFilterRowAction(event) {

        var selectedRows = event.detail.selectedRows;
        var row = selectedRows[0];
        this.casePlanVersionRecord.Period__c = row.Timeframe;
        this.casePlanVersionRecord.From_Date__c = row.FromDate;
        this.casePlanVersionRecord.To_Date__c = row.ToDate;
    }

    handleCasePlanRecord() {

        this.casePlanVersionRecord.Placement__c = this.placementId;
        this.casePlanVersionRecord.Approval_Status__c = 'Status-Draft';
        const fields = this.casePlanVersionRecord;
        const recordInput = { apiName: 'Case_Plan__c', fields };
        createRecord(recordInput)
            .then(result => {

                this.showConfirmationModal = false;
                this.showFilterTable = false;
                this.title = 'Success!';
                this.type = 'success';
                this.message = 'CasePlanVersion Created Successfully!';
                this.fireToastMsg();
                this.showConfirmationModal = false;
                this.doInit();
            })
            .catch(error => {

                this.loading = false;
                this.handleError(error);
            });
    }

    openConfirmationModal() {

        this.showCasePlanFilterModal = false;
        this.showConfirmationModal = true;

    }

    closeConfirmationModal() {
        this.showConfirmationModal = false;
        this.showFilterTable = false;

    }
}