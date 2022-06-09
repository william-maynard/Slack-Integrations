@isTest
public with sharing class SaveSlackMessageQueueableTest {

    private static final String USER_EMAIL = 'standarUser@testorg.com';

    @isTest(seeAllData=true)
    static void testingNewMessage() {        
        List<SlackMessageObjects.SlackMessage> messagesList = new List<SlackMessageObjects.SlackMessage>();
        Conversation__c slackConversation = new Conversation__c(Name = 'Test Conversation', Message_Timestamps__c = 'oldts');
        insert slackConversation;

        test.startTest();
        // Get an User Id
        String userId = createStandartUser();
        List<String> recipients = new List<String>{userId};
        String feedText = 'feed test';
        String commentText = 'comment test';
        // Post feed message to get feedId
		ConnectApi.FeedElement feed = ConnectAPIController.postFeedDirectMessage(null, feedText, recipients, false);
        // Fill SlackMessage List
        SlackMessageObjects.SlackMessage message = new SlackMessageObjects.SlackMessage();
        message.textMessage = 'test text1';
        message.ts = 'nmts1';
        message.slackUserId = 'testId1';
        messagesList.add(message);

        SaveSlackMessageQueueable testedClass = new SaveSlackMessageQueueable(messagesList, null, feed.Id, slackConversation);   
        system.enqueueJob(testedClass);
        //Finish Test
        test.stopTest();

        Conversation__c updatedConversation = [SELECT Id, Message_Timestamps__c FROM Conversation__c WHERE Id = :slackConversation.Id LIMIT 1]; 
        System.assertEquals('oldts,nmts1', updatedConversation.Message_Timestamps__c);
    }
    @isTest(seeAllData=true)
    static void testingNewEdittedMessage() {        
        List<SlackMessageObjects.SlackMessage> messagesList = new List<SlackMessageObjects.SlackMessage>();
        Conversation__c slackConversation = new Conversation__c(Name = 'Test Conversation', Message_Timestamps__c = 'oldts');
        insert slackConversation;

        test.startTest();
        // Get an User Id
        String userId = createStandartUser();
        List<String> recipients = new List<String>{userId};
        String feedText = 'feed test';
        String commentText = 'comment test';
        // post feed message to get feedId
		ConnectApi.FeedElement feed = ConnectAPIController.postFeedDirectMessage(null, feedText, recipients, false);
        // Fill SlackMessage List
        SlackMessageObjects.SlackMessage message = new SlackMessageObjects.SlackMessage();
        message.textMessage = 'test text2';
        message.ts = 'emts2';
        message.isEdited = false;
        message.editedTs = '';
        message.slackUserId = 'testId2';
        messagesList.add(message);

        SaveSlackMessageQueueable testedClass = new SaveSlackMessageQueueable(messagesList, null, feed.Id, slackConversation);   
        system.enqueueJob(testedClass);

        test.stopTest();

        Conversation__c updatedConversation = [SELECT Id, Message_Timestamps__c FROM Conversation__c WHERE Id = :slackConversation.Id LIMIT 1]; 
        System.assertEquals('oldts,emts2', updatedConversation.Message_Timestamps__c);
    }
    @isTest(seeAllData=true)
    static void testingAll() {        
        Conversation__c slackConversation = new Conversation__c(Name = 'Test Conversation', Message_Timestamps__c = 'oldts');
        insert slackConversation;

        test.startTest();
        // Get an User Id
        String userId = createStandartUser();
        List<String> recipients = new List<String>{userId};
        String feedText = 'feed test';
        String commentText = 'comment test';
        // post feed message to get feedId
		ConnectApi.FeedElement feed = ConnectAPIController.postFeedDirectMessage(null, feedText, recipients, false);
        // Fill SlackMessage List
        List<SlackMessageObjects.SlackMessage> messagesList = generateMessagesList();
        
        SaveSlackMessageQueueable testedClass = new SaveSlackMessageQueueable(messagesList, null, feed.Id, slackConversation);   
        system.enqueueJob(testedClass);

        test.stopTest();

        Conversation__c updatedConversation = [SELECT Id, Message_Timestamps__c FROM Conversation__c WHERE Id = :slackConversation.Id LIMIT 1]; 

        //System.assertEquals('oldts,nmts1,emts2', updatedConversation.Message_Timestamps__c);
        //System.assertEquals('oldts,nmts1,emts2,emts3', updatedConversation.Message_Timestamps__c);
        System.assertEquals('oldts,nmts1,emts2,emts4', updatedConversation.Message_Timestamps__c);
    }
    private static String createStandartUser() {
        User[] users = [SELECT Id FROM User WHERE Username = :USER_EMAIL LIMIT 1];
        
        if (users.size() > 0) {
            return users[0].Id;
        }
       
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User user = new User(
            Alias 		 = 'testUser',
            Email 		 = USER_EMAIL,
            LastName 	 = 'LastName',
            Username 	 = USER_EMAIL,
            LocaleSidKey = 'en_US',
            ProfileId    = prof.Id,
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey    = 'America/Los_Angeles'
        );       
        insert user;
        
        return user.Id;
    }
    private static List<SlackMessageObjects.SlackMessage> generateMessagesList() {
        List<SlackMessageObjects.SlackMessage> messagesList = new List<SlackMessageObjects.SlackMessage>();

        SlackMessageObjects.SlackMessage message1= new SlackMessageObjects.SlackMessage();
        message1.textMessage = 'test text1';
        message1.ts = 'nmts1';
        message1.slackUserId = 'testId1';
        messagesList.add(message1);
        SlackMessageObjects.SlackMessage message2 = new SlackMessageObjects.SlackMessage();
        message2.textMessage = 'test text2';
        message2.ts = 'oldts';
        message2.isEdited = false;
        message2.editedTs = 'emts2';
        message2.slackUserId = 'testId2';
        messagesList.add(message2);
        SlackMessageObjects.SlackMessage message3 = new SlackMessageObjects.SlackMessage();
        message3.textMessage = 'test text3';
        message3.ts = 'oldts';
        message3.isEdited = true;
        message3.editedTs = 'emts2';
        message3.slackUserId = 'testId3';
        messagesList.add(message3);
        SlackMessageObjects.SlackMessage message4 = new SlackMessageObjects.SlackMessage();
        message4.textMessage = 'test text4';
        message4.ts = 'oldts';
        message4.isEdited = true;
        message4.editedTs = 'emts4';
        message4.slackUserId = 'testId4';
        messagesList.add(message4);

        return messagesList;
    }
}
