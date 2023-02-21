import { track, api } from 'lwc';
import UtilityBaseElement from 'c/utilityBaseLwc';
import getInitiInfo from '@salesforce/apex/ServiceCaseController.getAssignmentRecords';
import createAssignmentRecord from '@salesforce/apex/ServiceCaseController.createAssignments';
import UserNameFld from '@salesforce/user/Id';

const actions = [
    { label: 'Preview', name: 'preview'},
    { label: 'Edit', name: 'edit'}
    
];

const assignmentTableColumns= [{label: 'Local Department', fieldName: '', type: 'string', wrapText: true},
{label: 'Unit', fieldName: 'Select_a_Unit__c', type: 'string', wrapText: true},
{label: 'Assigned By', fieldName: 'assignedByname', type: 'string', wrapText: true},
{label: 'Assigned To', fieldName: 'name', type: 'string', wrapText: true},
{label: 'Responsibility', fieldName: 'Responsibility__c', type: 'string', wrapText: true},
{label: 'Child', fieldName: 'Child_List__c', type: 'string', wrapText: true},
{label: 'Start Date', fieldName: 'Assign_Start_Date__c', type: 'date', wrapText: true,typeAttributes: {day: "numeric",month: "numeric",year: "numeric"}},
{label: 'End Date', fieldName: 'Assign_End_Date__c', type: 'date', wrapText: true,typeAttributes: {day: "numeric",month: "numeric",year: "numeric"}},
 { type: 'action', typeAttributes: { rowActions: actions} }
];


export default class ServicecaseAssignUserLWC extends UtilityBaseElement {

    assignmentTableColumns = assignmentTableColumns;
    @track showAssignModal = false;
    @api recordId;
    @api objectApiName;
    assignTypePickOption = [];
    selectUnitPickOption =[];
    socialWorkerPickOption = [];
    responsibilityPickOption = [];
    selectLocalDepartmentPickOption =[];
    childPickOption = [];
    @track showChildList = false;
    @track assignServiceCaseRec = {};
    @track assignmentRecordList =[];
    @track showLocalDepartment = false;
    @track readOnly = false;
    @track isLoading = false;
    @track readOnlyType = false;
    @track administrative = [];
    @track family = [];
    @track child = [];
    showPreviewModal = false;
    showAssignButton = false;
    showValidateModal = false;
    connectedCallback() {
        this.doInit();
    }

    doInit(){
        this.administrative = [];
        this.family = [];
        this.child = [];
        this.isLoading = true;
        getInitiInfo({recordId: this.recordId, objectName: this.objectApiName})
        .then(res=>{
           
            let result = JSON.parse(res);
            this.assignmentRecordList = this.checkNamespaceApplicable(result.assignments, false);
            for(let i=0;i<this.assignmentRecordList.length >0;i++) {
                if(this.assignmentRecordList[i].Select_a_Social_Worker__c) {
                    this.assignmentRecordList[i].name = this.assignmentRecordList[i].Select_a_Social_Worker__r.Name;
                }
                if(this.assignmentRecordList[i].Assigned_By__c) {
                    this.assignmentRecordList[i].assignedByname = this.assignmentRecordList[i].Assigned_By__r.Name;
                }
                if(this.assignmentRecordList[i].Responsibility__c == 'Administrative') {
                    this.administrative.push(this.assignmentRecordList[i]);
                }
                if(this.assignmentRecordList[i].Responsibility__c == 'Family') {
                    this.family.push(this.assignmentRecordList[i]);
                }
                if(this.assignmentRecordList[i].Responsibility__c == 'Child') {
                    this.child.push(this.assignmentRecordList[i]);
                }
                
                
            }
            this.showAssignButton = result.hasShareAccess;
            /*if(result.recordOwner == UserNameFld) {
                    this.showAssignButton = true;
            } else {
                    this.showAssignButton = false;
            }*/
            this.assignTypePickOption = result.assignTypePicklist.splice(1);
            this.selectUnitPickOption = result.selectUnitPicklist;
            this.socialWorkerPickOption = result.socialWorkerPicklist;
            this.selectLocalDepartmentPickOption = result.selectLocalDepartmentPicklist;
            this.responsibilityPickOption = result.responsibilityPicklist.splice(1);
            this.childPickOption = result.childPicklist;
            this.assignServiceCaseRec.Assign_Type__c = 'Assign to Worker';
            this.readOnlyType = true;
            this.isLoading = false;
        }).catch(error => {
            this.isLoading=false;
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
    
    handleAssignModal(event){
    
        if(this.showAssignButton) {
            this.assignServiceCaseRec = {};
            this.readOnly = false;
            this.showAssignModal = true;
            this.doInit();
        } else {
            this.showValidateModal = true;
        }
        
    }

    closeValidateModal() {
        
        this.showValidateModal = false;
    }
    

    handleTypeChange(event) {

        this.assignServiceCaseRec.Assign_Type__c = event.target.value;
        if(event.target.value == 'Assign to Worker') {
            this.showLocalDepartment = false;
            this.readOnlyType = true;
        } else if (event.target.value == 'Assign to another UNIT') {
            this.showLocalDepartment = false;
            this.readOnlyType = false;
        } else if (event.target.value == 'Transfer to Local Department') {
            this.showLocalDepartment = true;
        }
        if (event.target.name =='Assign_Type__c' && event.target.value == 'Assign to Worker') {
            this.assignServiceCaseRec.Select_a_Unit__c = 'CPS Unit 2';
        }

    }

    handleChange(event) {
        let fieldName = event.target.name;
        let Value = event.target.value;
        let fieldType = event.target.type;
    
        if (fieldType != 'checkbox') {
            if(Value =='Child' && fieldName =='Responsibility__c') {
                this.showChildList = true;
            } else if ((Value =='Administrative' && fieldName =='Responsibility__c') || (Value =='Family' && fieldName =='Responsibility__c')) {
                this.showChildList = false;
            }
            this.assignServiceCaseRec[fieldName] = Value;
        }
    }

    handleSave(validate) {
        
        this.assignServiceCaseRec[this.objectApiName] = this.recordId;
        if (this.assignServiceCaseRec.Assign_Type__c == 'Assign to Worker') {
            this.assignServiceCaseRec.Select_a_Unit__c = 'CPS Unit 2';
        }
        if (!this.onValidate()) {
            if(validate) {
                this.isLoading=true;
                createAssignmentRecord({ assignmentJSON: JSON.stringify(this.checkNamespaceApplicable(this.assignServiceCaseRec, true)),objectName: this.objectApiName}).then(result => {
                    this.isLoading=false;
                    this.title = 'Success!';
                    this.type = 'success';
                    this.message = 'Record assigned successfully';
                    this.fireToastMsg();
                    this.showAssignModal = false;
                    this.doInit();
                }).catch(error => {
                    this.isLoading=false;
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
            } else {
                this.title = 'Warning!';
                this.type = 'warning';
                this.message = 'There is already an active Family assignment for this case. If you want to add another Family assignment, please end date the current Family assignment';
                this.fireToastMsg();
                //const event = this.onToastEvent('warning', 'Warning!', 'There is already an active Family assignment for this case. If you want to add another Family assignment, please end date the current Family assignment');
                //this.dispatchEvent(event);
            }
        
        } else {
            this.isLoading=false;
            this.title = 'Error!';
            this.type = 'error';
            this.message = 'Complete the required field(s).';
            this.fireToastMsg();
            //const event = this.onToastEvent('warning', 'Warning!', 'Complete the required field(s).');
            //this.dispatchEvent(event);
            //this.isLoading=false;
        }

    }

    closeAssignModal(event) {
        this.showAssignModal = false;
    }

    handleRowaction(event) {
        let row = event.detail.row;
        let rowaction = event.detail.action.name;
        if(rowaction == 'edit') {
            this.assignServiceCaseRec = row;
            if(this.assignServiceCaseRec.Responsibility__c =='Child') {
                this.showChildList = true;
            } else {
                this.showChildList = false;
            }
            this.readOnly = false;
            if(this.assignServiceCaseRec.Assign_Type__c == 'Assign to Worker') {
               this.readOnlyType = true;
            }
            this.showAssignModal = true;
            this.showPreviewModal = false;

        } else if (rowaction == 'preview') {
            this.assignServiceCaseRec = row;
            if(this.assignServiceCaseRec.Responsibility__c =='Child') {
                this.showChildList = true;
            } else {
                this.showChildList = false;
            }
            /*this.readOnly = true;
            this.readOnlyType = true;*/
            this.showPreviewModal = true;
            this.showAssignModal = false;
        }
    }

    closePreviewModal() {
        this.showPreviewModal = false;
    }

    handleValidation() {
        if(this.assignServiceCaseRec.Assign_Start_Date__c > this.assignServiceCaseRec.Assign_End_Date__c) {
            this.title = 'Warning!';
            this.type = 'warning';
            this.message = 'End date should be greater than start date';
            this.fireToastMsg();
        } else {
            let validate = false;
            if(this.assignServiceCaseRec.Responsibility__c == 'Family') {
                if(this.family.length == 0) {
                    validate = true;
                } else if(this.family.length > 0 && this.family[0].Id != this.assignServiceCaseRec.Id) {
                    if( this.family[0].Assign_End_Date__c && this.family[0].Assign_End_Date__c <= this.assignServiceCaseRec.Assign_Start_Date__c) {
                        validate = true;
                    }
                } else if(this.family.length == 1 && this.family[0].Id == this.assignServiceCaseRec.Id) {
                    validate = true;
                }
            }
            else if(this.assignServiceCaseRec.Responsibility__c == 'Child') {
                if(this.child.length == 0) {
                    validate = true;
                } else if(this.child.length > 0 && this.child[0].Id != this.assignServiceCaseRec.Id){
                    if( this.child[0].Assign_End_Date__c && this.child[0].Assign_End_Date__c <= this.assignServiceCaseRec.Assign_Start_Date__c) {
                        validate = true;
                    } 
                } else if(this.child.length == 1 && this.child[0].Id == this.assignServiceCaseRec.Id) {
                    validate = true;
                }
                
            } else if(this.assignServiceCaseRec.Responsibility__c == 'Administrative') {
                validate = true;
            }
            this.handleSave(validate);
        }
        
    }
}