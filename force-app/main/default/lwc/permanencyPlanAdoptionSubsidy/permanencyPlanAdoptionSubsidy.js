import { LightningElement, track, api } from 'lwc';
import getActiveTabValue from '@salesforce/apex/PermanacyPlanAdoptionController.getActiveTab';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class PermanencyPlanAdoptionSubsidy extends UtilityBaseElement {
    @track activeTab = 'default';
    @api permanencyRecId;

    connectedCallback() {

        getActiveTabValue({ permanencyRecId: this.permanencyRecId })
            .then(result => {
                let res = this.checkNamespaceApplicable(JSON.parse(result), false);
                if (res.Subsidy_Approval_Status__c == 'Approved') {
                    this.activeTab = 'rate';
                }

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
            });

    }

    handleTabClick(event) {
        const tab = event.target;
        this.activeTab = `Tab ${
            event.target.value
        } is now active`;
    }
}