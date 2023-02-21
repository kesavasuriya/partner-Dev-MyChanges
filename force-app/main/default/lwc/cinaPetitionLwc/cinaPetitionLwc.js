import { LightningElement, track, api } from 'lwc';
import getInitiInfo from '@salesforce/apex/CourtController.getInitialInfos';

import UtilityBaseElement from 'c/utilityBaseLwc';
export default class PetitionCINALWC extends UtilityBaseElement{

    @track newReviewPick = [];
    @track emerengcyPick =[];
    @track childCurrentPlacementpick =[];
    @track parentNamePick = [];
    @track previousJuvenileCourtPick = [];
    @api recordId;

    connectedCallback() {
        
        this.doInitInfo();
    }

    doInitInfo() {

        getInitiInfo({recordId: this.recordId})
        .then(result => {
            let res = JSON.parse(result);
            this.newReviewPick = res.newReviewPickList;
            this.emerengcyPick = res.emergencyPickList;
            this.childCurrentPlacementpick = res.childCurrentPlacementPicklist;
            this.parentNamePick=res.parentNamePicklist
            this.previousJuvenileCourtPick=res.previousJuvenileCourtPicklist;
            
        }).catch(error => {

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
        })
    }
    
}