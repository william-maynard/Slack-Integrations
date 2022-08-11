import { LightningElement, api } from 'lwc';

export default class InboundMessages extends LightningElement {
    @api msgDatetime
    @api name
    @api messagebody

    renderedCallback() {
    }
}