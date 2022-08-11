import { LightningElement, track } from 'lwc';
import getConversations from '@salesforce/apex/SlackChatController.getConversations';

export default class ChatRecoveryWrapper extends LightningElement {
    @track conversations;
    @track selectedConversation;
    @track chat;
    @track errorMsg;

    nullMessageData = true;

    connectedCallback(){
        getConversations()
        .then(result => {
            this.conversations = result;
        })
        .catch(error =>{
            this.errorMsg = error;
        })
    }

    handleChange(event){
        this.selectedConversation = event.detail.value;
        this.nullMessageData = this.selectedConversation != '' ? false:true;
    }
}