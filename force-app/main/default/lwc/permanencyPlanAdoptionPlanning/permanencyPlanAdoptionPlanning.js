import { LightningElement, api, track } from 'lwc';
import getAdoptionPlanningInitInfo from '@salesforce/apex/PermanacyPlanAdoptionController.getAdoptionPlanningStageInitialInfos';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class PermanencyPlanAdoptionPlanning extends UtilityBaseElement {
    @api permanencyRecId;
    @track adoptionPlanningPicklist;
    @track adoptionPlanningRec = {};
    @track showAdoptionEfforts = false;
    @track showEmotionalTiles = false;
    @track showNarrtive = false;
    @track showApplicableChildAssessment = false;
    @track showDisclosureChecklist = false;
    @track currentadoptionStage = 1;

    connectedCallback() {

        this.getIntialAdoptionPlanStage();

    }

    getIntialAdoptionPlanStage() {

        getAdoptionPlanningInitInfo({ permanencyPlanId: this.permanencyRecId })
            .then(result => {

                if (result) {

                    this.showAdoptionEfforts = false;
                    this.showEmotionalTiles = false;
                    this.showNarrtive = false;
                    this.showDisclosureChecklist = false;
                    this.showApplicableChildAssessment = false;
                    let res = this.checkNamespaceApplicable(JSON.parse(result).adoptionPlanningStageRec, false);
                    var adoptionPlanningPick = this.checkNamespaceApplicable(JSON.parse(result).adoptionPlanningStagePicklist, false);
                    adoptionPlanningPick.splice(0, 1); // for remove new value
                    this.adoptionPlanningPicklist = adoptionPlanningPick;


                    if (res != null) {

                        this.adoptionPlanningRec = this.checkNamespaceApplicable(res, false);
                    }

                    if (this.adoptionPlanningRec.Adoption_Planning_Stage__c) {

                        this.currentadoptionStage = this.adoptionPlanningRec.Adoption_Planning_Stage__c;
                    }
                    switch (this.currentadoptionStage) {

                        case '1':
                            this.showAdoptionEfforts = true;
                            break;

                        case '2':
                            this.showEmotionalTiles = true;
                            break;

                        case '3':
                            this.showNarrtive = true;
                            break;

                        case '4':
                            this.showApplicableChildAssessment = true;
                            break;

                        case '5':
                            this.showDisclosureChecklist = true;
                            break;
                    }

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

        if (currentOnStageValue == 1) {

            if (this.currentadoptionStage == 1 || this.currentadoptionStage == 2 || this.currentadoptionStage == 3 || this.currentadoptionStage == 4 || this.currentadoptionStage == 5) {

                this.showAdoptionEfforts = true;
                this.showEmotionalTiles = false;
                this.showNarrtive = false;
                this.showDisclosureChecklist = false;
                this.showApplicableChildAssessment = false;
            }


        } else if (currentOnStageValue == 2) {

            if (this.currentadoptionStage == 2 || this.currentadoptionStage == 3 || this.currentadoptionStage == 4 || this.currentadoptionStage == 5) {
                this.showAdoptionEfforts = false;
                this.showEmotionalTiles = true;
                this.showNarrtive = false;
                this.showDisclosureChecklist = false;
                this.showApplicableChildAssessment = false;

            } else {

                this.title = "Error!";
                this.type = "error";
                this.message = 'Complete the  Adoption Efforts Stage';
                this.fireToastMsg();
            }

        } else if (currentOnStageValue == 3) {

            if (this.currentadoptionStage == 3 || this.currentadoptionStage == 4 || this.currentadoptionStage == 5) {

                this.showAdoptionEfforts = false;
                this.showEmotionalTiles = false;
                this.showNarrtive = true;
                this.showDisclosureChecklist = false;
                this.showApplicableChildAssessment = false;

            } else {

                this.title = "Error!";
                this.type = "error";
                this.message = 'Complete the  Emotional Tiles Stage';
                this.fireToastMsg();
            }


        } else if (currentOnStageValue == 4) {

            if (this.currentadoptionStage == 4 || this.currentadoptionStage == 5) {

                this.showAdoptionEfforts = false;
                this.showEmotionalTiles = false;
                this.showNarrtive = false;
                this.showDisclosureChecklist = false;
                this.showApplicableChildAssessment = true;

            } else {

                this.title = "Error!";
                this.type = "error";
                this.message = 'Complete the  Narrative Stage';
                this.fireToastMsg();
            }


        } else if (currentOnStageValue == 5) {

            if (this.currentadoptionStage == 5) {

                this.showAdoptionEfforts = false;
                this.showEmotionalTiles = false;
                this.showNarrtive = false;
                this.showDisclosureChecklist = true;
                this.showApplicableChildAssessment = false;

            } else {
                this.title = "Error!";
                this.type = "error";
                this.message = 'Complete the  Applicable Child Assessment Stage';
                this.fireToastMsg();
            }

        }

    }

    handleadoptionstage(event) {

        this.getIntialAdoptionPlanStage();
    }



}