import { LightningElement,track, api } from 'lwc';
import getPlacements from '@salesforce/apex/FinanceController.getAllPlacement';
import { NavigationMixin } from 'lightning/navigation';
import UtilityBaseElement from 'c/utilityBaseLwc';
import submitforApproval from '@salesforce/apex/FinanceController.onSubmitForApproval';
import { updateRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';

const Columns = [
    { label: 'Child Name', fieldName: 'child', wrapText: true, type: 'string',fixedWidth: 200 },
    { label: 'Current Placement Name', fieldName: 'Name', wrapText: true, type: 'string',fixedWidth: 300 },
    { label: 'Current Placement Structure', fieldName: 'Placement_Structure__c', wrapText: true, type: 'string',fixedWidth: 300 },
    { label: 'Placement Start Date ', fieldName: 'Begin_Date__c', type: 'date',fixedWidth: 200,  typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Placement End Date', fieldName: 'Exit_End_Date__c', type: 'date',  fixedWidth: 200, typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },   
    { label: 'Payment Start Date', fieldName: 'Start_Date__c', type: 'date', fixedWidth: 200, typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Days of Service', fieldName: 'Days_of_Service__c',  type: 'number', fixedWidth: 200},
    { label: 'Payment End Date', fieldName: 'End_Date__c', type: 'date', fixedWidth: 200, typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Amount of Payment', fieldName: 'Payment_Amount__c',  type: 'number' , fixedWidth: 200},
    { label: 'Approved', fieldName: 'Approved_Date_Time__c', wrapText: true, type: 'date', fixedWidth: 200, typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
        hour12: "true"
    }},
    { label: 'Approved By', fieldName: 'Approver', wrapText: true, type: 'string', fixedWidth: 300 },
    
];

const Columns1 = [
    { label: 'Approved', type: "button",fixedWidth: 200, typeAttributes: {  
        label: 'Approve',    
        disabled: {fieldName:'enableApprove'},  
        value: 'approve',  
        iconPosition: 'left'  
    }} ,
    { label: 'Child Name', fieldName: 'child', wrapText: true, type: 'string',fixedWidth: 200 },
    { label: 'Current Placement Name', fieldName: 'Name', wrapText: true, type: 'string',fixedWidth: 300 },
    { label: 'Current Placement Structure', fieldName: 'Placement_Structure__c', wrapText: true, type: 'string',fixedWidth: 300 },
    { label: 'Placement Start Date ', fieldName: 'Begin_Date__c', type: 'date', fixedWidth: 200, typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Placement End Date', fieldName: 'Exit_End_Date__c', type: 'date', fixedWidth: 200,  typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Payment Start Date', fieldName: 'Start_Date__c', type: 'date', fixedWidth: 200,  typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Days of Service', fieldName: 'Days_of_Service__c', fixedWidth: 200, type: 'number'},
    { label: 'Payment End Date', fieldName: 'End_Date__c', type: 'date', fixedWidth: 200, typeAttributes: { day: "numeric", month: "numeric", year: "numeric", timeZone: "UTC" } },
    { label: 'Amount of Payment', fieldName: 'Payment_Amount__c', fixedWidth: 200, type: 'number' },
     
   
];

export default class PlacementUnderFinanceLwc extends NavigationMixin(UtilityBaseElement) {

    @track userId = Id;
    @api showApprove;
    Columns = Columns;
    Columns1 = Columns1;
    @track placementList = [];
    @track approvedPlacements = [];
    @track pendingPlacements = [];
    @track loading = false;
    @track visibleData =[];
    @track visibleData1 =[];
    showWarning = false;
    @track paymentRecord = {};
    showPagination = false;
    currentDateTime;

    connectedCallback() {

        this.loading = true;
        this.doInitInfo();
        console.log('in',this.showApprove);


    }

    doInitInfo() {
        getPlacements({})
        .then(result =>{

            let res = JSON.parse(result).placements;
            let payment = JSON.parse(result).paymentSummaryRecords;
            this.currentTime = JSON.parse(result).currentTime;
            let init ={};
            if(res.length) {
                for(let i =0 ; i<payment.length;i++) {

                        if(payment[i].Person__r.Name) {
                            init.child = payment[i].Person__r.Name;
                        }
                        if(payment[i].Provider__r.Name) {
                            init.provider = payment[i].Provider__r.Name;
                        }
                        init.Status__c = payment[i].Status__c;
                        init.enableApprove = this.showApprove;
                        let foundElement = res.find(ele => ele.Child__c == payment[i].Person__c && ele.Provider__c == payment[i].Provider__c);                    
                        if(foundElement) {
                            init.Placement_Structure__c = foundElement.Placement_Structure__c;
                            init.Begin_Date__c = foundElement.Begin_Date__c;
                            init.Exit_End_Date__c = foundElement.Exit_End_Date__c;
                            init.placementId = foundElement.Id;
                            init.Name = foundElement.Name;
                            console.log('found',foundElement);
                        }
                        init.Days_of_Service__c = payment[i].Days_of_Service__c;
                        init.Payment_Amount__c = payment[i].Payment_Amount__c;
                        init.Id = payment[i].Id;
                        init.Start_Date__c = payment[i].Start_Date__c;
                        init.End_Date__c = payment[i].End_Date__c;
                    if(init.Status__c == "Approved") {
                        init.Approved_Date_Time__c = payment[i].Approved_Date_Time__c;
                        init.Approver = payment[i].Supervisor_Approval__r.Name;
                        this.approvedPlacements.push(init);
                        init = {};

                    } else {

                        this.pendingPlacements.push(init);
                        init = {};

                    }
                    init = {};
                }
            }
            console.log('5',this.pendingPlacements);
            this.showPagination = true;
            this.loading = false;
        })
    }
   
    handleRowAction(event) {

        let row = event.detail.row;
        this.paymentRecord = row;
        this.showWarning = true;


    }

    paginationHandler(event) {

        this.visibleData = [...event.detail.records];  
        console.log(this.visibleData);   
    }

    paginationHandler1(event) {

        this.visibleData1 = [...event.detail.records];     
    }

    handleCancel() {
        this.showWarning = false;
        const fields = {};
        fields.Id = this.paymentRecord.Id;
        fields.Status__c = 'Approved';
        fields.Supervisor_Approval__c = this.userId;
        fields.Approved_Date_Time__c = this.currentTime;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.title = 'Success!';
                this.type = 'success';
                this.message = 'Record was Approved';
                this.fireToastMsg();
                this.showPagination = false;
                this.doInitInfo();
                });

    }

    handleProcced() {

        this.showWarning = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.paymentRecord.placementId,
                objectApiName: 'Placement__c',
                actionName: 'view'
            },
        });

    }


    handleCloseModal() {
        this.paymentRecord = {};
        this.showWarning = false;
    }


}