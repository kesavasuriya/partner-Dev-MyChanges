import { LightningElement, api, track } from 'lwc';
import getPlacementChildRemovalRecords from '@salesforce/apex/PlacementController.getPlacementUnderChildRemoval';
import getChildValues from '@salesforce/apex/PlacementController.getChildRemovalRecords';
import UtilityBaseElement from 'c/utilityBaseLwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import { subscribe, onError } from 'lightning/empApi';

const actions = [
    { label: 'Delete', name: 'delete' }
];

const gridColumns = [ { label : 'Name' ,  fieldName : 'recordUrl', type : 'url', target : '_self', wrapText:'true',  typeAttributes : {  label : { fieldName : 'recordName'} }},
{ label : 'Child',  fieldName : 'childName', type : 'text', wrapText:'true'},
{ label : 'Removal Date',  fieldName :'removalDate', type:'text', wrapText:'true'},
{ label : 'Provider',  fieldName : 'providerName', type : 'text', wrapText:'true' },
{ label : 'Begin Date',  fieldName : 'beginDate', type: 'date',typeAttributes : { month : "numeric", day: "numeric", year : "numeric",hour:"numeric",minute:"numeric",hour12:"true" ,timeZone: TIME_ZONE}},
{ label : 'End Date',  fieldName : 'endDate', type : 'date',typeAttributes : { month : "numeric", day: "numeric", year : "numeric", timeZone: "UTC"} },
{ label : 'Placement Structure',  fieldName : 'placementStructure', type : 'text', wrapText : 'true'},
{ label : 'Exit Type',  fieldName : 'exitType', type : 'text', wrapText:'true'},
{ label : 'Placement Approval Status',  fieldName : 'placementApprovalStatus', type : 'text', wrapText:'true'},
{ label : 'Exit Approval Status',  fieldName : 'exitApprovalStatus', type : 'text', wrapText:'true'},
{
    type: 'action',
    typeAttributes: { rowActions: actions}, cellAttributes: { class : { fieldName : 'cssClass'}}
}
];

export default class PlacementUnderChildRemovalLwc extends UtilityBaseElement {

    @api recordId;
    gridColumns = gridColumns;
    @track gridData = [];
    @track cardTitle = '';
    showNew = false;
    placementCount = 0;
    showModal = false;
    @track childOptions = [];
    childId;
    @track placementRecordList = [];
    @track childRemovallist = [];
    isLoading = false;
    subscription = {};
    CHANNEL_NAME = '/data/Placement__ChangeEvent';
    showFlowScreen = false;
    @track placementType;
    showplacementType = false;
    showLivingArrangementFlow = false;
    showFlowButton = false;
    showPlacementFlow = false;

    get inputvariable() {
        return[{
            name : 'recordId',
            type : 'String',
            value : this.recordId
        }
    ]
    }
    
    options=[{label:"Placement", value:"placement"},
             {label:"Living Arrangement", value:"living arrangement"}];

    connectedCallback() {

        subscribe(this.CHANNEL_NAME, -1, this.refreshList).then(response => {
            this.subscription = response;
        });
        onError(error => {});
        this.doInit();
    }

    refreshList = () => {

        this.doInit();
    }

    doInit() {

        this.isLoading = true;
        getPlacementChildRemovalRecords( { servicecaseId : this.recordId})
        .then(result => {
            let parseResult = JSON.parse(result);
            let response = parseResult.childRemovalRecordList;
            this.childRemovallist = parseResult.childRemovalRecordList;
            this.showNew = parseResult.isOpenServiceCase;
            let dataList = [];
            for ( let i = 0 ; i < response.length; i++) {
                let childRemovalIns = {};
                childRemovalIns.Id = response[i].Id;
                childRemovalIns.recordName = response[i].Name;
                childRemovalIns.recordUrl = '/lightning/r/'+response[i].Id+'/view';
                childRemovalIns.childName = response[i].Child__r.Name;
                childRemovalIns.removalDate = response[i].Removal_DateF__c;
                childRemovalIns.cssClass = 'slds-hide';
                if(response[i].Placements__r) {
                    let childList = [];
                    this.placementCount = this.placementCount + response[i].Placements__r.records.length;
                    for( let j = 0; j < response[i].Placements__r.records.length ; j++) {
                        let placementIns = {};
                        let currentIteration = response[i].Placements__r.records[j];
                        placementIns.Id = currentIteration.Id; 
                        placementIns.recordName = currentIteration.Name;
                        placementIns.recordUrl = '/lightning/r/'+currentIteration.Id+'/view';
                        placementIns.childName = currentIteration.Child__r.Name;
                        if(currentIteration.Provider__c) {
                            placementIns.providerName = currentIteration.Provider__r.Name;
                        }
                        placementIns.beginDate = currentIteration.Begin_Date__c;
                        placementIns.endDate = currentIteration.End_Date__c;
                        placementIns.exitType = currentIteration.Exit_Type__c;
                        placementIns.placementApprovalStatus = currentIteration.Placement_Approval_Status__c;
                        if( placementIns.placementApprovalStatus == 'Approved') {
                            placementIns.cssClass = 'slds-hide';
                        } else {
                            placementIns.cssClass = 'slds-show';
                        }
                        placementIns.exitApprovalStatus = currentIteration.Exit_Approval_Status__c;
                        placementIns.placementStructure = currentIteration.Placement_Structure__c;
                        childList.push(placementIns);
                    }
                    childRemovalIns._children = childList;
                }
                dataList.push(childRemovalIns);
            }
            this.cardTitle = 'Placements ('+this.placementCount+')';
            this.gridData = dataList;
            this.isLoading = false;
            
        }).catch(error => {
            this.isLoading = false;
            this.handleError(error);
        })
    }

    handleNew() {
        
      getChildValues( { servicecaseId : this.recordId })
      .then(result => {
          let response = JSON.parse(result);
          this.childOptions = response.childPicklist;
          this.placementRecordList = response.placementRecordList;
          this.showModal = true;
      }).catch(error => {
            this.handleError(error);
        })
    }

    handleRefresh() {
        this.placementCount = 0;
        this.doInit();
    }

    hideModal() {
        this.showFlowScreen = false;
    }

    handleChange(event) {
        this.childId = event.target.value;
    }

    handleSubmit(event) {
        event.preventDefault();       
        const fields = event.detail.fields;
        let foundelement = this.childRemovallist.find(ele => ele.Child__c ==  this.childId);
        console.log(foundelement);
        if (foundelement) {
            fields.Child_Removal__c = foundelement.Id;                                
            fields.Service_Case__c = this.recordId;
            fields.Child__c = foundelement.Child__c;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }

    handleSuccess() {
        this.title ="Success!";
        this.type ="success";
        this.message = 'Placement Record Created Successfully!';
        this.fireToastMsg();
        this.showModal = false;
        this.handleRefresh();
    }

    handleError(error) {
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
    }

    handleRowAction(event) {
        var selectedRowId = event.detail.row.Id;
        deleteRecord(selectedRowId)
            .then(() => {
                this.title ="Success!";
                this.type ="success";
                this.message = 'Placement record deleted successfully!';
                this.fireToastMsg();
                this.doInit();
            })
            .catch(error => {
                this.handleError(error);
            });
    }

    handleFlow() {

        this.showFlowScreen = true;

    }

    handleNavigation(event) {
        if(event.target.value == 'living arrangement') {
            this.showLivingArrangementFlow = true;
        } else if(event.target.value == 'placement') {
            this.showPlacementFlow = true;

        }

    }

    closeFlowModal() {

        this.showFlowScreen = false;
        this.showLivingArrangementFlow = false;
        this.showPlacementFlow = false;
    }



}