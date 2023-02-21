import { LightningElement, api, track } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getSubsidyAgreeInitInfo from '@salesforce/apex/AdoptionCaseController.getSubsidyAgreementIntiInfos';
import getProviders from '@salesforce/apex/PlacementController.fetchAccount';
import getSelectProviderInfos from '@salesforce/apex/PermanacyPlanAdoptionController.getSelectProviderDetail';
import updateSubsidyAgreementRec from '@salesforce/apex/AdoptionCaseController.updateSubsidyAgreement';
import onSubmitSubsidyAgreementApprovalProcess from '@salesforce/apex/AdoptionCaseController.onSubmitSubsidyAgreementApprovalProcess';
import uploadFile from '@salesforce/apex/CourtOrderController.uploadFile';
import getRelatedFilesByRecordId from '@salesforce/apex/CourtOrderController.getRelatedFilesByRecordId';
import { NavigationMixin } from 'lightning/navigation';
import deleteFile from '@salesforce/apex/AdoptionCaseController.deleteFile';
import editFileUpload from '@salesforce/apex/AdoptionCaseController.editFileUpload';

const columns = [
    { label: 'PROVIDER ID', fieldName: 'Casevault_ProID__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' } },
    { label: 'PROVIDER NAME', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'VACANCY', fieldName: 'Number_of_Beds__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' } },
    { label: 'PLACEMENT STRUCTURE', fieldName: 'Placement_Service__c', type: 'text', sortable: true },
    { label: 'PROVIDER CATEGORY', fieldName: 'Type__c', type: 'text', sortable: true }
];

const actions = [
    { label: 'Preview', name: 'preview'},
    { label: 'Edit', name: 'edit'},
    { label: 'Delete', name: 'delete'}
    
];
const columnlist = [
    { label: 'Document Name', fieldName: 'label', type: 'string'},
    { type: 'action', typeAttributes: { rowActions: actions} }
    
];

export default class AdoptionCaseSubsidyAgreement extends NavigationMixin(UtilityBaseElement) {

    @api adoptionCaseId;
    @track adoptiveSubsidyIsPaidpick;
    @track childPlacedFrompick;
    @track childPlacedBypick;
    @track placementStructurePick;
    @track childCharPick;
    @track localDeptPick;
    @track showSearchProviderModal = false;
    @track searchInput = {};
    columns = columns;
    columnlist = columnlist;
    @track providerList = [];
    @track selectedProviderId;
    @track sleectproviderMD_chessie_Id;
    @track adoptiveParent1;
    @track adoptiveParent2;
    @track showProviderTable = false;
    @track isLoading = false;
    @track showSubmitforApprovalModal = false;
    @track selectedUserId;
    @track enableSubmit = false;
    @track enableSubmitForApprovalBtn = false;
    @track subsidyAgreementRec = {};
    @track readOnly = false;
    @track showSignModal = false;
    @track signatureFieldName;
    @track signatureObj = {};
    fileData;
    @track fileList = [];
    showFiles = false;
    showEditFile = false;
    editFileId = '';
    submitButton = true;
    eventName;
    sourceUrlParent1 = '';
    sourceUrlParent2 = '';
    sourceUrlLDSS = '';
    showParent1 = false;
    showParent2 = false;
    showLDSS = false;

    get providerTypes() {
        return [
            {'label': 'Public', 'value': 'Public Provider'},
            {'label': 'Private', 'value': 'Private Provider Org'},
        ];
    }

    connectedCallback() {

       
        this.getAdoptionCaseSubsidyAgreeInfos();
        this.getFiles();
    }
    getAdoptionCaseSubsidyAgreeInfos() {
        
        this.isLoading = true;
        getSubsidyAgreeInitInfo({adoptionCaseId: this.adoptionCaseId}).then(result => {
            if (result) {

                let res = JSON.parse(result);
                this.adoptiveSubsidyIsPaidpick = res.adoptiveSubsidyIsPaidPicklist;
                this.childPlacedFrompick = res.childPlacedFromPicklist;
                this.childPlacedBypick = res.childPlacedByPicklist;
                this.placementStructurePick = res.placementStructurePicklist;
                this.childCharPick=res.childCharPicklist;
                this.localDeptPick=res.localDeptPicklist;
                this.isLoading = false;
                if(res.adoptionCaseSubsidyAgreementRec) {

                     this.subsidyAgreementRec = this.checkNamespaceApplicable(res.adoptionCaseSubsidyAgreementRec,false);
                     if(this.subsidyAgreementRec.Adoptive_Parent_1_Signature__c) {

                        let removeImageTag = this.subsidyAgreementRec.Adoptive_Parent_1_Signature__c.replaceAll("&amp;","&");
                        this.sourceUrlParent1 = removeImageTag.substring(10,removeImageTag.length-8);
                        this.showParent1 = true;
                        
                     } 
                     if(this.subsidyAgreementRec.Adoptive_Parent_2_Signature__c) {

                        let removeImageTag = this.subsidyAgreementRec.Adoptive_Parent_2_Signature__c.replaceAll("&amp;","&");
                        this.sourceUrlParent2 = removeImageTag.substring(10,removeImageTag.length-8);
                        this.showParent2 = true;
                        
                     } 
                     if(this.subsidyAgreementRec.LDSS_Director_DESIGNEE_SIGNATURE__c) {

                        let removeImageTag = this.subsidyAgreementRec.LDSS_Director_DESIGNEE_SIGNATURE__c.replaceAll("&amp;","&");
                        this.sourceUrlLDSS = removeImageTag.substring(10,removeImageTag.length-8);
                        this.showLDSS = true;
                        
                     }      
                }
                if ((this.subsidyAgreementRec.Subsidy_Agreement_Approval_Status__c == 'Submitted') ||(this.subsidyAgreementRec.Subsidy_Agreement_Approval_Status__c == 'Approved')) {
                    this.readOnly = true;
                }
            }
        }).catch(error => {
            this.isLoading = false;
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
        })
    }

    searchHandle(event) {

        let name = event.target.name;
        let value = event.target.value;
        this.searchInput[name] = value;
    }

    handleShowSearch(event) {

        this.showSearchProviderModal = true;
    
    }

    closeSearchModal(event) {

        this.showSearchProviderModal = false;
    }

    handleSearchProvider() {

        this.isLoading = true;
        getProviders({searchInputJSON:JSON.stringify(this.searchInput)})   
        .then(result => {
            if (result) {

                this.providerList = this.checkNamespaceApplicable(JSON.parse(result),false); 
                this.isLoading = false;
                this.showSearchProviderModal = false;
                this.showProviderTable = true;
                if (!this.providerList.length) {
                    this.title = "info!";
                    this.type ="info";
                    this.message = "Such provider not exsits";
                    this.fireToastMsg();
                }
            }
        }).catch(error => {
            this.isLoading = false;
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
        })
    }

    handleRowSelection(event) {

        var selectedRows=event.detail.selectedRows;
        this.selectedProviderId = selectedRows[0].Id;
        this.sleectproviderMD_chessie_Id = selectedRows[0].Casevault_ProID__c;  
        this.subsidyAgreementRec.Subsidy_Provider_Id__c = this.sleectproviderMD_chessie_Id;
    }

    closeShowTableModal(event) {
        
        this.showSearchProviderModal = false;
        this.showProviderTable =false;
    }

    handleSelectedProvider(event) {

        this.isLoading = true;
        getSelectProviderInfos({providerId: this.selectedProviderId})
        .then(result => {
            if (result) {

                this.showProviderTable = false;
                let appilcantAndCoAppilcantList = this.checkNamespaceApplicable(JSON.parse(result),false);
                if(appilcantAndCoAppilcantList.length) {
                    for (let i=0; i<appilcantAndCoAppilcantList.length; i++) {
                        if(appilcantAndCoAppilcantList[i].Applicant_or_Co_Applicant__c == "Applicant") {
                            this.subsidyAgreementRec.Adoptive_Parent_1__c = appilcantAndCoAppilcantList[i].Name;
                       } else if (appilcantAndCoAppilcantList[i].Applicant_or_Co_Applicant__c == "Co-Applicant") {
                            this.subsidyAgreementRec.Adoptive_Parent_2__c = appilcantAndCoAppilcantList[i].Name;
                        }
                    }
                }
            }
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
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
        })   

    }
    

    handleChange(event) {

        let fieldType = event.target.type;
        if (fieldType != 'checkbox') {

           

            this.subsidyAgreementRec[event.target.name] = event.target.value;

        } else {
            this.subsidyAgreementRec[event.target.name] = event.target.checked;
        }
        
    }


    handleSaveAgreement() {

        if(!this.onValidate() && this.signatureObj != null) { 
            this.subsidyAgreementRec.Id = this.adoptionCaseId;
            this.isLoading = true;
            
            updateSubsidyAgreementRec({adoptionCaseJSON : JSON.stringify(this.checkNamespaceApplicable(this.subsidyAgreementRec,true)), parent1Signature : this.signatureObj.Adoptive_Parent_1_Signature__c, parent2Signature : this.signatureObj.Adoptive_Parent_2_Signature__c, lDSSDirectorSignature : this.signatureObj.LDSS_Director_DESIGNEE_SIGNATURE__c})
            .then(result => {

                this.isLoading = false;
                this.getAdoptionCaseSubsidyAgreeInfos();
                this.getFiles();
                this.title ="Success!";
                this.type="success";
                this.message="Subsidy Agreement Updated Successfuly";
                this.fireToastMsg();
            }).catch(error => {
                this.isLoading = false;
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
            })   

        } else {
                this.title ="Error!";
                this.type="error";
                this.message="Please complete the requried field(s)";
                this.fireToastMsg();
        }
    }

  handleSubmitForApproval(event) {

        if(!this.onValidate() && this.signatureObj != null) { 

            this.subsidyAgreementRec.Id = this.adoptionCaseId;
            this.isLoading = true;
            updateSubsidyAgreementRec({adoptionCaseJSON : JSON.stringify(this.checkNamespaceApplicable(this.subsidyAgreementRec,true)), parent1Signature : this.signatureObj.Adoptive_Parent_1_Signature__c, parent2Signature : this.signatureObj.Adoptive_Parent_2_Signature__c, lDSSDirectorSignature : this.signatureObj.LDSS_Director_DESIGNEE_SIGNATURE__c})
            .then(result => {

                this.isLoading = false;
                this.getAdoptionCaseSubsidyAgreeInfos();
                this.getFiles();
                this.title ="Success!";
                this.type="success"
                this.message="Subsidy Agreement Updated Successfuly"
                this.fireToastMsg();
                if (this.subsidyAgreementRec.Subsidy_Agreement_Approval_Status__c !='Approved') {
                    this.showSubmitforApprovalModal = true;
                    this.enableSubmitForApprovalBtn = false;
                } else if ((this.subsidyAgreementRec.Subsidy_Agreement_Approval_Status__c = 'Submitted') ||(this.subsidyAgreementRec.Subsidy_Agreement_Approval_Status__c = 'Approved')) {
                    this.showSubmitforApprovalModal = false; 
                    this.readOnly = true;
                    this.ttitle='Error!';
                    this.type = "error";
                    this.message ="Subsidy Agreement Record Already Submitted "
                    this.fireToastMsg();
                }
            }).catch(error => {
                this.isLoading = false;
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
            })   

        } else {
            this.title ="Error!";
                this.type="error"
                this.message="Please complete the requried field(s)"
                this.fireToastMsg();
        }
    }

    closeSubmiteModal(event) {

        this.showSubmitforApprovalModal = false;
    }

    handleSelectRec(event) {

        this.selectedUserId = event.detail.recordId;
        this.enableSubmit = this.selectedUserId?false:true;
    }
    submitApproval(event) {

        this.isLoading = true;
        onSubmitSubsidyAgreementApprovalProcess({adoptionCaseId: this.adoptionCaseId, selectedSupervisorUserId:this.selectedUserId})
        .then(result=>{

            this.showSubmitforApprovalModal = false;
            this.isLoading = false;
            this.title = "Success!";
            this.type = "success";
            this.message = "Subsidy Agreement Record Submitted for Approval Successfully";
            this.fireToastMsg();
            this.getAdoptionCaseSubsidyAgreeInfos();
        })
        .catch(error => {

            let errorMsg;
            this.title = "Error!";
            this.type = "error";
            if (error) {
                let errors = this.reduceErrors(error);
                errorMsg = errors.join('; ');
            } else {
                errorMsg = 'Unknown Error';
            }
            this.isLoading = false;
            this.message = errorMsg;
            this.fireToastMsg();
        })
    }

    handleSignModal(event) {

        this.signatureFieldName = event.target.name;
        this.showSignModal = true;
    }

    closeSignModal() {

        this.showSignModal = false;
    }

    handleSignature(event) {

        this.signatureObj[this.signatureFieldName] = event.detail;
    }

    openfileUpload(event) {

        this.eventName=event.target.name;
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.adoptionCaseId
            }
            if(this.eventName == "insertFile") {
                this.handlefileClick();
            } else if(this.eventName == "editFile") {
                this.submitButton = false;
            }
            
        }
        reader.readAsDataURL(file);
        
    }

    handlefileClick(){

        this.isLoading = true;
        const {base64, filename, recordId} = this.fileData
        uploadFile({ base64, filename, recordId })
        .then(result=>{
            this.fileData = null;
            this.isLoading = false;
            let msg = `${filename} uploaded successfully!!`
            this.title = "Success!";
            this.type = "success";
            this.message = msg;
            this.fireToastMsg();
        }).catch(error => {

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
            this.isLoading = false;
            this.fireToastMsg();
        })
    }

    getFiles() {

        this.isLoading = true;
        getRelatedFilesByRecordId({recordId : this.adoptionCaseId})
        .then( result => {
            this.fileList = Object.keys(result).map(item => ({
                "label":result[item],
                "value": item
                
            }))
            if(this.fileList.length) {
                this.showFiles = true;
            }
            this.isLoading = false;
            
        }).catch(error => {

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
            this.isLoading = false;
            this.fireToastMsg();
        })
    }

    previewHandler(row){

        
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: row.value
            }
        })
    }

    deleteHandler(row) {

        let id = row.value;
        this.isLoading = true;
        deleteFile({fileId:id})
        .then(result => {

            this.isLoading = false;
            this.title = "Success!";
            this.type = "success";
            this.message = 'File deleted';
            this.fireToastMsg();
            this.getFiles();
        }).catch(error => {

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
            this.isLoading = false;
            this.fireToastMsg();
        })

        
    }

    editHandler(row) {

        this.editFileId = row.value;
        this.showEditFile = true;
    }

    hideEditFile() {

        this.showEditFile = false;
    }

    handleFileSubmit() {

        const {base64, filename, recordId} = this.fileData;
        this.isLoading = true;
        editFileUpload({base64:base64, filename:filename, fileId:this.editFileId })
        .then(result=>{

            this.showEditFile = false;
            this.fileData = null;
            this.isLoading = false;
            let msg = `${filename} uploaded successfully!!`
            this.title = "Success!";
            this.type = "success";
            this.message = msg;
            this.fireToastMsg();
            this.getFiles();
        }).catch(error => {

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
            this.isLoading = false;
            this.fireToastMsg();
        })
    }

    handleRowAction(event) {

        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'preview': 
                this.previewHandler(row);
                break;
            case 'edit': 
                this.editHandler(row);
                break;
            case 'delete': 
                this.deleteHandler(row);
                break;
        }
    }

    
}