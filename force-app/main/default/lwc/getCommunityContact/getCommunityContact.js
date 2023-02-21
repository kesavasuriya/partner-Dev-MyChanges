import { LightningElement, track, api } from 'lwc';
import getContactRec from '@salesforce/apex/GetProviderCommunityInfos.getPlacementRecord';
import getplacementContacts from '@salesforce/apex/CommunityLoggedProviderDetail.getProviderPlacement';
const columns = [
    { label: 'Name', fieldName: 'childNameurl', type: 'text', sortable: true, cellAttributes: { alignment: 'left' },
    type:'url', typeAttributes: {
        label: { 
            fieldName: 'childName' 
        },
        target : '_blank'
    }},
    { label: 'Date Of Birth', fieldName: 'dob', type: 'date', sortable: true },
    { label: 'Program Area', fieldName: 'programArea', type: 'text', sortable: true, cellAttributes: { alignment: 'left' } },
    { label: 'Person Role', fieldName: 'personRole', type: 'text', sortable: true },
];


export default class GetCommunityContact extends LightningElement {
    @track contacts;
    @track childContacts = [];
    @track placementRecord;
    @api providerId;
    childName;
    dob;
    programArea;
    personRole;
    totalNoofContacts;
    childNameurl;
    @track columns = columns;
    @track childcolumns = [{ label: 'Id', fieldName: 'Id', type: 'text', sortable: true, cellAttributes: { alignment: 'left' } },
    { label: 'Name', fieldName: 'Name', type: 'text', sortable: true }];

    connectedCallback() {
    
        getplacementContacts() 
        .then(result => {
            this.contacts = JSON.parse(result).contactList;
            console.log(JSON.parse(result).contactList);
            this.totalNoofContacts = 'Contacts ('+this.contacts.length+')';
            let baseurl = 'casevaultpartners-developer-edition.na172.force.com/casevaultCommunity/s/detail/';

            for ( var i = 0; i < this.contacts.length; i++ ) {
            
                var row = this.contacts[i];
                row.childNameurl = baseurl+row.Id;
                if ( row.Date_of_Birth__c) {
                    row.dob = row.Date_of_Birth__c;
                }
                if (row.Name) {
                    row.childName = row.Name;
                }
                if ( row.Program_Area__c) {
                    row.programArea = row.Program_Area__c;
                }
                if ( row.Intake_Person_Role__c) {
                    row.personRole = row.Intake_Person_Role__c;
                }
               // this.contacts = [...this.contacts];
            }
        }).catch(error => {
        })
    }
}