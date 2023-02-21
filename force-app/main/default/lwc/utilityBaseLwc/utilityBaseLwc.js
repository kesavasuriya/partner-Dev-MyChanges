import { LightningElement, api, track, wire  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Namespace from '@salesforce/label/c.Org_NamePrefix';
import hasNamespace from '@salesforce/label/c.HasNamespace';
import USER_ID from '@salesforce/user/Id'; 
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import { deleteRecord } from 'lightning/uiRecordApi';

export default class UtilityBaseLwc extends LightningElement {

    @api title;
    @api message;
    @api type;
    @api mode;
    @api deleteRecordId;
    addNSMap = {};
    @track error; 
    @api profileName;
    @api showApprovalBtn = false;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.profileName = data.fields.Profile.value.fields.Name.value;
            if(this.profileName =='Casevault Supervisor') {
                this.showApprovalBtn = true;
            }else{
                this.showApprovalBtn = false;
            }
        }
    }


    reduceErrors(errors) {

        if (!Array.isArray(errors)) {
            errors = [errors];
        }
    
        return (
            errors
                // Remove null/undefined items
                .filter((error) => !!error)
                // Extract an error message
                .map((error) => {
                    // UI API read errors
                    if (Array.isArray(error.body)) {
                        return error.body.map((e) => e.message);
                    }
                    // Page level errors
                    else if (
                        error?.body?.pageErrors &&
                        error.body.pageErrors.length > 0
                    ) {
                        return error.body.pageErrors.map((e) => e.message);
                    }
                    // Field level errors
                    else if (
                        error?.body?.fieldErrors &&
                        Object.keys(error.body.fieldErrors).length > 0
                    ) {
                        const fieldErrors = [];
                        Object.values(error.body.fieldErrors).forEach(
                            (errorArray) => {
                                fieldErrors.push(
                                    ...errorArray.map((e) => e.message)
                                );
                            }
                        );
                        return fieldErrors;
                    }
                    // UI API DML page level errors
                    else if (
                        error?.body?.output?.errors &&
                        error.body.output.errors.length > 0
                    ) {
                        return error.body.output.errors.map((e) => e.message);
                    }
                    // UI API DML field level errors
                    else if (
                        error?.body?.output?.fieldErrors &&
                        Object.keys(error.body.output.fieldErrors).length > 0
                    ) {
                        const fieldErrors = [];
                        Object.values(error.body.output.fieldErrors).forEach(
                            (errorArray) => {
                                fieldErrors.push(
                                    ...errorArray.map((e) => e.message)
                                );
                            }
                        );
                        return fieldErrors;
                    }
                    // UI API DML, Apex and network errors
                    else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    }
                    // JS errors
                    else if (typeof error.message === 'string') {
                        return error.message;
                    }
                    // Unknown error shape so try HTTP status text
                    return error.statusText;
                })
                // Flatten
                .reduce((prev, curr) => prev.concat(curr), [])
                // Remove empty strings
                .filter((message) => !!message)
        );
    }

    fireToastMsg() {

        const toastEvent = new ShowToastEvent({
            variant: this.type,
            title: this.title,
            message: this.message,
            mode: this.mode
        });
        this.dispatchEvent(toastEvent);

    }

    renameKeys(obj, newKeys, addNS) {

        if (Array.isArray(obj)) {

            var objAssignList = [];

            obj.forEach((element) => {

                var newkeyValues = Object.keys(element).map(key => {
                    var newKey2 = newKeys[key] || key;
                    if (typeof element[key] == 'object' || Array.isArray(element[key]) == true) {
                        return {
                            [newKey2]: this.checkNamespaceApplicable(element[key], addNS)
                        };
                    } else {

                        return {
                            [newKey2]: element[key]
                        };
                    }

                });

                objAssignList.push(Object.assign({}, ...newkeyValues));
            });
            return objAssignList;

        } else {
            var keyValues = Object.keys(obj).map(key => {
                var newKey = newKeys[key] || key;
                if (typeof obj[key] == 'object' || Array.isArray(obj[key]) == true) {

                    return {
                        [newKey]: this.checkNamespaceApplicable(obj[key], addNS)
                    };
                } else {
                    return {
                        [newKey]: obj[key]
                    };
                }

            });
            return Object.assign({}, ...keyValues);
        }
    }


    checkNamespaceApplicable(obj, addNS) {

        if (hasNamespace.toLowerCase() == 'true') {

            let objects = {};
            if (Array.isArray(obj)) {

                obj.forEach((element) => {
                    Object.assign(objects, element);
                });
            } else {

                objects = obj;
            }

            if (objects && Object.keys(objects).length) {
                if (addNS) {

                    Object.keys(objects).forEach((element) => {

                        if ((element.endsWith('__c') || element.endsWith('__r')) && !(element.startsWith(Namespace))) {
                            this.addNSMap[element] = Namespace + element;
                        }
                    });
                    return this.renameKeys(obj, this.addNSMap, addNS);
                } else {

                    Object.keys(objects).forEach((element) => {

                        if ((element.endsWith('__c') || element.endsWith('__r')) && element.startsWith(Namespace)) {

                            this.addNSMap[element] = element.substring(Namespace.length);
                        }
                    });
                    return this.renameKeys(obj, this.addNSMap, addNS);
                }
            } else {
                return obj;
            }
        } else {
            return obj;
        }
    }
    
    onValidate() {
        const allValid = [
            ...this.template.querySelectorAll("lightning-input"), ...this.template.querySelectorAll("lightning-combobox"), ...this.template.querySelectorAll("lightning-textarea"), ...this.template.querySelectorAll("lightning-radio-group"), ...this.template.querySelectorAll("lightning-dual-listbox")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return !allValid;
    }

    onRequiredValidate() {

        var isValid = true;
        const fields = this.template.querySelectorAll(".required-fields")
        fields.forEach(inputField => {
            if(inputField.disabled == true) {
                inputField.disabled = false;
                if((inputField.localName == 'lightning-input-field' && !inputField.value) || 
                    (inputField.localName != 'lightning-input-field' && !inputField.checkValidity())) {
                        inputField.reportValidity();
                        isValid = false;
                }
                inputField.disabled = true;
            } else {
                if((inputField.localName == 'lightning-input-field' && !inputField.value) || 
                    (inputField.localName != 'lightning-input-field' && !inputField.checkValidity())) {
                        inputField.reportValidity();
                        isValid = false;
                }
            }
        });    
        if (!isValid) {

            this.title = "Error!";
            this.type = "error";
            this.message = 'Complete the required field(s).';
            this.fireToastMsg(); 
        }
        return isValid;
    }

    deleteRecord(deleteId) {
        deleteRecord(deleteId)
        .then(() => {
            this.type = 'success';
            this.title = 'Success!';
            this.message = 'Record Deleted Successfully!';
            this.fireToastMsg();
        }) 
        .catch(error => {

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