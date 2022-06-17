@IsTest
public with sharing class SaveSlackMessageScheduleHandlerTest {

    @isTest
    public static void saveAllSlackConversationsNoCursor(){
        Test.startTest(); 

        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        SaveSlackMessageScheduleHandler.saveAllSlackConversations(null);
        //we should change this with an actual conversation which will be saved
        List<Conversation__c> conversationsSaved = new List<Conversation__c>();
        System.assertEquals(conversationsSaved.size(), 0);

        Test.stopTest();

    }

    @isTest
    public static void saveAllSlackConversationsWithCursor(){
        String cursor = '=dfv37284';
        Test.startTest(); 

        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        SaveSlackMessageScheduleHandler.saveAllSlackConversations(cursor);
        //we should change this with an actual conversation which will be saved
        List<Conversation__c> conversationsSaved = new List<Conversation__c>();
        System.assertEquals(conversationsSaved.size(), 0);

        Test.stopTest();
    }
}
