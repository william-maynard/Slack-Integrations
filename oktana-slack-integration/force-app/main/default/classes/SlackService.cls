public with sharing class SlackService {
    
    public static void getSlackConversationsInformationAndSave(SlackMessageObjects.UserConversationPair user_ConversationPair, String token, String nextCursor, List<Debug_Log__c> errorLogs){ //next cursor conversationIds
    
        List<String> convIds = user_ConversationPair.conversationIds;
        List<User> tokenUser = new List<User>();
        if(User.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.User.fields.SlackID__c.isAccessible() &&
            Schema.SObjectType.User.fields.Id.isAccessible()){

                tokenUser = [SELECT Id,SlackID__c FROM User WITH SECURITY_ENFORCED];         
        }


        List<SlackMessageObjects.SlackUser> allUsers = SaveSlackMessageHandler.mapSlackIdsToAllUsers(tokenUser); 

       SlackMessageObjects.UserConversationPair conversationsPair = new  SlackMessageObjects.UserConversationPair();
        conversationsPair.conversationIds = convIds;
        conversationsPair.userToken = token;
    
        //waiting for the addMenbersAndMessages method
        List<SlackMessageObjects.FullConversation> slackConversationsToSave = SaveSlackMessageHandler.addMembersAndMessages(conversationsPair, allUsers,conversationsPair.userToken);
        if (slackConversationsToSave.size() > 0 && !errorLogs.isEmpty()) {
            if (slackConversationsToSave[0].errorLogs == null) {
                slackConversationsToSave[0].errorLogs = errorLogs;
            } else {
                slackConversationsToSave[0].errorLogs.addAll(errorLogs);
            }   
        }
    
        //Waiting for scheduleSaveConversations method
        SaveSlackMessageHandler.scheduleSaveConversations(slackConversationsToSave);
        //check if there's a next cursor then call saveAllSlackConversations
        
        //waiting for SaveSlackMessageScheduler method
        // if(nextCursor!=null){
        //     SaveSlackMessageScheduler savingScheduler = new SaveSlackMessageScheduler(nextCursor);
        //     Datetime time1 = Datetime.now().addMinutes(1);
        //     String cron1 = '' + time1.second() + ' ' + time1.minute() + ' ' + time1.hour() + ' ' + time1.day() + ' ' + time1.month() + ' ? 2022';
        //     System.schedule('Saving Slack Messages Trigger ' + time1.getTime(), cron1, savingScheduler);
        // }
    }

    public static String getSlackToken() {
        return [SELECT UserId__c, Token__c FROM Token_Custom_Metadata__mdt LIMIT 1].Token__c;
    }
}
