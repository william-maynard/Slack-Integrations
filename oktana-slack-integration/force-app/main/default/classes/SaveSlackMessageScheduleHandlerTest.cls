@IsTest
public with sharing class SaveSlackMessageScheduleHandlerTest {

    @isTest
    public static void saveAllSlackConversationsNoCursor(){

        SaveSlackMessageScheduleHandler.saveAllSlackConversations(null);

        //we should change this with an actual conversation which will be saved
        List<Conversation__c> conversationsSaved = new List<Conversation__c>();
        System.assertEquals(conversationsSaved.size(), 0);

    }

    @isTest
    public static void saveAllSlackConversationsWithCursor(){
        String cursor = '=dfv37284';
        SaveSlackMessageScheduleHandler.saveAllSlackConversations(cursor);

        //we should change this with an actual conversation which will be saved
        List<Conversation__c> conversationsSaved = new List<Conversation__c>();
        System.assertEquals(conversationsSaved.size(), 0);
    }
}
