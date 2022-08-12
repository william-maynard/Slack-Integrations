public with sharing class SlackService {

    public static void getSlackConversationsInformationAndSave(List<SlackMessageObjects.Channel> channels, String token, String nextCursor, List<Debug_Log__c> errorLogs) {
    
        List<User> users = new List<User>();
        
        if(User.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.User.fields.SlackID__c.isAccessible() &&
            Schema.SObjectType.User.fields.Id.isAccessible()){
                users = [SELECT Id, SlackID__c 
                            FROM User 
                            WHERE SlackID__c != NULL 
                            WITH SECURITY_ENFORCED];         
        }

        Map<String, User> usersMap = new Map<String, User>();
        for(User user : users) {
            usersMap.put(user.SlackID__c, user);
        }
        List<SlackMessageObjects.SlackUser> allUsers = SlackUtils.mapSlackIdsToAllUsers(users); 
        List<SlackMessageObjects.FullConversation> slackConversationsToSave = SaveSlackMessageHandler.addMembersAndMessages(channels, usersMap, token);
        
        if (slackConversationsToSave.size() > 0 && !errorLogs.isEmpty()) {
            if (slackConversationsToSave[0].errorLogs == null) {
                slackConversationsToSave[0].errorLogs = errorLogs;
            } else {
                slackConversationsToSave[0].errorLogs.addAll(errorLogs);
            }   
        }
        
        SaveSlackMessageHandler.scheduleSaveConversations(slackConversationsToSave);
        
        if(nextCursor != null && !nextCursor.equals('')) {
            SaveSlackMessageScheduler savingScheduler = new SaveSlackMessageScheduler(nextCursor);
            Datetime dateDT = Datetime.now().addMinutes(1);
            String cron = dateDT.format('ss mm HH dd MM ? yyyy');
            System.schedule('Saving Slack Messages Trigger ' + dateDT.getTime(), cron, savingScheduler);
        }
    }

    public static String getSlackToken() {
        return [SELECT UserId__c, Token__c 
                FROM Token_Custom_Metadata__mdt 
                LIMIT 1].Token__c;
    }

    public static String getSlackBotToken() {
        return [SELECT Bot_Token__c FROM Token_Custom_Metadata__mdt LIMIT 1].Bot_Token__c;
    }
}
