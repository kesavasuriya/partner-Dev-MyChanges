import { LightningElement, api, track, wire} from 'lwc';
import Id from '@salesforce/user/Id';
import getReferralInfo from '@salesforce/apex/GetProviderCommunityInfos.getProviderDetails';

const columns = [
    { label: 'Referral Id', fieldName: 'referralName', type:'url', typeAttributes: {
        label: { 
            fieldName: 'Name' 
        },
        target : '_blank'
    }},
    { label: 'Converted', fieldName: 'Converted__c', type: 'Checkbox',wrapText: true },
    { label: 'Referral Status', fieldName: 'Referal_status__c', type: 'String',  wrapText: true },
    { label: 'Created By', fieldName: 'createdBy', type: 'String',  wrapText: true },
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
];

export default class GetCommunityProviderDetails extends LightningElement {
    
    @api providerId;
    @track referralList= [];
    @track columns=columns;
    numberofRefferal;
    
    connectedCallback() {
        
        getReferralInfo({providerId : this.providerId}).
                then(result =>{
                    this.referralList = JSON.parse(result).referralList;
                    if(this.referralList.length) {
                        this.numberofRefferal = 'Referrals ('+ this.referralList.length+')';
                        let baseurl = 'casevaultpartners-developer-edition.na172.force.com/CasevaultCustomerPortal/s/detail/';
                        for ( var i = 0; i < this.referralList.length; i++ ) {
                            var row = this.referralList[i];
                            row.referralName = baseurl+row.Id;
                            row.createdBy = row.CreatedBy.Name;
                            }
                    }
                }).catch(error => {
                })
    }
   

}