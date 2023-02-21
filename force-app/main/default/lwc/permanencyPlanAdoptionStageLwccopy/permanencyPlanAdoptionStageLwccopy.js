import { LightningElement, track, api } from 'lwc';
import getAdoptionInitInfo from '@salesforce/apex/PermanacyPlanAdoptionController.getAdoptionInitialInfos';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class PermanencyPlanAdoptionStageLwc extends UtilityBaseElement {

    @api id;
    @track adoptionPlanningpicklist = [];
    @track permanencyPlanRec = {};
    @track currentadoptionStage = '1';
    showTPRRecommendation = true;
    showLegalCustody = false;
    showTPR = false;
    showAdoptionPlanning = false;
    showAdoptionSubsidy = false;
    showBreaktheLink = false;
    showChild = false;
    loading = false;
    @track legalCustody = [];
    @track placementRec = [];
    @track tprList = [];
    @track subSidyRateRecList =[];

    connectedCallback() {

        this.doInitInfo();
    }

    doInitInfo() {

        this.loading = true;
        this.showChild = false;
        getAdoptionInitInfo({ permanencyPlanId: this.id })

        .then(result => {
            if (result) {
                let res = JSON.parse(result);
                var adoptionPicklist = res.adoptionPlanPicklist;
                adoptionPicklist.splice(0, 1); // for remove new value
                this.adoptionPlanningpicklist = adoptionPicklist;
                this.permanencyPlanRec = this.checkNamespaceApplicable(res.permanencyPlanRec, false);
                if(this.permanencyPlanRec.Adoption_Planning__c) {
                    this.currentadoptionStage = this.permanencyPlanRec.Adoption_Planning__c;
                }
                
                this.legalCustody = this.checkNamespaceApplicable(res.legalCustody, false);
                this.placementRec = this.checkNamespaceApplicable(res.placementRec, false);
                this.tprList = this.checkNamespaceApplicable(res.tpRList, false);
                this.subSidyRateRecList = this.checkNamespaceApplicable(res.subSidyRecList, false);
                
                if(this.legalCustody.length && this.placementRec.length && this.currentadoptionStage == '3') {
                    //this.currentadoptionStage = '3';
                    this.showTPRRecommendation = false;
                    this.showTPR = true;
                } /*else if(this.currentadoptionStage == '2') {
                    
                    this.showTPRRecommendation = false;
                    this.showTPR = false;
                    this.showLegalCustody = true;
                }*/
                if(this.tprList.length && this.currentadoptionStage == '3') {

                    this.currentadoptionStage = '4';
                    this.showTPR = false;
                    this.showLegalCustody = false;
                    this.showAdoptionPlanning = true;
                }
                if(this.currentadoptionStage == '5') {
                    
                    this.showTPRRecommendation = false;
                    this.showLegalCustody = false;
                    this.showTPR = false;
                    this.showAdoptionPlanning = false;
                    this.showBreaktheLink = false;
                    this.showAdoptionSubsidy = true;

                }
                if(this.currentadoptionStage == '6') {

                    this.showTPRRecommendation = false;
                    this.showLegalCustody = false;
                    this.showTPR = false;
                    this.showAdoptionPlanning = false;
                    this.showAdoptionSubsidy = false;
                    this.showBreaktheLink = true;

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

        if(currentOnStageValue == '1') {

            this.showTPRRecommendation = true;
            this.showLegalCustody = false;
            this.showTPR = false;
            this.showAdoptionPlanning = false;
            this.showAdoptionSubsidy = false;
            this.showBreaktheLink = false;

        } else if(currentOnStageValue == '3') {

            
                this.showTPRRecommendation = false;
                this.showLegalCustody = false;
                this.showTPR = true;
                this.showAdoptionPlanning = false;
                this.showAdoptionSubsidy = false;
                this.showBreaktheLink = false;
            

        } else if(currentOnStageValue == '4') {


                this.showTPRRecommendation = false;
                this.showLegalCustody = false;
                this.showTPR = false;
                this.showAdoptionPlanning = true;
                this.showAdoptionSubsidy = false;
                this.showBreaktheLink = false;
            
            

        } else if(currentOnStageValue == '5') {


                this.showTPRRecommendation = false;
                this.showLegalCustody = false;
                this.showTPR = false;
                this.showAdoptionPlanning = false;
                this.showAdoptionSubsidy = true;
                this.showBreaktheLink = false;
           
            

        } else if(currentOnStageValue == '6') {


                this.showTPRRecommendation = false;
                this.showLegalCustody = false;
                this.showTPR = false;
                this.showAdoptionPlanning = false;
                this.showAdoptionSubsidy = false;
                this.showBreaktheLink = true;
            
            
        }

    }

    handleStage(event) {

        this.doInitInfo();
    }
}