public without sharing class UserSelector {
    
    public static List<User> getUsersIdWithToken(){
        List<User> userList = [SELECT Id, User_Token__c FROM User WHERE isActive = true AND SlackID__c != null AND User_Token__c != null ORDER BY Id];
        return userList;
    }
    public static List<User> getUserIdsFromSlackIds(Set<String> slackIds){
        return [SELECT Id, SlackID__c FROM User WHERE SlackID__c IN :slackIds];
    }
}
