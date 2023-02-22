import { LightningElement,api } from 'lwc';
export default class AddressValidationLwc extends LightningElement {

    @api address1;
    @api address2;
    @api street;
    @api county;
    @api state;
    @api zipcode;
    @api city;
    @api postalcode;

    handleChange(event) {
        this.address1 = event.target.street;
        this.city =  event.target.city;
        this.street = event.target.province;
        this.county = event.target.country;
        this.state = event.target.state;
        this.postalcode = event.target.postalCode;
        this.address2 = event.target.value;
    }
}