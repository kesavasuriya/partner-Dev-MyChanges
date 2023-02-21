import { LightningElement, track, api } from 'lwc';
import getAdoptionInitInfo from '@salesforce/apex/PermanacyPlanAdoptionController.getAdoptionInitialInfos';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class PermanencyPlanAdoptionStageLwc extends UtilityBaseElement {

    @api recordId;
    @track adoptionPlanningpicklist = [];
    @track permanencyPlanRec = {};
    @track currentadoptionStage = '1';
    @track showTPRRecommendation = true;
    @track showLegalCustody = false;
    @track showTPR = false;
    @track showAdoptionPlanning = false;
    @track showAdoptionSubsidy = false;
    @track showBreaktheLink = false;
    @track showChild = false;
    loading = false;
    @track legalCustody = [];
    @track placementRec = [];
    @track tprList = [];
    @track subSidyRateRecList = [];

    connectedCallback() {

        this.doInitInfo();
    }

    doInitInfo() {

        this.loading = true;
        this.showChild = false;
        getAdoptionInitInfo({ permanencyPlanId: this.recordId })

        .then(result => {

            if (result) {

                let res = JSON.parse(result);
                var adoptionPicklist = res.adoptionPlanPicklist;
                adoptionPicklist.splice(0, 1); // for remove new value
                this.adoptionPlanningpicklist = adoptionPicklist;
                this.permanencyPlanRec = res.permanencyPlanRec;
                console.log('res',res);
                if (this.permanencyPlanRec.Adoption_Planning__c) {

                    this.currentadoptionStage = this.permanencyPlanRec.Adoption_Planning__c;
                }

                this.legalCustody = res.legalCustody;
                this.placementRec = res.placementRec;
                this.tprList = res.tpRList;
                this.subSidyRateRecList = res.subSidyRecList;

                switch (this.currentadoptionStage) {

                    case '1':
                        this.showTPRRecommendation = true;
                        break;

                    case '3':
                        if (this.legalCustody.length && this.placementRec.length) {

                            this.showTPRRecommendation = false;
                            this.showTPR = true;
                            console.log('in',this.showTPR);
                        }
                        break;

                    case '4':
                        if (this.tprList.length) {

                            this.showTPR = false;
                            this.showTPRRecommendation = false;
                            this.showLegalCustody = false;
                            this.showAdoptionPlanning = true;
                        }
                        break;

                    case '5':
                        if (this.subSidyRateRecList.length) {

                            for (let i = 0; i < this.subSidyRateRecList.length; i++) {
                                if (this.subSidyRateRecList[i].Rate_Approval_Status__c == 'Approved') {

                                    this.currentadoptionStage = '6';
                                    this.showTPRRecommendation = false;
                                    this.showLegalCustody = false;
                                    this.showTPR = false;
                                    this.showAdoptionPlanning = false;
                                    this.showAdoptionSubsidy = false;
                                    this.showBreaktheLink = true;
                                }
                            }

                        } else {

                            this.showTPRRecommendation = false;
                            this.showLegalCustody = false;
                            this.showTPR = false;
                            this.showAdoptionPlanning = false;
                            this.showBreaktheLink = false;
                            this.showAdoptionSubsidy = true;
                        }
                        break;

                    case '6':

                        this.showTPRRecommendation = false;
                        this.showLegalCustody = false;
                        this.showTPR = false;
                        this.showAdoptionPlanning = false;
                        this.showAdoptionSubsidy = false;
                        this.showBreaktheLink = true;

                        break;

                }

                this.loading = false;
                this.showChild = true;
            }

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

    stageAction(event) {

        var currentOnStageValue = event.target.value;

        if (currentOnStageValue == '1') {

            this.showTPRRecommendation = true;
            this.showLegalCustody = false;
            this.showTPR = false;
            this.showAdoptionPlanning = false;
            this.showAdoptionSubsidy = false;
            this.showBreaktheLink = false;

        } else if (currentOnStageValue == '3') {

            if (this.currentadoptionStage == '1') {
                this.title = "Error!";
                this.type = "error";
                this.message = 'Complete the  TPR Recommendation Stage';
                this.fireToastMsg();
            }

            if (!(this.legalCustody.length)) {

                this.title = "Error!";
                this.type = "error";
                this.message = 'Please ensure that legal custody has Guardianship to DSS';
                this.fireToastMsg();

            } else if (!(this.placementRec.length)) {

                this.title = "Error!";
                this.type = "error";
                this.message = 'Please ensure that placement structure has Prefinalized Adoptive Home';
                this.fireToastMsg();

            } else if (this.currentadoptionStage >= currentOnStageValue) {

                this.showTPRRecommendation = false;
                this.showLegalCustody = false;
                this.showTPR = true;
                this.showAdoptionPlanning = false;
                this.showAdoptionSubsidy = false;
                this.showBreaktheLink = false;
            }

        } else if (currentOnStageValue == '4') {

            if (!(this.tprList.length)) {

                this.title = "Error!";
                this.type = "error";
                this.message = 'Complete the Termination of Parental Rights stage';
                this.fireToastMsg();

            } else if (this.currentadoptionStage >= currentOnStageValue) {

                this.showTPRRecommendation = false;
                this.showLegalCustody = false;
                this.showTPR = false;
                this.showAdoptionPlanning = true;
                this.showAdoptionSubsidy = false;
                this.showBreaktheLink = false;
            }


        } else if (currentOnStageValue == '5') {

            if (this.currentadoptionStage >= currentOnStageValue) {

                this.showTPRRecommendation = false;
                this.showLegalCustody = false;
                this.showTPR = false;
                this.showAdoptionPlanning = false;
                this.showAdoptionSubsidy = true;
                this.showBreaktheLink = false;

            } else {

                this.title = "Error!";
                this.type = "error";
                this.message = 'Complete the Adoption Planning stage';
                this.fireToastMsg();
            }


        } else if (currentOnStageValue == '6') {

            if (this.currentadoptionStage >= currentOnStageValue) {

                this.showTPRRecommendation = false;
                this.showLegalCustody = false;
                this.showTPR = false;
                this.showAdoptionPlanning = false;
                this.showAdoptionSubsidy = false;
                this.showBreaktheLink = true;

            } else {

                this.title = "Error!";
                this.type = "error";
                this.message = 'Complete the Adoption Subsidy stage';
                this.fireToastMsg();
            }

        }

    }

    handleStage(event) {

        this.doInitInfo();
    }
}