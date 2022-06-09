@isTest
private class SlackUtilsTest {
    @isTest
    static void getNewMessageTimestampFieldNormalTest(){
        Test.startTest();

        String oldTimestamp = '';

        for(Integer i = 0; i<728; i++){
            oldTimestamp += '1652972910.113759,';
        }
        oldTimestamp += '1652972910.113759';

        String newTimestamp = '1652972910.113759';
        String resultingTimestamp = SlackUtils.getNewMessageTimestampField(oldTimestamp, newTimestamp);
       
        Test.stopTest();

        System.AssertEquals(resultingTimestamp.length(), 13139);
    }

    @isTest
    static void getNewMessageTimestampFieldLimitTest(){
        Test.startTest();

        String oldTimestamp = '';

        for(Integer i = 0; i<7280; i++){
            oldTimestamp += '1652972910.113759,';
        }
        oldTimestamp += '1652972910.113759';

        String newTimestamp = '1652972910.113759';
        String resultingTimestamp = SlackUtils.getNewMessageTimestampField(oldTimestamp, newTimestamp);
       
        Test.stopTest();

        System.AssertEquals(resultingTimestamp.length(), 35999);
    }

    @isTest
    static void mapSlackIdsToAllUsersWorkspaceExistsTest(){
        SlackWorkspace__c wspaceToInsert = new SlackWorkspace__c();
        wspaceToInsert.Name = 'CurrentWorkspace';
        wspaceToInsert.SlackWorkspaceId__c = 'T039RHVRJTZ';
        wspaceToInsert.SlackWorkspaceLabel__c = 'OktanaDemo';
        insert wspaceToInsert;

        List<User> userList = createTestUsers();
        Test.startTest();
        List<SlackMessageObjects.SlackUser> slackUserList = SlackUtils.mapSlackIdsToAllUsers(userList);
        Test.stopTest();
        System.AssertEquals(slackUserList.size(), 1);
    }

    @isTest
    static void mapSlackIdsToAllUsersWorkspaceDoesNotExistTest(){
        SlackWorkspace__c wspaceToInsert = new SlackWorkspace__c();
        wspaceToInsert.Name = 'CurrentWorkspace';
        wspaceToInsert.SlackWorkspaceId__c = 'T039RHVRJTZ';
        wspaceToInsert.SlackWorkspaceLabel__c = 'OktanaDemo1';
        insert wspaceToInsert;

        List<User> userList = createTestUsers();
        Test.startTest();
        List<SlackMessageObjects.SlackUser> slackUserList = SlackUtils.mapSlackIdsToAllUsers(userList);
        Test.stopTest();
        System.AssertEquals(slackUserList.size(), 0);
    }

    @isTest
    static void getSalesforceIdTest(){
        SlackMessageObjects.SlackUser slackUser = new SlackMessageObjects.SlackUser();
        slackUser.slackUserId = 'slackuserid';
        slackUser.salesforceUserId = 'salesforceuserid';

        List<SlackMessageObjects.SlackUser> listSlackUsers = new List<SlackMessageObjects.SlackUser>();
        listSlackUsers.add(slackUser);
        Test.startTest();
        String result = SlackUtils.getSalesforceId('slackuserid', listSlackUsers);
        Test.stopTest();
        System.AssertEquals('salesforceuserid', result);
    }

    @isTest
    static void findSlackConversationConversationExistsTest(){

        Conversation__c conversation = new Conversation__c();
        conversation.Slack_Conversation_Id__c = 'slackid';
        insert conversation;

        List<Conversation__c> listConversation = new List<Conversation__c>();
        listConversation.add(conversation);
        Test.startTest();
        Conversation__c result = SlackUtils.findSlackConversation(listConversation, 'slackid');
        Test.stopTest();
        System.AssertEquals(conversation.Id, result.Id);
    }

    @isTest
    static void findSlackConversationConversationDoesNotExistTest(){

        Conversation__c conversation = new Conversation__c();
        conversation.Slack_Conversation_Id__c = 'slackid';
        insert conversation;

        List<Conversation__c> listConversation = new List<Conversation__c>();
        listConversation.add(conversation);
        Test.startTest();
        Conversation__c result = SlackUtils.findSlackConversation(listConversation, 'slackid1');
        Test.stopTest();
        System.AssertEquals(null, result);
    }

    @isTest
    static void copySlackMessagesListTest(){

        List<SlackMessageObjects.SlackMessage> smList = createTestSlackMessages();
        Test.startTest();
        List<SlackMessageObjects.SlackMessage> result = SlackUtils.copySlackMessagesList(smList, 0, 10);
        Test.stopTest();
        System.AssertEquals(result.size(), 10);

        for(Integer i = 0; i<10; i++){
            System.AssertEquals(result[i].textMessage, String.valueOf(result.size()-1-i));
        }
    }

    private static List<SlackMessageObjects.SlackMessage> createTestSlackMessages(){
        List<SlackMessageObjects.SlackMessage> smList = new List<SlackMessageObjects.SlackMessage>();
        for(Integer i = 0; i<10; i++){
            SlackMessageObjects.SlackMessage sm = new SlackMessageObjects.SlackMessage();
            sm.textMessage = String.valueOf(i);
            smList.add(sm);
        }
        return smList;
    }


    private static List<User> createTestUsers(){
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'TestUser', Email = 'testUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='TestUser', ProfileId=p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        SlackID__c='slackid',
        LanguageLocaleKey = 'en_US',
        UserName='tokuser@testorg.com');
        insert u;

        userList.add(u);

        return userList;
    }

}
