import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class TitleIvEStageLWC extends NavigationMixin(LightningElement) {

    @api steps=[];
    @api currentTitleIvERec;
    @api rec = {};
    @track titleIVEId;
    isLegal = true;
    isAFDCRelatedness = false;
    isPlacement = false;
    isOtherCriteria = false;
    @track currentStage = '';
    @track loading = false;


    connectedCallback() {
        var currentStageVal = this.steps;
        this.titleIVEId = this.currentTitleIvERec.Id;
    }
    
    stageAction(event) {

        var currentOnStageValue = event.target.value;
        var currentStageValue = this.steps;
        this.currentStage = currentOnStageValue;
        
        if(currentOnStageValue == 'Legal') {

            this.isLegal = true;
            this.isAFDCRelatedness = false;
            this.isPlacement = false;
            this.isOtherCriteria = false;
        } else if(currentOnStageValue == 'AFDC Relatedness')  {

            this.isAFDCRelatedness = true;
            this.isLegal = false;
            this.isPlacement = false;
            this.isOtherCriteria = false;
        } else if(currentOnStageValue == 'Placement')  {

            this.isPlacement = true;
            this.isLegal = false;
            this.isAFDCRelatedness = false;
            this.isOtherCriteria = false;
        } else if(currentOnStageValue == 'Other Criteria')  {

            this.isOtherCriteria = true;
            this.isLegal = false;
            this.isAFDCRelatedness = false;
            this.isPlacement = false;
        }

    }

    handleBackBtn(event) {
        this[NavigationMixin.Navigate]({
            "type": "standard__recordRelationshipPage",
            "attributes": {
                recordId: '0035w00003M5nhvAAB',
                objectApiName: 'Contact'
                
            }
    });
    }
}