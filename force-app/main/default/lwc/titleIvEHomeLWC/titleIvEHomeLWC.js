import { LightningElement, track, wire } from 'lwc';
import getInitiInfo from '@salesforce/apex/TitleIvEController.getTitleIveRecords';
import getpickvalue from '@salesforce/apex/TitleIvEController.getInitialInfo';

//import getSearchList from '@salesforce/apex/TitleIvEController.getSearch';
import getSearchList from '@salesforce/apex/TitleIvEController.getSearchTitles';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import { loadScript } from 'lightning/platformResourceLoader';
import UtilityBaseElement from 'c/utilityBaseLwc';

const columns = [ { label : 'CHILD NAME' , fieldName : 'childName', type : 'text',wrapText : true},
                  { label: 'CLIENT ID', type:  'button',typeAttributes: { 
                    variant :'base', name : 'name',
                             label:   { 
                        fieldName: 'clientId' 
                    } }},
                  { label : 'CASE NUMBER', fieldName : 'caseNumber', type:'text',wrapText : true},
                  { label : 'CHILD AGENCY', fieldName : 'childAgency', type:'text',wrapText : true},
                  { label : 'CHILD JURISDICTION', fieldName : 'childJurisdiction', type:'text',wrapText : true},
                  { label : 'REMOVAL DATE', fieldName : 'removalDate', type:'date', typeAttributes : {day:"numeric",month:"numeric",year:"numeric",timeZone:"UTC"}},
                  { label : 'DATE OF BIRTH', fieldName : 'DOB', type:'date', typeAttributes : {day:"numeric",month:"numeric",year:"numeric",timeZone:"UTC"}}, 
                  { label : 'REMOVAL AGE', fieldName : 'removalAge', type:'text',wrapText : true},
                  { label : 'ASSIGNED TO' , fieldName : 'assignedTo', type : 'text',wrapText : true},
                  { label : 'ASSIGNMENT STATUS' , fieldName : 'assignmentStatus', type : 'text',wrapText : true},
                  { label : 'ELIGIBLE STATUS' , fieldName : 'eligibleStatus', type : 'text',wrapText : true},
                  { label : 'REVIEW PERIOD' , fieldName : 'reviewPeriod', type : 'text',wrapText : true}
                ];

export default class TitleIvEHomeLWC extends UtilityBaseElement {

    @track titleIVEList = [];
    @track showTitleIVETable = false;
    @track showtitleIvEStageCmp = false;
    @track showTitleIVECmp = true;
    @track showAssignButton = true;
    @track titleIVESize = 0;
    @track titleSearchIns = {};
    @track currentIvERec = {};
    @track currentRec = {};
    @track pathSteps = [];
    @track assigningList = [];
    @track displayList = [];
    @track searchList = [];
    @track isSpinner = true;
    @track eligibleStatusPicklist = [];
    @track visibleData = [];
    showChild = false;
    columns = columns;

    //showMsg = false;

    connectedCallback() {

        this.pathSteps.push({ label: 'Legal', value: 'Legal' }, { label: 'AFDC Relatedness', value: 'AFDC Relatedness' }, { label: 'Placement', value: 'Placement' }, { label: 'Other Criteria', value: 'Other Criteria' });
        loadScript(this, momentForTime)
        .then(() => {
            getpickvalue()
            .then(result => {
                let res = JSON.parse(result);
                this.eligibleStatusPicklist = res.eligibleStatusPicklist;
                this.doInitInfo();

            })
            .catch(error => {

                let errorMsg;
                this.title = "Error!";
                this.type = "error";
                if (error) {
                    let errors = this.reduceErrors(error);
                    errorMsg = errors.join('; ');
                } else {
                    errorMsg = 'Unknown Error';
                }
                this.loading = false;
                this.message = errorMsg;
                this.fireToastMsg();
            })
            })
            .catch(error => {

                let errorMsg;
                this.title = "Error!";
                this.type = "error";
                if (error) {
                    let errors = this.reduceErrors(error);
                    errorMsg = errors.join('; ');
                } else {
                    errorMsg = 'Unknown Error';
                }
                this.loading = false;
                this.message = errorMsg;
                this.fireToastMsg();
            })
       
    }

    doInitInfo() {

        getInitiInfo()
            .then(result => {
                this.loading = false;
                this.isSpinner = false;
                let res = JSON.parse(result);
                this.titleIVEList = res;
                /*for (let i = 0; i < this.titleIVEList.length; i++) {
                    this.titleIVEList[i].removalDate = moment(this.titleIVEList[i].removalDate).format('MM/DD/YYYY');
                    this.titleIVEList[i].DOB = moment(this.titleIVEList[i].DOB).format('MM/DD/YYYY');
                }*/

                this.titleIVESize = this.titleIVEList.length;
                this.showTitleIVETable = this.titleIVEList.length ? true : false;
                this.showChild = true;
            }) .catch(error => {

                let errorMsg;
                this.title = "Error!";
                this.type = "error";
                if (error) {
                    let errors = this.reduceErrors(error);
                    errorMsg = errors.join('; ');
                } else {
                    errorMsg = 'Unknown Error';
                }
                this.loading = false;
                this.message = errorMsg;
                this.fireToastMsg();
            })
    }

    handleClear() {
        this.titleSearchIns = {};
    }

    handleTitleIvERec(event) {

        let recId = event.target.dataset.id;
        let foundelement = this.titleIVEList.find(ele => ele.titleIVEId == recId);
        this.currentIvERec = foundelement;
        this.showTitleIVECmp = false;
        this.showtitleIvEStageCmp = true;
    }

    handleClick(event) {
        //event.target.label;
        alert('Assign logic - Working in progress');
    }

    handleCheckboxChange(event) {

        let checkValue = event.target.checked;
        let recId = event.target.name;
        let assignIns = this.titleIVEList.find(ele => ele.id == recId);
        if (checkValue) {
            this.assigningList.push(assignIns);
        } else {
            let rows = this.assigningList;
            const rowIndex = rows.indexOf(assignIns);
            rows.splice(rowIndex, 1);
            this.assigningList = rows;
        }
        this.showAssignButton = this.assigningList.length ? false : true;
    }

    handleSearchChange(event) {

        let name = event.target.name;
        let value = event.target.value;

        if (name == 'searchClientId') {
            this.titleSearchIns.clientId = value;
        } else if (name == 'searchRemovalDate') {
            this.titleSearchIns.removalDate = value;
        } else if (name == 'searchFirstName') {
            this.titleSearchIns.firstName = value;

        } else if (name == 'searchLastName') {
            this.titleSearchIns.lastName = value;
        } else if (name == 'searchEligibleStatus') {
            this.titleSearchIns.eligibleStatus = value;
        }
    }

    handleSearch() {
        this.isSpinner = true;
        this.showChild = false;
        getSearchList({ searchInsString: JSON.stringify(this.titleSearchIns) })
            .then(result => {
                this.isSpinner = false;
                let res = JSON.parse(result);
                this.titleIVEList = res;
                /*for (let i = 0; i < this.titleIVEList.length; i++) {
                    this.titleIVEList[i].removalDate = moment(this.titleIVEList[i].removalDate).format('MM/DD/YYYY');
                    this.titleIVEList[i].DOB = moment(this.titleIVEList[i].DOB).format('MM/DD/YYYY');
                }*/
                this.showChild = true;
                //this.titleIVESize = this.titleIVEList.length;
                //this.showTitleIVETable =  this.titleIVEList.length? true: false; 
            }) .catch(error => {

                let errorMsg;
                this.title = "Error!";
                this.type = "error";
                if (error) {
                    let errors = this.reduceErrors(error);
                    errorMsg = errors.join('; ');
                } else {
                    errorMsg = 'Unknown Error';
                }
                this.loading = false;
                this.message = errorMsg;
                this.fireToastMsg();
            })

    }

    handleBackBtnClick(event) {

            this.showtitleIvEStageCmp = event.detail;
            this.showTitleIVECmp = true;

    }

    paginationHandler(event) {

        this.visibleData = [...event.detail.records];     
    }

    handleRowAction(event) {

        var actionName = event.detail.action.name;
        var selectedrow = event.detail.row;
        if(actionName) {
            
            this.currentIvERec = selectedrow;
            this.showTitleIVECmp = false;
            this.showtitleIvEStageCmp = true;
        }

    }


}