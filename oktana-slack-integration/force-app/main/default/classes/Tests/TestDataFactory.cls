
@isTest
public without sharing class TestDataFactory {
    
    public static void updateActiveLocalUsersToInActive(){
        List<User> userList = new List<User>();
        for (User user : [SELECT Id, isActive FROM User WHERE SlackID__c != null AND User_Token__c != null]) {
            user.isActive = false;
            userList.add(user);
        }  
        Database.update(userList) ;
    }
    
    public static void insertStandardUsersWithSlackToken(Integer size){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> users = new List<User>();

        for (Integer i = 0; i < size; i++) {
            User user = new User(Alias = 'User'+i, Email = 'testUser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestUser'+i,
            ProfileId=p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            SlackID__c = 'slackid',
            UserName='Test'+i+'@test.org.dev',
            User_Token__c='xoxp-3598964873479-3615963368372-3757017684002-b6c4aae94ffc7782311012616b9db0fc-'+i,
            IsActive = true);

            users.add(user); 
        }
        insert users;
    }

    @TestVisible()
    private static void createCustomIndexSetting() {
        UserIndex__c userIndex = new userIndex__c();
        userIndex.Name = 'Index';
        userIndex.Index__c = 0;
        insert userIndex;
    }
}
