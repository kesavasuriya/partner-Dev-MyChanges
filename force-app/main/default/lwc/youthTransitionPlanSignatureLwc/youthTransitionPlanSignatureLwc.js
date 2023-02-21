import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';


export default class YouthTransitionPlanSignatureLwc extends LightningElement {

    signatureFieldName = '';
    @api youthSign;
    @api LDSSSign;
    @api familyMemberSign;

    showSignModal = false;
    showParent1 = false;
    showParent2 = false;
    showParent3 = false;
    sourceUrlParent1 = '';
    sourceUrlParent2 = '';
    sourceUrlParent3 = '';

    connectedCallback() {

        if(this.youthSign) {

            let removeImageTag = this.youthSign.replaceAll("&amp;","&");
            this.sourceUrlParent1 = removeImageTag.substring(10,removeImageTag.length-8);
            this.showParent1 = true;
            
         } 
         if(this.LDSSSign) {

            let removeImageTag = this.LDSSSign.replaceAll("&amp;","&");
            this.sourceUrlParent2 = removeImageTag.substring(10,removeImageTag.length-8);
            this.showParent2 = true;
            
         } 
         if(this.familyMemberSign){

            let removeImageTag = this.familyMemberSign.replaceAll("&amp;","&");
            this.sourceUrlParent3 = removeImageTag.substring(10,removeImageTag.length-8);
            this.showParent3 = true;
            
         } 
    }

    handleSignModal(event) {

        this.signatureFieldName = event.target.name;
        this.showSignModal = true;
    }

    closeSignModal() {

        this.showSignModal = false;
    }

    handleSignature(event) {

        if(this.signatureFieldName == 'Youth_Signature__c') {
            let Youthimage = '<img src="data:image/jpeg;base64,'+event.detail+'">';
            this.youthSign = Youthimage;
            const youthSign = new FlowAttributeChangeEvent('youthSign',this.youthSign);
            this.dispatchEvent(youthSign);
        } else if(this.signatureFieldName == 'LDSS_Representative_Signature__c') {
            let LDSSImage = '<img src="data:image/jpeg;base64,'+event.detail+'">';
            this.LDSSSign = LDSSImage;
            const LDSSSign = new FlowAttributeChangeEvent('LDSSSign',this.LDSSSign);
            this.dispatchEvent(LDSSSign);
        } else if(this.signatureFieldName == 'Family_Member_Signature__c') {
            let familyMemberImage = '<img src="data:image/jpeg;base64,'+event.detail+'">';
            this.familyMemberSign = familyMemberImage;
            const familyMemberSign = new FlowAttributeChangeEvent('familyMemberSign',this.familyMemberSign);
            this.dispatchEvent(familyMemberSign);
        }
       
    }

}