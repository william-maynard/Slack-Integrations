import { api, LightningElement, track } from 'lwc';
import getConversations from '@salesforce/apex/SlackChatController.getConversations';
import getChat from '@salesforce/apex/SlackChatController.getChat';
import Id from '@salesforce/user/Id';

export default class SlackChat extends LightningElement {
    
     @track chat;
    @api recordId
    showChat = false;
    userId = Id;

    connectedCallback(){
        this.getChat();
    }

    getChat() {
        this.showChat = false;
        
        getChat({conversationID : this.recordId})
        .then(result =>{           
            this.chat = JSON.parse(JSON.stringify(result));

            for (let i = 0; i < this.chat.messages.length; i++) {
                const element = this.chat.messages[i];

                const date = Date.parse(element.messageDateTime);
                element.messageDateTime = date;   
                if (element.messageOwner.Id === this.userId) {
                    element.isOwner = true;
                } else {
                    element.isOwner = false;                
                }  
            }
            this.showChat = true;
        })
        .catch(error =>{
            this.errorMsg = error;
        })
    }
}