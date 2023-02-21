import { LightningElement,api,track } from 'lwc';
import getPicklist from '@salesforce/apex/RelatedListController.getPicklistinfo';

export default class MultiselectPicklistLwc extends LightningElement {

    @api fieldName;
    @api fieldLabel;
    @api value;
    @track option=[];
    @track selectedValues =[];
    @api objectApiName;
    @api result =[];
    @api columns;
    @api required;


    connectedCallback() {

        console.log('fieldName:::::',this.fieldName);
        document.documentElement.style.setProperty('--columns',this.columns);
        getPicklist({objectName : this.objectApiName,fieldName : this.fieldName,isMultiPicklist : true})
        .then(res =>{
            this.option = JSON.parse(res);
            console.log('options',this.option);
            if(this.value[0] != null) {
                let selectedValuesStr = this.value[0];
                this.selectedValues = selectedValuesStr.split(';');
                this.result.push(selectedValuesStr);
            }
        
        })
        console.log('label',this.fieldLabel);
        console.log('value',this.value);
    }

    handleChange(event) {
        let value = event.target.value;
        this.result = [];
        let converttoStr = value.join(';');
        this.result.push(converttoStr);
    }
}