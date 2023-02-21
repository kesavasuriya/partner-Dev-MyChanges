import { LightningElement, api, track } from 'lwc';
import getTitleIvRec from '@salesforce/apex/TitleIvEController.getAllPeriodTitleIVERec';
import submitDetermineEligibleAPI from '@salesforce/apex/TitleIvEController.submitDetermineEligibleAPI';
import getSpecificIVERec from '@salesforce/apex/TitleIvEController.getTitleIVERec';
import momentForTime from '@salesforce/resourceUrl/momentForTime';
import { loadScript } from 'lightning/platformResourceLoader';
import updateFirstDetermination from '@salesforce/apex/TitleIvEController.updateTitleIveRec';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class TitleIVTabsLWC extends UtilityBaseElement {

    @api currentTitleIvERec;
    titleIVEList = [];
    showStageCmp = false;
    @track pathSteps = [];
    @track titleIVERec = {};
    @track activeTab = 'default';
    isEiligible = true;
    tabContent = '';
    @track titleIVeIdList = [];
    @track loading = false;
    @track apiLoading = false;
    @track firstDetermination = false;
    @track disableCheckbox = false;
    @track titleIdsList =[];
    @track selectAllValue = false;
    @track determinationId = [];


    connectedCallback() {

        this.loading = true;
        loadScript(this, momentForTime)
            .then(() => {
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
                this.message = errorMsg;
                this.fireToastMsg();
            })
        this.pathSteps.push({ label: 'Legal', value: 'Legal' }, { label: 'AFDC Relatedness', value: 'AFDC Relatedness' }, { label: 'Placement', value: 'Placement' }, { label: 'Other Criteria', value: 'Other Criteria' });
        getTitleIvRec({ titleIVId: this.currentTitleIvERec.titleIVEId }).then(result => {
            this.titleIVEList = this.checkNamespaceApplicable(JSON.parse(result).titleIVERecList, false);

            for (let i = 0; i < this.titleIVEList.length; i++) {

                if (this.titleIVEList[i].Review_Period_Start_Date__c) {
                    this.titleIVEList[i].Review_Period_Start_Date__c = moment(this.titleIVEList[i].Review_Period_Start_Date__c).format('MM/DD/YYYY');
                    this.titleIdsList.push(this.titleIVEList[i].Id);
                }
                if (this.titleIVEList[i].Review_Period_End_Date__c) {
                    this.titleIVEList[i].Review_Period_End_Date__c = moment(this.titleIVEList[i].Review_Period_End_Date__c).format('MM/DD/YYYY');
                }
                if (this.titleIVEList[i].First_Time_Redetermination__c == 'Yes' && this.titleIVEList[i].Id == this.currentTitleIvERec.titleIVEId) {
                    this.firstDetermination = true;
                    this.disableCheckbox = true;
                    this.isEiligible = false;
                    this.selectAllValue = true;


                }
            }
            this.titleIVeIdList = this.titleIdsList;
            this.loading = false;
        }).catch(error => {

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
        })
    }

    handleStageCmp(event) {
        let recId = event.currentTarget.getAttribute('data-id');
        getSpecificIVERec({ titleIVEId: recId }).then(result => {
            this.titleIVERec = this.checkNamespaceApplicable(JSON.parse(result).titleIVERec, false);
            this.showStageCmp = true;
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

    handleTabClick(event) {
        const tab = event.target;
        this.activeTab = `Tab ${
            event.target.value
        } is now active`;
    }

    handleBackBtnClick(event) {
        const childdetail = new CustomEvent('hidetabs', { detail: false });
        this.dispatchEvent(childdetail);
    }

    handleDetermaine(event) {

        let eiligible = event.target.checked;
        let RecId = event.target.dataset.id;
        if(event.target.name !='selectAll') {
            this.selectAllValue = false;
            if (eiligible) {
                this.determinationId.push(RecId);
            } else {
                let index = this.titleIVeIdList.indexOf(RecId);
                this.determinationId.splice(index, 1);
            }
            this.isEiligible = this.determinationId.length ? false : true;
        } else {
            this.selectAllValue = event.target.checked;
            this.firstDetermination = event.target.checked;
            if(event.target.checked) {
                this.determinationId = this.titleIdsList;
                this.isEiligible = false;
            } else {
                this.isEiligible = true;
                this.determinationId = [];
            }
        }

    }


    handleEligibilityDetermine() {

        if(this.firstDetermination == true) {
            this.titleIVeIdList = [];
            this.titleIVeIdList = this.titleIdsList;
        } else {
            this.titleIVeIdList = this.determinationId;
        }
       
        if (this.titleIVeIdList.length <= 100) {
        this.apiLoading = true;
        submitDetermineEligibleAPI({ titleIveIdList: this.titleIVeIdList }).then(result => {
               
            this.activeTab = 'default';
                this.title = 'Success';
                this.message = 'Determination submitted successfully';
                this.type = 'success';
                this.fireToastMsg();
                this.activeTab = 'detail';
                this.titleIVeIdList = this.titleIdsList;
                setTimeout(() => {
                    this.template.querySelector('c-eligibility-detail-lwc').refresh();
                }, 500);
                this.apiLoading = false;
               

                if(this.firstDetermination == true) {
                    updateFirstDetermination({ titleIVId : this.currentTitleIvERec.titleIVEId})
                    .then(res =>{
                    })
                    .catch(error => {
            
                        this.apiLoading = false;
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


               
           
        }).catch(error => {
            
            this.apiLoading = false;
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

    } else {

            this.title = 'Warning!';
            this.type = 'warning';
            this.message = 'A Transaction can Make a Maximum of 100 Callouts to an API Call.';
            this.fireToastMsg();

    }

    }

    handleRowClick(event) {

        for (let i = 0; i < this.titleIVEList.length; i++) {
            this.titleIVEList[i].selectedRow = '';
            if (parseInt(event.currentTarget.getAttribute('data-label')) == i) {
                this.titleIVEList[i].selectedRow = 'selectedRowClass';
            }
        }
    }


}