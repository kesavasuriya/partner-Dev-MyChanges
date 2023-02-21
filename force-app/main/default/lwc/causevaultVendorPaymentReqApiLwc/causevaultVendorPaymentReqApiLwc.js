import { LightningElement,track,api} from 'lwc';
import getpaymentinputRec from '@salesforce/apex/CaseVaultCalloutHandler.getpaymentinputdetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UtilityBaseElement from 'c/utilityBaseLwc';
//import uploadCsvFiles from '@salesforce/apex/CaseVaultCsvFileUpload.handleCsvFile';

const columns = [
    { label: 'Client Name', fieldName: 'clientID' },
    { label: 'Vendor Name', fieldName: 'vendorNo' },
    { label: 'Vendor Type', fieldName: 'vendorType' },
    { label: 'Placement ID', fieldName: 'placementID' },
    { label: 'Service Type ID', fieldName: 'serviceTypeID' },
    { label: 'Service Start Date', fieldName: 'serviceStartDate' ,type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"}},
    { label: 'Service End Date', fieldName: 'serviceEndDate',type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"} },
    { label: 'Rate Amount', fieldName: 'rateAmount',type:'number',typeAttributes: { formatStyle:"decimal",minimumFractionDigits:"2"} },
    { label: 'Rate Type', fieldName: 'rateType' },
    { label: 'Rate Start Date', fieldName: 'rateStartDate',type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"} },
    { label: 'Rate End Date', fieldName: 'rateEndDate',type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"} },
    { label: 'Changed Date', fieldName: 'changedDate',type:'date', typeAttributes:{month: "numeric",day: "numeric",year: "numeric",timeZone:"UTC"} },
];

export default class CausevaultVendorPaymentReqApiLwc extends UtilityBaseElement {

    @track paymentInputData = [];
    columns = columns;
    @api myRecordfile;
    isLoading=true;
    @track fileNames='';
    @track visibleData = [];
    showChild = false;
    @track fakeclient = [];
    @track fakeprovider = [];
    get acceptedFormats() {
        return ['.csv'];
    }
    connectedCallback(){
        this.showChild = false;

        this.fakeclient[8]='Mike';
        this.fakeclient[1]='Applicant';
        this.fakeclient[9]='John';
        this.fakeclient[10]='jack';
        this.fakeclient[4]='Dhaksha';
        this.fakeclient[11]='Amy';
        this.fakeclient[12]='Cathrin';
        this.fakeclient[2101]='David';
        this.fakeclient[7]='winter';

        this.fakeprovider[108]='Steve Smith';
        this.fakeprovider[100]='John Doe';
        this.fakeprovider[109]='John Smith';
        this.fakeprovider[110]='James Simth';
        this.fakeprovider[104]='John Doe';
        this.fakeprovider[111]='Anthony S';
        this.fakeprovider[112]='William Doe';
        this.fakeprovider[116]='John Mitchel';
        this.fakeprovider[107]='Rose';

        getpaymentinputRec()
        .then(result => {
            let res = JSON.parse(result);
            if (res.status == 'success') {
            this.isLoading=false;
            this.paymentInputData = res.data;
            for(let i=0;i<11;i++) {
                this.paymentInputData[i].clientID = this.fakeclient[this.paymentInputData[i].clientID];
                this.paymentInputData[i].vendorNo = this.fakeprovider[this.paymentInputData[i].vendorNo];
            }
            let records = this.paymentInputData;
            this.paymentInputData = records.slice(0,10);

            this.showChild = true;
            }
            else if (res.status == 'error') {
            this.paymentInputData = [];
            let errorMsg = res.error.message;
            const event = this.onToastEvent('warning', 'Warning!', errorMsg);
            this.dispatchEvent(event); 
            }
        })
        .catch(error => {

            this.isLoading=false;
            let errorMsg;
            this.title ="Error!";
            this.type ="error";
            if(error) {
                let errors = this.reduceErrors(error);
                errorMsg = errors.join('; ');
            } else {
            errorMsg = 'Unknown Error';
            }
            this.message = errorMsg;
            this.fireToastMsg();
        }) 
    }
    onToastEvent(type, toastTitle, msg) {

        const toastEvent = new ShowToastEvent({
            variant: type,
            title: toastTitle,
            message: msg,
        });
        return toastEvent;
    }
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        let uploadedFileNames = '';
        var reader = new FileReader();
        for(let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';
            reader.onload = () => {
                var base64 = reader.result.split(',')[1];
                this.fileData = {
                'filename' : file.name,
                'base64' : base64
                }
                }
                reader.readAsDataURL(file);
        }
        this.fileNames=uploadedFileNames;
    }
    handleCancel(){
        this.myRecordfile='';
        this.fileNames='';
    }
    handleFile(){
        
    }
    paginationHandler(event) {

        this.visibleData = [...event.detail.records];     
    }
}