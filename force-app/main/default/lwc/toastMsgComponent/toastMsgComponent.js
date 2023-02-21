import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ToastMsgComponent extends LightningElement {

    onToastEvent(type, toastTitle, msg) {

        const toastEvent = new ShowToastEvent({
            variant: type,
            title: toastTitle,
            message: msg,
        });
        return toastEvent;
    }

}