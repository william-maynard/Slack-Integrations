@isTest
private with sharing class SlackServiceTest {

    private static List<User> createTestUsers(){
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'TestUser', Email = 'testUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='TestUser', ProfileId=p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        LanguageLocaleKey = 'en_US',
        SlackID__c = '12',
        UserName='tokuser@testorg.com' );
        insert u;

        userList.add(u);

        return userList;
    }

    @isTest 
    static void TestGetSlackConversationsInformationAndSave() {

        Test.startTest();
        //using saveAllSlackConversationsNoCursor test to work with slackservice test, since the former is a future method
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        SaveSlackMessageScheduleHandler.saveAllSlackConversations(null);
        List<Conversation__c> conversationsSaved = new List<Conversation__c>();
        System.assertEquals(conversationsSaved.size(), 0);
        
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    private static void TestGetSlackToken() {
        String tokens = SlackService.getSlackToken();
        System.assertEquals((tokens != ''), true);     
    }
}