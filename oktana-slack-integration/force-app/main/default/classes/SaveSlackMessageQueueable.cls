public with sharing class SaveSlackMessageQueueable implements Queueable {
    private List<SlackMessageObjects.SlackMessage> messagesList;
    private String communityID;
    private String feedItemID;
    private Conversation__c slackConversation;

    public SaveSlackMessageQueueable(List<SlackMessageObjects.SlackMessage> messagesList, String communityID, String feedItemID, Conversation__c slackConversation) {
        this.messagesList = messagesList;
        this.communityID = communityID;
        this.feedItemID = feedItemID;
        this.slackConversation = slackConversation;
    }
    
    public void execute(QueueableContext context){
        
        Debug_Log__c newLog = new Debug_Log__c();
        newLog.Name = 'SaveSlackMessageQueueable-execute-Line 18';
        newLog.Description__c = 'Trying to save messages of conversation';
        newLog.Log_Body__c = slackConversation.Slack_Conversation_Id__c;
        insert newLog;
        

        for( Integer i = 0; i < this.messagesList.size(); i++ ){

            if( isNewTimestamp(this.messagesList[i].ts) ){
                ConnectAPIController.updateFeedDirectMessage(this.communityID, this.feedItemID, this.messagesList[i].textMessage);
                slackConversation.Message_Timestamps__c = SlackUtils.getNewMessageTimestampField(slackConversation.Message_timestamps__c, this.messagesList[i].ts);
            }else if( isEditedAndNewTimestamp(this.messagesList[i]) ){
                ConnectAPIController.updateFeedDirectMessage(this.communityID, this.feedItemID, this.messagesList[i].textMessage);
                slackConversation.Message_Timestamps__c = SlackUtils.getNewMessageTimestampField(slackConversation.Message_timestamps__c, this.messagesList[i].editedTs);
            }
        }
        update slackConversation;

    }

    private Boolean isNewTimestamp(String timestamp) {
        return !slackConversation.Message_timestamps__c.contains(timestamp);
    }
    private Boolean isEditedAndNewTimestamp(SlackMessageObjects.SlackMessage slackMessage) {
        return slackMessage.isEdited != null && slackMessage.editedTs != null && isNewTimestamp(slackMessage.editedTs);
    }

}
