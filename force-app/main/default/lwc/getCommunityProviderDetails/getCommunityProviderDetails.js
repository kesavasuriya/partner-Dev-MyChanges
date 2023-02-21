import { LightningElement, api, track, wire} from 'lwc';
import Id from '@salesforce/user/Id';
import getProviderInfo from '@salesforce/apex/CommunityLoggedProviderDetail.getProviderDetails';

const columns = [
    { label: 'Provider Id', fieldName: 'MD_CHESSIE_Provider_ID__c', type: 'number',wrapText: true,
        cellAttributes: { alignment: 'left' } },
    { label: 'Name', fieldName: 'providerName', type:'url', typeAttributes: {
        label: { 
            fieldName: 'Name' 
        },
        target : '_blank'
    }},
    { label: 'First Name', fieldName: 'Individual_First_Name__c', type: 'string',wrapText: true },
    { label: 'Provider Staus', fieldName: 'Provider_Status__c', type: 'string', wrapText: true},
    { label: 'Number of Beds', fieldName: 'Number_of_Beds__c', type: 'number',  wrapText: true,
        cellAttributes: { alignment: 'left' } },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', wrapText: true,
    typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric",
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
    }
    },
    { label: 'Provider Record Type', fieldName: 'RecordType', type: 'string', wrapText: true},
];

export default class GetCommunityProviderDetails extends LightningElement {
    @api userId = Id;
    @api providerId;
    @api recordId;
    @track providerList= [];
    @track columns=columns;
    numberofProvider;
    //@wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    //objectInfo;

    connectedCallback() {
        
       
        getProviderInfo().
                then(provider =>{
                    this.providerList = JSON.parse(provider).providers;
                    if(this.providerList.length) {
                        this.numberofProvider = 'Providers ('+ this.providerList.length+')';
                        this.providerList = JSON.parse(provider).providers;
                        let baseurl = 'casevaultpartners-developer-edition.na172.force.com/casevaultCommunity/s/detail/';
                        for ( var i = 0; i < this.providerList.length; i++ ) {
                            var row = this.providerList[i];
                            row.providerName = baseurl+row.Id;
                            row.RecordType = row.RecordType.Name;
                            }
                    }
                }).catch(error => {
                })
    }
   
   

    
}