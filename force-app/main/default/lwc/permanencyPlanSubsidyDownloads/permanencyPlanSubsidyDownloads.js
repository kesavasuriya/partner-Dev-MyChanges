import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import downloadfile from '@salesforce/apex/AdoptionCaseController.downloadFile';

export default class PermanencyPlanSubsidyDownloads extends NavigationMixin(LightningElement) {

    @track fileRec = {};
    @track urldownload;

    handleDownload(event) {

        let title = event.target.name
        downloadfile({fileName:title})
        .then(result => {
            this.fileRec = result;
            this.urldownload = `/sfc/servlet.shepherd/document/download/${this.fileRec.Id}`
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.urldownload
                }
            });
        })
    }
}