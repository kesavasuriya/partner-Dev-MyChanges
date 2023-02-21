import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getActiveFlow from "@salesforce/apex/FinanceController.getFlowVersion"
export default class FinanceTabLwc extends NavigationMixin(LightningElement) {

    @api showApprove;
    handleNavigate() {
        getActiveFlow({})
        .then(res=>{
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/builder_platform_interaction/flowBuilder.app?flowId=' + res
                    }
                }).then(generatedUrl => {
                    window.open(generatedUrl);
                });
        })
        
    }

}