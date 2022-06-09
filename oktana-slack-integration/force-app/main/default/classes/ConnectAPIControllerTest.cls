@isTest
public with sharing class ConnectAPIControllerTest {

    private static final String USER_EMAIL = 'standarUser@testorg.com';

    @isTest(seeAllData=true)
    private static void postFeedDirectMessageTest() {
        Test.startTest();
        String userId = createStandartUser();

        List<String> recipients = new List<String>{userId};
		String feedText = 'feed test';
        String commentText = 'comment test';
        // post feed message
		ConnectApi.FeedElement feed = ConnectAPIController.postFeedDirectMessage(null, feedText, recipients, false);
		System.assert(feed.Id != null);
        // update feed message
        ConnectApi.Comment comment = ConnectAPIController.updateFeedDirectMessage(null, feed.Id, commentText);
        System.assert(comment.Id != null);
        Test.stopTest();
        // check body content
        System.assertEquals(feedText, feed.body.text);
		System.assertEquals(commentText, comment.body.text);
    }
    
    @isTest(seeAllData=true)
    private static void postFeedDirectMessageWithChangeOwnerCrossOrgTest() {
        Test.startTest();
       	String userId = createStandartUser();

        List<String> recipients = new List<String>{userId};
            
		String feedText = 'feed test change owner';
        String commentText = 'comment test change owner';
		// post feed message
        ConnectApi.FeedElement feed = ConnectAPIController.postFeedDirectMessage(null, feedText, recipients, true);
		System.assert(feed.Id != null);
        // update feed message
        ConnectApi.Comment comment = ConnectAPIController.updateFeedDirectMessage(null, feed.Id, commentText);
        System.assert(comment.Id != null);
        Test.stopTest();
        // check body content
        System.assertEquals(feedText, feed.body.text);
		System.assertEquals(commentText, comment.body.text);
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
}