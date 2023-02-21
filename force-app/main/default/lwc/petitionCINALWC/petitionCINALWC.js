import { LightningElement, track, api } from 'lwc';
import getInitiInfo from '@salesforce/apex/CourtController.getInitialInfos';
import savePetitionCINARec from '@salesforce/apex/CourtController.upsertPetition';
import deleteSiblingRec from '@salesforce/apex/CourtController.deleteSiblingRec';
import deleteSubpoenaedRec from '@salesforce/apex/CourtController.deleteSubpoenaed';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import UtilityBaseElement from 'c/utilityBaseLwc';
export default class PetitionCINALWC extends UtilityBaseElement{

    @track newReviewPick = [];
    @track emerengcyPick =[];
    @track childCurrentPlacementpick =[];
    @track parentNamePick = [];
    @track previousJuvenileCourtPick = [];
    @track parentsCircumstancePick = [];
    @track specialneedsofRespondentPick = [];
    @track whatServicesWereOfferedPick = [];
    @track wereReasonableEffortsNotMadePick = [];
    @track familyInvolvementMeetingPick = [];
    @track petCINARec = {};
    @track siblingRec = {};
    @api recordId;
    @track showSiblingModal = false;
    @api petitionRec = {};
    @api petId = '';
    @api siblingId='';
    @track petitionRec = {};
    @api siblingsList = [];
    @track subpoenedRec = {};
    @track showSubpoenaedModal = false;
    @track subpoenaedList = [];
                          
    connectedCallback() {
        this.petitionRec = this.petitionRec;
       
        
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
            this.parentsCircumstancePick = res.parentsCircumstancePicklist;
            this.specialneedsofRespondentPick=res.specialneedsofRespondentPicklist;
            this.whatServicesWereOfferedPick = res.whatServicesWereOfferedPicklist;
            this.wereReasonableEffortsNotMadePick = res.wereReasonableEffortsNotMadePicklist;
            this.familyInvolvementMeetingPick=res.familyInvolvementMeetingPickList;
            this.siblingsList = res.siblingsList;
            this.subpoenaedList = res.subpoenaedList;
        }).catch(error => {

            let errorMsg;
            this.title ="Error!";
            this.type ="error";
            if(error) {
            
            if (Array.isArray(error.body)) {
            errorMsg = error.body.map(e => e.message).join('; ');
            }
            else if (typeof error.body.message === 'string') {
            errorMsg = error.body.message;
            }
            } else {
            errorMsg = 'Unknown Error';
            }
            this.message = errorMsg;
            this.fireToastMsg();
            })
    }

    handleChange(event) {
        
        let fieldName = event.target.name;
        let checkedfields = event.target.checked;      
        let Value = event.target.value;
        let fieldType = event.target.type;
       
        if(fieldType != 'checkbox'){
            if(fieldName =='Child_s_Current_placement_if_not_foster__c' || fieldName =='D_Special_needs_of_Respondent__c' ||
                         fieldName =='PARENT_S_CIRCUMSTANCE__c' || fieldName =='C_What_Services_were_offered_prior__c' ) {
                let multiValues = Value.join(';');
                this.petCINARec[fieldName] =  multiValues;
            } else {
                this.petCINARec[fieldName] = Value;
            }
        } else {
            this.petCINARec[fieldName] =  checkedfields;
        }
        
        const petitionCINAJSON = new CustomEvent('selected', { detail: 
                {
                    petRec : this.petCINARec
                }
        });
        this.dispatchEvent(petitionCINAJSON);
        
    }

    handleSave(event) {
        if(!this.onValidate()) {   
            savePetitionCINARec({petitionJSONStr: JSON.stringify(this.petCINARec)})
            .then(result => {
                let res = result;
                let toastMsg = this.petCINARec.Id?'Petition CINA Record updated succesfully':'Petition CINA Record created succesfully';
                const event = this.onToastEvent('success', 'Success!', toastMsg);
                this.dispatchEvent(event);
            }).catch(error => {

                let errorMsg;
                this.title ="Error!";
                this.type ="error";
                if(error) {
                
                if (Array.isArray(error.body)) {
                errorMsg = error.body.map(e => e.message).join('; ');
                }
                else if (typeof error.body.message === 'string') {
                errorMsg = error.body.message;
                }
                } else {
                errorMsg = 'Unknown Error';
                }
                this.message = errorMsg;
                this.fireToastMsg();
                })
        } else {
            const event = this.onToastEvent('error', 'Error!', 'Please complete the required field(s).');
            this.dispatchEvent(event);
        }
    }

    addSibling(event) {
        this.showSiblingModal = true;
    }

    cancelSiblingModal(event) {
        this.showSiblingModal = false;
    }

    handleChangeSibling(event) {

        let fieldName = event.target.name;
        let checkedfields = event.target.checked;      
        let Value = event.target.value;
        let fieldType = event.target.type;
        if(fieldType != 'checkbox') {
            this.siblingRec[fieldName] = Value;
        }else {
            this.siblingRec[fieldName] = checkedfields;
        }
      

    }

    handleAdd(event) {
        const childdetail = new CustomEvent('childrecord', {detail :
            { sibling: this.siblingRec
            }
        });
        this.dispatchEvent(childdetail);
        this.showSiblingModal = false;
    }

    addHandleSubpoenaed(event) {
        const subpoenaedDetail = new CustomEvent('subpoenaed', {detail : {
            subpoenaed: this.subpoenedRec
        }
        });
        this.dispatchEvent(subpoenaedDetail);
        this.showSubpoenaedModal = false;
    }

    handleChangeSubpoened(event) {
        let fieldName = event.target.name;
        let checkedfields = event.target.checked;
        let value = event.target.value;
        let fieldType = event.target.type;
       
        if(fieldType != 'checkbox') {
            this.subpoenedRec[fieldName] = value;
        } else {
            this.subpoenedRec[fieldName] = checkedfields;
        }
    }

    addSubpoenaed(event) {
        this.showSubpoenaedModal = true;
    }

    canceSubpoenaedModal(event) {
        this.showSubpoenaedModal = false;
    }

    handleIconAction(event) {
       
        
        let childPersonId = event.target.dataset.childid;
        this.contactId = childPersonId;
        let actionValue = event.target.name;
        switch (actionValue) {
            case 'edit':
                this.showSiblingModal = true;
                let foundelement = this.siblingsList.find(ele => ele.Id == event.target.dataset.childid);
                this.siblingRec = foundelement;
                break;
            case 'delete':
                let record = this.siblingsList.find(ele => ele.Id == event.target.dataset.childid);
                if (record) {
                    deleteSiblingRec({siblingRec: JSON.stringify(record)})
                    .then(result => {
                        let res = result;
                        let rows = this.siblingsList;
                        const rowIndex = rows.indexOf(record);
                        rows.splice(rowIndex, 1);
                        this.siblingsList = rows;
                        const event = this.onToastEvent('success', 'Success!', 'Sibling record deleted successfully.');
                        this.dispatchEvent(event);
                        this.doInitInfo();
                     }).catch(error => {

                        let errorMsg;
                        this.title ="Error!";
                        this.type ="error";
                        if(error) {
                        
                        if (Array.isArray(error.body)) {
                        errorMsg = error.body.map(e => e.message).join('; ');
                        }
                        else if (typeof error.body.message === 'string') {
                        errorMsg = error.body.message;
                        }
                        } else {
                        errorMsg = 'Unknown Error';
                        }
                        this.message = errorMsg;
                        this.fireToastMsg();
                        })
                }
                break;
            case 'subpoenaedEdit':
                this.showSubpoenaedModal = true;
                let subFoudEle = this.subpoenaedList.find(ele => ele.Id == event.target.dataset.childid);
                this.subpoenedRec = subFoudEle;
                break;
            case 'subpoenaedDelete':
                let delRec = this.subpoenaedList.find(ele => ele.Id == event.target.dataset.childid);
                if(delRec){
                    deleteSubpoenaedRec({subpoenaedRec: JSON.stringify(delRec)})
                    .then(result =>{
                        let res = result;
                        let rows = this.subpoenaedList;
                        const rowIndex = rows.indexOf(delRec);
                        rows.splice(rowIndex, 1);
                        this.subpoenaedList = rows;
                        const event = this.onToastEvent('success', 'Success!', 'Sibling record deleted successfully.');
                        this.dispatchEvent(event);
                        this.doInitInfo();
                     }).catch(error => {

                        let errorMsg;
                        this.title ="Error!";
                        this.type ="error";
                        if(error) {
                        
                        if (Array.isArray(error.body)) {
                        errorMsg = error.body.map(e => e.message).join('; ');
                        }
                        else if (typeof error.body.message === 'string') {
                        errorMsg = error.body.message;
                        }
                        } else {
                        errorMsg = 'Unknown Error';
                        }
                        this.message = errorMsg;
                        this.fireToastMsg();
                        })                   
                }
                break;
        }
    }

    onValidate(){
        const allValid = [
            ...this.template.querySelectorAll("lightning-input"),...this.template.querySelectorAll("lightning-combobox"),...this.template.querySelectorAll("lightning-textarea")
            ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
            }, true);
            return !allValid;
    }

    onToastEvent(type, toastTitle, msg) {
        const toastEvent = new ShowToastEvent({
            variant: type,
            title: toastTitle,
            message: msg,
        });
        return toastEvent;
    }
    
}