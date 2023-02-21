import { LightningElement, track, api} from 'lwc';
import getProviderFiles from '@salesforce/apex/GetProviderCommunityInfos.getProviderFiles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
const columns = [{ label: 'Title', fieldName: 'Title', wrapText : true,},
                
                { label: 'Download', type:  'button', typeAttributes: { 
                    label: 'Download',  name: 'Download',  variant: 'label-hidden',
                    iconName: 'utility:download'} }
                ];

export default class CommunityFileUpload extends NavigationMixin(LightningElement) {

    @api providerId;
    @track columnsList = columns;
    @track dataList = [];
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpeg'];
    }

    connectedCallback() {

        this.doInit();
       
    }

    doInit() {
            
            getProviderFiles({providerId:this.providerId})
            .then(result => {
                let res = JSON.parse(result);
                if(res != null) {
                    this.dataList = res;
                } 
            }).catch(error => {
            })        
    }

    handleRowAction(event){

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'Preview':
                this.previewFile(row);
                break;
            case 'Download':
                this.downloadFile(row);
                break;
        }

    }

    downloadFile(row) {

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://casevaultpartners-developer-edition.na172.force.com/CasevaultCustomerPortal/sfc/servlet.shepherd/document/download/'+row.ContentDocumentId
            }
        }, false 
    );
    }


    handleUploadFinished(event) {
       
        const evt = new ShowToastEvent({
            title : 'Success',
            message : 'Files uploaded Successfully',
            variant : 'success',
            mode : 'dismissable'
        });
        this.dispatchEvent(evt);
        this.doInit();
       
    }

}