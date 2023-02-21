import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ToastMsgLwc extends LightningElement {

    @api title;
    @api message;
    @api type;
    @api mode;

    connectedCallback() {

        const toastEvent = new ShowToastEvent({
            variant: this.type,
            title: this.title,
            message: this.message,
            mode: this.mode
        });
        this.dispatchEvent(toastEvent);
        const toastDetail = new CustomEvent('toastcustomevent', {detail : false});
        this.dispatchEvent(toastDetail);
    }

}