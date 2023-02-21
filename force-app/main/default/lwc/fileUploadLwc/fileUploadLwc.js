import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class FileUploadLwc extends NavigationMixin(LightningElement) {

    @api contentDocumentId;
    fileName;
    showFileLink = false;

    handleUploadFinished(event) {

        if(event.detail.files[0]) {
            let fileDetail = event.detail.files[0];
            this.contentDocumentId = fileDetail.documentId;
            this.fileName = fileDetail.name;
            this.showFileLink = true;
        }
    }

    handleFileNavigate() {

        this[NavigationMixin.Navigate]({

            type: 'standard__recordPage',
            attributes: {
                recordId: this.contentDocumentId,
                actionName: 'view'
            }
        })
    }


}