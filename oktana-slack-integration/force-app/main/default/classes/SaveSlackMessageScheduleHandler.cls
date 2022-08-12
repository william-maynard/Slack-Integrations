public with sharing class SaveSlackMessageScheduleHandler {
    public class SlackSavingMessageException extends Exception {}


    @future(callout=true)
    public static void saveAllSlackConversations(String nextCursor){

        String token = SlackService.getSlackToken();
        Integer jobLimit = 40 - Limits.getQueueableJobs();
        List<Debug_Log__c> errorLogs = new List<Debug_Log__c>();

        Debug_Log__c slackDebug1 = new Debug_Log__c();
        slackDebug1.Name = 'SaveSlackMessageScheduleHandler-saveAllSlackConversations-Line 9';
        slackDebug1.Description__c = 'The limit of conversations to fetch now is: ';
        slackDebug1.Log_Body__c = String.valueOf(jobLimit);
        errorLogs.add(slackDebug1);

        SlackMessageObjects.GetConversationsResponse conversationsResponse = SlackCalloutService.getConversations(token, nextCursor, jobLimit);
        if(!conversationsResponse.ok) {
            throw new SlackSavingMessageException('Error getting conversations. Error: ' + conversationsResponse.error);
        }

        List<SlackMessageObjects.Channel> channels = conversationsResponse.channels;
        Debug_Log__c slackDebug2 = new Debug_Log__c();
        slackDebug2.Name = 'SaveSlackMessageScheduleHandler-saveAllSlackConversations-Line 17';
        slackDebug2.Description__c = 'The amount of ' + channels.size() + ' conversations were fetched, and those are the following:';
        slackDebug2.Log_Body__c = '';//String.join(userConversationPair.conversationIds, ', ');
        errorLogs.add(slackDebug2);

        SlackService.getSlackConversationsInformationAndSave(channels, token, conversationsResponse.nextCursor, errorLogs);

    }
}
