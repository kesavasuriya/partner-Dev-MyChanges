import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getIntakeRecords from '@salesforce/apex/GetProviderCommunityInfos.getPlacementRecord';

const columns = [
        
    { label: 'Case Number', fieldName: 'CaseNumberurl', type: 'url', wrapText: true,
    typeAttributes: {
        label: { 
            fieldName: 'CaseNumber' 
        },
        target : '_blank'
        }
    },
    { label: 'Origin', fieldName: 'Origin', type: 'string', wrapText: true},
    { label: 'Status', fieldName: 'Status', type: 'string',  wrapText: true }
];

export default class GetCommunityPlacement extends LightningElement {

    @track intakeRecordList =[];
    @api providerId;
    columns = columns;
    totalCases ;
    connectedCallback() {

    getIntakeRecords({providerId: this.providerId})
    .then(result =>{
        let res = JSON.parse(result);
        this.intakeRecordList = res.Intakes;
        for ( var i = 0; i < this.intakeRecordList.length; i++ ) {

            var row = this.intakeRecordList[i];
            let baseurl = 'casevaultpartners-developer-edition.na172.force.com/s/detail/';
            row.CaseNumberurl = baseurl+row.Id;
            this.totalCases = "Intakes ("+this.intakeRecordList.length+ ")";
         
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