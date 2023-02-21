import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getServiceCaseRec from '@salesforce/apex/GetProviderCommunityInfos.getPlacementRecord';

const columns = [
        
    { label: 'Service Case Name', fieldName: 'servicecaseName', type: 'url', wrapText: true,
        typeAttributes: {
        label: { 
            fieldName: 'Name' 
        },
        target : '_blank'
        } },
    { label: 'Head of Houseshold', fieldName: 'Head_of_Household__c', type: 'string',wrapText: true },
    { label: 'Intake', fieldName: 'Intake', type: 'string', wrapText: true},
    { label: 'Number of Days', fieldName: 'Number_of_days__c', type: 'number',  wrapText: true },
    { label: 'Status', fieldName: 'Status__c', type: 'string',  wrapText: true }
];

export default class GetCommunityPlacement extends LightningElement {

    @track serviceRecordList =[];
    @track totalnoServicecase;
    @api providerId;
    columns = columns;
    
    connectedCallback() {

     getServiceCaseRec({providerId: this.providerId})
    .then(result =>{
        let res = JSON.parse(result);
        this.serviceRecordList = res.ServiceCaseList;
        for ( var i = 0; i < this.serviceRecordList.length; i++ ) {
            this.totalnoServicecase = "Service Case (" + this.serviceRecordList.length + ")";
            let baseurl = 'casevaultpartners-developer-edition.na172.force.com/s/detail/';
            var row = this.serviceRecordList[i];
            row.servicecaseName = baseurl+row.Id;
            row.Intake = row.Intake__r.CaseNumber;
        }
    })

}




    handleRowAction(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: res,
                objectApiName: 'Placement__c', 
                actionName: 'view'
            }
        })
    }
}