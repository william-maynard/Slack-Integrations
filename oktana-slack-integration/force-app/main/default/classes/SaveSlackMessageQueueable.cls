public with sharing class SaveSlackMessageQueueable implements Queueable {
    private List<SlackMessageObjects.SlackMessage> messages;
    private String communityID;
    private String feedItemID;
    private Conversation__c slackConversation;

    public SaveSlackMessageQueueable(List<SlackMessageObjects.SlackMessage> messages, String communityID, String feedItemID, Conversation__c slackConversation) {
        this.messages = messages;
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
        
        String msgText = '';
        String msgUser = '';
        String msgDateTime = '';
        for(SlackMessageObjects.SlackMessage message : this.messages){
            msgDateTime = getMessageDateTime(message.ts);
            msgUser = getMessageUser(message.salesforceUserId);
            msgText = msgUser + ' ' + msgDateTime + ' ' + message.textMessage;
            if( isNewTimestamp(message.ts) ){
                ConnectAPIController.updateFeedDirectMessage(this.communityID, this.feedItemID, msgText);
                slackConversation.Message_Timestamps__c = SlackUtils.getNewMessageTimestampField(slackConversation.Message_timestamps__c, message.ts);
            }else if( isEditedAndNewTimestamp(message) ){
                ConnectAPIController.updateFeedDirectMessage(this.communityID, this.feedItemID, msgText);
                slackConversation.Message_Timestamps__c = SlackUtils.getNewMessageTimestampField(slackConversation.Message_timestamps__c, message.editedTs);
            }
        }
        update slackConversation;

    }
    private String getMessageUser(String sfUserId) {
        return (sfUserId == null ? '@unknown' : '@' + sfUserId);
    }

    private String getMessageDateTime(String tsString) {
        Long tsLong = Long.valueOf(tsString.substringBefore('.')) * 1000L;
        return String.valueOf(Datetime.newInstance(tsLong));
    }

    private Boolean isNewTimestamp(String timestamp) {
        return !slackConversation.Message_timestamps__c.contains(timestamp);
    }
    private Boolean isEditedAndNewTimestamp(SlackMessageObjects.SlackMessage slackMessage) {
        return slackMessage.isEdited != null && slackMessage.editedTs != null && isNewTimestamp(slackMessage.editedTs);
    }

}
