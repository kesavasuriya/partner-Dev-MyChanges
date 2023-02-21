import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//import getPlacementRecords from '@salesforce/apex/GetProviderCommunityInfos.getPlacementRecord';
import getPlacementRecords from '@salesforce/apex/GetProviderCommunityInfos.getPlacementRecord';

const columns = [
        
    { label: 'Placement Name', fieldName: 'PlacementName', type:'url', typeAttributes: {
        label: { 
            fieldName: 'Name' 
        },
        target : '_blank'
    }},
    { label: 'Provider', fieldName: 'providerName', type: 'string',wrapText: true },
    { label: 'Child', fieldName: 'childName', type: 'string', wrapText: true},
    { label: 'Begin Date', fieldName: 'Begin_Date__c', type: 'date',  wrapText: true,typeAttributes: { day: 'numeric', month: 'numeric', year: 'numeric', timeZone: 'UTC' } }
];

export default class GetCommunityPlacement extends LightningElement {

    @track placementRecord =[];
    @api providerId;
    columns = columns;
    providerName;
    childName;
    numberofPlacement;
    PlacementName;

    connectedCallback() {
       this.getPlacements();      
    }

getPlacements(){
    getPlacementRecords({providerId: this.providerId}) 
    .then(result =>{
        let res = JSON.parse(result);
        let baseurl = 'casevaultpartners-developer-edition.na172.force.com/CasevaultCustomerPortal/s/detail/';
        this.placementRecord = res.placementList;
        this.numberofPlacement = "Placement"+"("+this.placementRecord.length+")";
        for ( var i = 0; i < this.placementRecord.length; i++ ) {         

            var row = this.placementRecord[i];
            row.PlacementName = baseurl+row.Id;
            if ( row.Provider__r.Name ) {
                row.providerName = row.Provider__r.Name;
            }
            if (row.Child__r.Name) {
                row.childName = row.Child__r.Name;
            }
        
        }
    })
}

}