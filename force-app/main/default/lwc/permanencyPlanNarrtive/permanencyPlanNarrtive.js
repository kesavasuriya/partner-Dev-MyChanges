import { LightningElement, track, api } from 'lwc';
import getAdoptionNarrativeInfo from '@salesforce/apex/PermanacyPlanAdoptionController.getAdoptionPlanningNarrativeInitialInfos';
import savePermanencyPlan from '@salesforce/apex/PermanacyPlanAdoptionController.updateAdoptionPlanning';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class PermanencyPlanNarrtive extends UtilityBaseElement {

    readOnly = false;
    @api permanencyRecId;
    @track permanencyPlanRec = {};
    loading = false;

    connectedCallback() {

        this.doInitInfo()
    }

    doInitInfo() {

        this.loading = true;
        getAdoptionNarrativeInfo({ permanencyPlanId: this.permanencyRecId })
            .then(result => {
                if (result) {
                    this.permanencyPlanRec = this.checkNamespaceApplicable(JSON.parse(result).permanencyPlanRec, false);
                }
                this.loading = false;
            }).catch(error => {

                //this.isLoading = false;
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
                this.loading = false;
            })
    }

    handleChange(event) {

        let fieldName = event.target.name;
        let checkedfields = event.target.checked;
        let fieldValue = event.target.value;
        let fieldType = event.target.type;
        if (fieldType != 'checkbox') {

            this.permanencyPlanRec[fieldName] = fieldValue;
        } else {
            this.permanencyPlanRec[fieldName] = checkedfields;
        }

    }

    handleSave() {

        if (!this.onValidate()) {
            this.loading = true;
            this.permanencyPlanRec.Adoption_Planning_Stage__c = 'APPLICABLE CHILD ASSESSMENT';
            savePermanencyPlan({ adoptionPlanningJSON: JSON.stringify(this.checkNamespaceApplicable(this.permanencyPlanRec, true)) })
                .then(result => {
                    if (result) {
                        this.title = "Success!";
                        this.type = "success";
                        this.message = 'Adoption plan emotional tiles saved Successfully.';
                        this.fireToastMsg();
                        this.doInitInfo();
                    }
                    this.loading = false;
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
                    this.loading = false;
                })
        } else {

            this.title = "Error!";
            this.type = "error";
            this.message = 'Complete the required field(s).';
            this.fireToastMsg();
        }
    }

    handleSaveNext() {

        this.handleSave();
        const adoptionStageEvent = new CustomEvent('adoptionstage');
        this.dispatchEvent(adoptionStageEvent);

    }
}