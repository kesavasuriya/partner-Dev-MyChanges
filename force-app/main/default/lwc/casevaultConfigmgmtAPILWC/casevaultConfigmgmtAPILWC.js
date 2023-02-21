import { LightningElement,track } from 'lwc';
import getAllConfig from '@salesforce/apex/CaseVaultCalloutHandler.getAllConfig';
import addConfig from '@salesforce/apex/CaseVaultCalloutHandler.addConfig';
import updateConfig from '@salesforce/apex/CaseVaultCalloutHandler.updateConfig';
import UtilityBaseElement from 'c/utilityBaseLwc';

export default class CasevaultConfigmgmtAPILWC extends UtilityBaseElement {
    @track showTable = false;
    @track allConfigList = [];
    @track showModal = false;
    @track showUpdateModal = false;
    @track addConfig = {};
    @track updateConfig = {};
    @track visibleData = [];
    showChild = false;
    
    
    connectedCallback() {

        this.doInitInfo();
    }

    doInitInfo() {

        this.showChild = false;
        getAllConfig()
        .then(result => {
            let res = JSON.parse(result);
            this.allConfigList = res;
            this.showTable =  this.allConfigList.length? true: false; 
            this.showChild = true;
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

    handleChange(event) {

        if(event.target.name == 'Config Name') {
            this.addConfig.configName = event.target.value;
        }
        else if(event.target.name == 'Config Description') {
            this.addConfig.configDescription = event.target.value;
        }
        else if(event.target.name == 'Config Value') {
            this.addConfig.configValue = event.target.value;
        }
        else if(event.target.name == 'Config Name Update') {
            this.updateConfig.configName = event.target.value;
        }
        else if(event.target.name == 'Config Description Update') {
            this.updateConfig.configDescription = event.target.value;
        }
        else if(event.target.name == 'Config Value Update') {
            this.updateConfig.configValue = event.target.value;
        }
    }

    handleAdd() {

        this.showModal = true;
        this.addConfig = {};
    }

    handleDiscard() {

        this.showModal = false;
    
    }

    handleSave() {

        this.showModal = false;
        addConfig({configName : this.addConfig.configName,configDesc : this.addConfig.configDescription ,configValue : this.addConfig.configValue });
        this.doInitInfo();

    }

    handleEdit(event) {

        let row = event.target.name;
        this.updateConfig.configID = row.configID;
        this.updateConfig.configName = row.configName;
        this.updateConfig.configDescription = row.configDesc;
        this.updateConfig.configValue = row.configValue;
        this.showUpdateModal = true;
        
    }

    handleDiscardUpdate() {

        this.showUpdateModal = false;
        this.updateConfig = {};
    }

    handleSaveUpdate() {

        this.showUpdateModal = false;
        updateConfig({configID : this.updateConfig.configID,configName :this.updateConfig.configName,configDesc : this.updateConfig.configDescription ,configValue : this.updateConfig.configValue} );
        this.doInitInfo();
    }

    paginationHandler(event) {

        this.visibleData = [...event.detail.records];     
    }
}