public with sharing class SaveSlackMessageScheduleHandler {


    public static void saveAllSlackConversations(String nextCursor){

        String token = SlackService.getSlackToken();
        Integer jobLimit = 40 - Limits.getQueueableJobs();

        List<Debug_Log__c> errorLogs = new List<Debug_Log__c>();

        Debug_Log__c slackDebug1 = new Debug_Log__c();
        slackDebug1.Name = 'SaveSlackMessageScheduleHandler-saveAllSlackConversations-Line 9';
        slackDebug1.Description__c = 'The limit of conversations to fetch now is: ';
        slackDebug1.Log_Body__c = String.valueOf(jobLimit);
        errorLogs.add(slackDebug1);

        //SlackMessageObjects.UserConversationPair userConversationPair = SlackCalloutService.getsConversationIds(token, nextCursor, jobLimit);

        //Mocked data for when the callouts class is ready
        SlackMessageObjects.UserConversationPair userConversationPair = new SlackMessageObjects.UserConversationPair();
        userConversationPair.conversationIds = new List<String>();
        userConversationPair.conversationIds.add('C128745');
        userConversationPair.conversationIds.add('C1854768');
        userConversationPair.conversationIds.add('C856739');
        userConversationPair.userToken = token;

        Debug_Log__c slackDebug2 = new Debug_Log__c();
        slackDebug2.Name = 'SaveSlackMessageScheduleHandler-saveAllSlackConversations-Line 17';
        slackDebug2.Description__c = 'The amount of ' + userConversationPair.conversationIds.size() + ' conversations were fetched, and those are the following:';

        slackDebug2.Log_Body__c = '';
        
        for(String conversationID : userConversationPair.conversationIds){
            slackDebug2.Log_Body__c =  slackDebug2.Log_Body__c + conversationID + ', ';
        }
        errorLogs.add(slackDebug2);

        SlackService.getSlackConversationsInformationAndSave(userConversationPair, token, userConversationPair.nextCursor, errorLogs);

    }
}
