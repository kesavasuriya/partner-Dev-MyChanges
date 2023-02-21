import { LightningElement, track } from 'lwc';
import getUser from '@salesforce/apex/GetProviderCommunityInfos.checkUserLogin';

export default class CommunityLoginPage extends LightningElement {
   @track providerId;
   @track userName;
   @track password;
   @track activeTab = 'home';
   showModal = true;
   @track loggedProviderId;

    connectedCallback() {
        /*getProviderRec({userId: this.userId}) 
        .then(result => {
            this.providerId = result;
        }).catch(error => {
        })*/
    }

    handleTabClick(event) {

        const tab = event.target;
        this.activeTab = `Tab ${
            event.target.value
        } is now active`;
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
                        this.showModal = false;
                        this.loggedProviderId = providerRec[0].Id;
                    } else {
                        alert('Please check your username and password.');
                    }
            }).catch(error => {
            })
        } else {
            alert('Please enter username and password.');
        }

    }

    

        
}