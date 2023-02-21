import { LightningElement, api, wire, track } from 'lwc';
import getTPRRecommendationInitialInfos from '@salesforce/apex/PermanacyPlanAdoptionController.getTPRRecommendationInitialInfos';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class PermanencyPlanTPRRecommendation extends UtilityBaseElement {

    @api permanencyRecId;
    @track tprRec = {};
    loading = false;
    wireData;
    initData = {};
    isValid;
    @track saveandNext = false;
    disableButton = false;

    @wire(getTPRRecommendationInitialInfos, { permanencyPlanId: '$permanencyRecId' })
    initInfos(result) {

        this.wireData = result;
        this.loading = true;

        if (result.data) {

            this.initData = JSON.parse(result.data);
            this.loading = false;
            this.tprRec = this.initData.permanencyPlanRec;
            if (this.tprRec.Adoption_Planning__c > 1) {

                this.disableButton = true;
            } else {

                this.disableButton = false;
            }

            if (this.initData.courtHearingRec.length) {

                this.tprRec.Court_hearing_occurs__c = true;
                this.tprRec.Court_order_of_TPR_for_parents__c = true;
                this.tprRec.Petition_for_TPR_sent_to_court__c = true;
                this.tprRec.Primary_Permanacy_Plan_is_adoption__c = true;

            } else {

                this.tprRec.Court_hearing_occurs__c = false;
                this.tprRec.Court_order_of_TPR_for_parents__c = false;
                this.tprRec.Petition_for_TPR_sent_to_court__c = false;
                this.tprRec.Primary_Permanacy_Plan_is_adoption__c = false;
            }


        } else if (result.error) {

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
        }
    }

    onFormValidate() {

        this.isValid = this.onRequiredValidate();
    }

    handleSaveandNext() {

        this.saveandNext = true;
        this.onFormValidate();

    }

    handleSave() {

        this.saveandNext = false;
        this.onFormValidate();

    }

    handleSubmit(event) {

        event.preventDefault();
        if (this.isValid) {

            const fields = event.detail.fields;
            if (this.saveandNext) {

                fields.Adoption_Planning__c = '3';
            }
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }

    handleSuccess(event) {

        this.title = "Success!";
        this.type = "success";
        this.message = 'Record Updated Successfully';
        this.fireToastMsg();
        const stageEvent = new CustomEvent('stage');
        this.dispatchEvent(stageEvent);
    }

    handleError(event) {

        this.title = "Error!";
        this.type = "error";
        this.message = event.detail.detail;
        this.fireToastMsg();
    }
}