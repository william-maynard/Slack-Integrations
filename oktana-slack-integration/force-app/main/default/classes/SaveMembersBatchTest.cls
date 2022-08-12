@isTest
private with sharing class SaveMembersBatchTest {
    
    @isTest(seeAllData=true)
    private static void testRunBatch(){

        List<SlackMessageObjects.SlackMessage> messagesList = new List<SlackMessageObjects.SlackMessage>();
        Conversation__c slackConversation = new Conversation__c(Name = 'Test Conversation', Conversation_Id__c='0D58a00008VI39SCAT', 
                                                                Slack_Conversation_Id__c='C03HBSQLV5H', Slack_Workspace_Id__c='T03HBSQKZEX',
                                                                Message_Timestamps__c = '1234452');
        insert slackConversation;

        test.startTest();
        // Get an User Id
        String userId = createStandartUser(String.valueOf(Datetime.now().millisecond())+'@mail.com');
        List<String> recipients = new List<String>{userId};
        String feedText = 'feed test';
        String commentText = 'comment test';
        // Post feed message to get feedId
		ConnectApi.FeedElement feed = ConnectAPIController.postFeedDirectMessage(null, feedText, recipients, false);
        // Fill SlackMessage List
        SlackMessageObjects.SlackMessage message = new SlackMessageObjects.SlackMessage();
        message.textMessage = 'test text1';
        message.ts = '12344521';
        message.slackUserId = 'testId1';
        messagesList.add(message);
        
        SaveSlackMessageQueueable testedClass = new SaveSlackMessageQueueable(messagesList, null, feed.Id, slackConversation);   
        system.enqueueJob(testedClass);
        //Finish Test
         SaveMembersBatch runBatch = new SaveMembersBatch(); 
         Id batchId = Database.executeBatch(runBatch);
        test.stopTest();

        Conversation__c updatedConversation = [SELECT Id, Conversation_Id__c FROM Conversation__c WHERE Id = :slackConversation.Id LIMIT 1]; 
        System.debug(updatedConversation);
        
        List<FeedItem> fe = [SELECT Id, ParentId, title, body FROM FeedItem WHERE Id =: updatedConversation.Conversation_Id__c];
        System.debug(fe);
        
        List<DirectMessageMember> dms = [SELECT MemberId FROM DirectMessageMember];
        System.debug(dms);
        
        List<FeedComment> fc = [SELECT Id, FeedItemId, ParentId, CreatedDate, CommentBody FROM FeedComment LIMIT 200];
        System.debug(fc);
    }
    
    private static String createStandartUser(String email) {
        User[] users = [SELECT Id FROM User WHERE Username = :email LIMIT 1];
        
        if (users.size() > 0) {
            return users[0].Id;
        }
       
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User user = new User(
            Alias 		 = 'testUser',
            Email 		 = email,
            LastName 	 = 'LastName',
            Username 	 = email,
            LocaleSidKey = 'en_US',
            ProfileId    = prof.Id,
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey    = 'America/Los_Angeles'
        );       
        insert user;
        
        return user.Id;
    }

}
