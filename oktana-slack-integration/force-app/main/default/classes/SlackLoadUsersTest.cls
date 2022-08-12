@isTest
public with sharing class SlackLoadUsersTest {

    private static final String USER_EMAIL = 'standaruser@testorg.com';

    private static List<User> createStandardUser(Integer amount) {
        
        List<User> usersToInsert = new List<User>();
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

        for(Integer i = 0; i < amount; i++){

            Long timeNow = Datetime.now().getTime();
            
            User user = new User(
                Alias 		 = 'testUser',
                Email 		 = USER_EMAIL,
                LastName 	 = 'LastName',
                Username 	 = USER_EMAIL + timeNow,
                LocaleSidKey = 'en_US',
                ProfileId    = prof.Id,
                EmailEncodingKey  = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey    = 'America/Los_Angeles'
            );  
            usersToInsert.add(user);
        }
             
        insert usersToInsert;
        
        return usersToInsert;
    }

    private static List<SlackMessageObjects.SlackUser> generateSlackUsers(){

        List<SlackMessageObjects.SlackUser> users = new List<SlackMessageObjects.SlackUser>();

        SlackMessageObjects.SlackUser user1 = new SlackMessageObjects.SlackUser();
        user1.slackUserId = 'U1234';
        user1.salesforceUserId = '';
        user1.email = USER_EMAIL;

        SlackMessageObjects.SlackUser user2 = new SlackMessageObjects.SlackUser();
        user2.slackUserId = 'U5678';
        user2.salesforceUserId = '';
        user2.email = USER_EMAIL;

        SlackMessageObjects.SlackUser user3 = new SlackMessageObjects.SlackUser();
        user3.slackUserId = 'U9101';
        user3.salesforceUserId = '';
        user3.email = USER_EMAIL;

        users.add(user1);
        users.add(user2);
        users.add(user3);

        return users;

    }

    @isTest(SeeAllData = true)
    public static void testGetWorkspaceId(){

        Test.startTest();
        String workspaceId = SlackLoadUsers.getWorkspaceId();
        Test.stopTest();
        
        System.assertEquals((workspaceId != ''), true); 

    }

    @isTest(SeeAllData = true)
    public static void testLoadSlackUsers(){

        Test.setMock(HttpCalloutMock.class, new SlackLoadUsersMockHttp()); 
        Test.startTest();
        createStandardUser(1);
        SlackLoadUsers.loadSlackUsers();
        Test.stopTest();

        List<User> users  = [SELECT Id, email,SlackID__c FROM User WHERE email = :USER_EMAIL];
        System.assertEquals(users.get(0).SlackID__c, 'U1234');
    }


}
