import { api, LightningElement } from 'lwc';

export default class OutboundMessages extends LightningElement {
    @api msgDatetime
    @api name
    @api messagebody

    renderedCallback() {
    }
}