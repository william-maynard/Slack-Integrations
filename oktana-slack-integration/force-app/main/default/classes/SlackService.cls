public with sharing class SlackService {
    
    public static void getSlackConversationsInformationAndSave(List<String> conversationsIds, String token, String nextCursor, List<Debug_Log__c> errorLogs){ //next cursor conversationIds
    
        List<User> users = new List<User>();
        
        if(User.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.User.fields.SlackID__c.isAccessible() &&
            Schema.SObjectType.User.fields.Id.isAccessible()){
                users = [SELECT Id, SlackID__c 
                            FROM User 
                            WHERE SlackID__c != NULL 
                            WITH SECURITY_ENFORCED];         
        }
        System.debug('users');
        System.debug(users);
        Map<String, User> usersMap = new Map<String, User>();
        for(User user : users) {
            usersMap.put(user.SlackID__c, user);
        }
        System.debug('usersMap');
        System.debug(usersMap);
        List<SlackMessageObjects.SlackUser> allUsers = SlackUtils.mapSlackIdsToAllUsers(users); 
    
        List<SlackMessageObjects.FullConversation> slackConversationsToSave = SaveSlackMessageHandler.addMembersAndMessages(conversationsIds, usersMap, token);
        
        if (slackConversationsToSave.size() > 0 && !errorLogs.isEmpty()) {
            if (slackConversationsToSave[0].errorLogs == null) {
                slackConversationsToSave[0].errorLogs = errorLogs;
            } else {
                slackConversationsToSave[0].errorLogs.addAll(errorLogs);
            }   
        }
        
        SaveSlackMessageHandler.scheduleSaveConversations(slackConversationsToSave);
        //check if there's a next cursor then call saveAllSlackConversations
        
        if(nextCursor != null) {
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
}
