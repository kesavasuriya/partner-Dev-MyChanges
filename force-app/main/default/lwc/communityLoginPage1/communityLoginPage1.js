import { LightningElement, track } from 'lwc';
import getUser from '@salesforce/apex/GetProviderCommunityInfos.checkUserLogin';
import { NavigationMixin } from 'lightning/navigation';

export default class CommunityLoginPage1 extends NavigationMixin(LightningElement) {
   @track providerId;
   @track userName;
   @track password;
   @track loggedProviderId;

    connectedCallback() {
        /*getProviderRec({userId: this.userId}) 
        .then(result => {
            this.providerId = result;
        }).catch(error => {
        })*/
    }

    

    handleUserChange(event) {
        let Value = event.target.value;
        this.userName = Value;
    }

    handlePasswordChange(event) {
        let Value = event.target.value;
        this.password = Value;
    }

    handleClick(event) {

        if (this.userName && this.password) {
       
            getUser({providerId: this.userName, taxId: this.password })
            .then(res => {
                    let providerRec = JSON.parse(res);
        
                    if(providerRec.length) {
                        this.loggedProviderId = providerRec[0].Id;
                        this[NavigationMixin.Navigate]({
                            type: 'standard__webPage',
                            attributes: {
                                url: 'https://casevaultpartners-developer-edition.na172.force.com/CaseVaultPortal/s/providerpage'
                            }
                        },
                        true 
                      );
                    } else {
                        alert('Please check your username and password.');
                    }
            }).catch(error => {
                console.log(error);
            })
        } else {
            alert('Please enter username and password.');
        }

    }
        
}