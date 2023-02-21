import { LightningElement, api, track } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class RemovalMetrostopsLwc extends UtilityBaseElement {

    @api recordId;
    @track selectedChildRec = {};
    currentStep = '1';
    showChild = false;
    showStep1 = false;
    showStep2 = false;
    showStep3 = false;
    showStep4 = false;
    @track childRemovalRec = {};
    
    
    get inputVariables() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

    get inputVariables1() {

        return [
            {
                name: 'selectedChildRec',
                type: 'SObject',
                value: this.selectedChildRec
            }
        ];
    }

    get inputVariables2() {

        return [
            {
                name: 'Selected_Child_Rec',
                type: 'SObject',
                value: this.selectedChildRec
            },
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }

        ];
    }

    get inputVariables3() {

        return [
            {
                name: 'Child_Removal_Record',
                type: 'SObject',
                value: this.childRemovalRec
            },
            

        ];
    }
        
    

    connectedCallback() {

        this.doInit();
    }

    doInit() {

        this.showChild = true;
    }

    handleStatusChange(event) {

        if (event.detail.status === 'FINISHED') {

            this.showChild = false;
            let outputVariables = event.detail.outputVariables;
            this.selectedChildRec = outputVariables[0].value;
            console.log('selectedChildRec========',this.selectedChildRec);
            this.showStep1 = true;
            this.currentStep = '1';

        }
    }

    handleStatusChange1(event) {

        console.log('detail:::',event.detail);
        if(event.detail.status === 'FINISHED') {

           this.handleStage2();
           this.currentStep = '2';
        }

    }

    handleStatusChange2(event) {

        console.log('detail:::',event.detail);

        if(event.detail.status === 'FINISHED') {

            this.handleStage3();
            this.currentStep = '3';
         }

    }

    handleStatusChange3(event) {

        console.log('detail:::',event.detail);
        if(event.detail.status === 'FINISHED') {
            
            let outputVariables = event.detail.outputVariables;
            this.childRemovalRec = outputVariables[0].value;
            this.handleStage4();
            this.currentStep = '4';
        }

    }

    handleStatusChange4(event) {

        if(event.detail.status === 'FINISHED') {

            this.handleChildScreen();
        }
    }

    handleChildScreen() {

        this.showChild = true;
        this.currentStep = '1';
        this.showStep1 = false;
        this.showStep2 = false;
        this.showStep3 = false;
        this.showStep4 = false;
    }

    handleActionStage1() {

        console.log('1::::');
        
        if(this.selectedChildRec.Id) {
            this.handleStage1();

        } else {
            this.handleRestrict();
        }
    }

    handleActionStage2(event) {

        console.log('xxxx:::');
        let clickedStage = event.target.value;
        console.log('clicked::',clickedStage);
        
        if(this.currentStep >= clickedStage) {

            this.handleStage2();
                   
        } else {
            
            this.handleRestrict();
        }
        
    }

    handleActionStage3(event) {

        let clickedStage = event.target.value;
        console.log('clicked::',clickedStage);

        
        if(this.currentStep >= clickedStage) {

            this.handleStage3();

        } else {
            
            this.handleRestrict();
        }
              
    }

    handleActionStage4(event) {

        let clickedStage = event.target.value;
        console.log('clicked::',clickedStage);

        if(this.currentStep >= clickedStage) {

            this.handleStage4();
        }
        
    }

    handleStage1() {

        this.showStep1 = true;
        this.showStep2 = false;
        this.showStep3 = false;
        this.showStep4 = false;
    }

    handleStage2() {

        this.showStep1 = false;
        this.showStep2 = true;
        this.showStep3 = false;
        this.showStep4 = false;
    }

    handleStage3() {

        this.showStep1 = false;
        this.showStep2 = false;
        this.showStep3 = true;
        this.showStep4 = false;
    }

    handleStage4() {

        this.showStep1 = false;
        this.showStep2 = false;
        this.showStep3 = false;
        this.showStep4 = true;
    }

    handleRestrict() {
     
        this.title = "Error!";
        this.type = "error";
        this.message = 'Complete the previous stage';
        this.fireToastMsg();
    }
}