@isTest
public with sharing class SaveSlackMessageQueueableTest {

    private static final String USER_EMAIL = 'standarUser@testorg.com';

    @isTest(seeAllData=true)
    static void testingNewMessage() {        
        List<SlackMessageObjects.SlackMessage> messagesList = new List<SlackMessageObjects.SlackMessage>();
        Conversation__c slackConversation = new Conversation__c(Name = 'Test Conversation', Message_Timestamps__c = '1659991358');
        insert slackConversation;

        Test.startTest();
        // Get an User Id
        String userId = createStandartUser();
        List<String> recipients = new List<String>{userId};
        String feedText = 'feed test';
        String commentText = 'comment test';
        // Post feed message to get feedId
		ConnectApi.FeedElement feed = ConnectAPIController.postFeedDirectMessage(null, feedText, recipients, false);
        // Fill SlackMessage List
        SlackMessageObjects.SlackMessage message = new SlackMessageObjects.SlackMessage();
        message.textMessage = 'test msg 1';
        message.ts = '1659991360';
        message.slackUserId = 'testId1';
        messagesList.add(message);

        SaveSlackMessageQueueable testedClass = new SaveSlackMessageQueueable(messagesList, null, feed.Id, slackConversation);   
        System.enqueueJob(testedClass);
        Test.stopTest();

        String expected = '1659991358,1659991360';
        Conversation__c updatedConversation = [SELECT Id, Message_Timestamps__c FROM Conversation__c WHERE Id = :slackConversation.Id LIMIT 1]; 
        System.assertEquals(expected, updatedConversation.Message_Timestamps__c);
    }
    @isTest(seeAllData=true)
    static void testingNewEdittedMessage() {        
        List<SlackMessageObjects.SlackMessage> messagesList = new List<SlackMessageObjects.SlackMessage>();
        Conversation__c slackConversation = new Conversation__c(Name = 'Test Conversation', Message_Timestamps__c = '1659991358');
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
        message.ts = '1659991360';
        message.isEdited = false;
        message.editedTs = '';
        message.slackUserId = 'testId2';
        messagesList.add(message);

        SaveSlackMessageQueueable testedClass = new SaveSlackMessageQueueable(messagesList, null, feed.Id, slackConversation);   
        system.enqueueJob(testedClass);

        test.stopTest();
        String expected = '1659991358,1659991360';
        Conversation__c updatedConversation = [SELECT Id, Message_Timestamps__c FROM Conversation__c WHERE Id = :slackConversation.Id LIMIT 1]; 
        System.assertEquals(expected, updatedConversation.Message_Timestamps__c);
    }
    @isTest(seeAllData=true)
    static void testingAll() {        
        Conversation__c slackConversation = new Conversation__c(Name = 'Test Conversation', Message_Timestamps__c = '1659991360');
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

        System.assertEquals('1659991360,1659991361,1659991362,1659991363', updatedConversation.Message_Timestamps__c);
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
        List<SlackMessageObjects.SlackMessage> messages = new List<SlackMessageObjects.SlackMessage>();
        for(Integer i = 1; i <= 3; i++) {
            SlackMessageObjects.SlackMessage message= new SlackMessageObjects.SlackMessage();
            message.textMessage = 'test text ' + i;
            message.ts = '165999136' + i;
            message.slackUserId = 'testId' + i;
            messages.add(message);
        }

        return messages;
    }
}
