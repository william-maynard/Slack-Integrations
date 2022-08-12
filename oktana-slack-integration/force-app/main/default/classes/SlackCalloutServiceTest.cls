@isTest
public with sharing class SlackCalloutServiceTest {

    static final Integer CONVERSATION_PAIR_LIMIT_SIZE = 40;
    static final Integer CONVERSATION_PAIR_LIST_SIZE = 40;

    @isTest 
    static void getConversationsSucessTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        SlackMessageObjects.GetConversationsResponse conversations = SlackCalloutService.getConversations('token', 'nextcursor', CONVERSATION_PAIR_LIMIT_SIZE);
        Test.stopTest();
        System.assert(conversations.ok);
        System.assertEquals(CONVERSATION_PAIR_LIST_SIZE, conversations.channels.size(), 
            'Expected conversations size is: ' + CONVERSATION_PAIR_LIST_SIZE + '. Actual: ' + conversations.channels.size());
    }

    @isTest 
    static void getConversationsErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock('error_mock'));
        SlackMessageObjects.GetConversationsResponse conversations = SlackCalloutService.getConversations('error_mock', 'nextcursor', CONVERSATION_PAIR_LIMIT_SIZE);
        Test.stopTest();
        System.assert(!conversations.ok);
        System.assertEquals(null, conversations.channels, 
            'Channels attribute should be null. Actual: ' + conversations.channels);
    }

    @IsTest 
    static void getMessagesTest(){
        Map<String, User> usersMap = new Map<String, User>();
        usersMap.put('ABC123', new User(Id = '0058c00000CHYHuAAP', SlackID__c = 'ABC123'));
        //setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        List<SlackMessageObjects.SlackMessage> slackMsgs = SlackCalloutService.getMessages('token','conversationId', usersMap);
        Test.stopTest();

        System.assertNotEquals(slackMsgs, null);
    }

    @IsTest 
    static void getConversationMembersInsufficientTest(){
        Map<String, User> usersMap = new Map<String, User>();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        SlackMessageObjects.MemberErrorWrapper slackMsgs = SlackCalloutService.getConversationMembers('conversationId', usersMap,'tokens');
        Test.stopTest();

        System.assertEquals(slackMsgs.members.size(), 0);
    }

    @IsTest 
    static void getConversationMembersSufficientTest(){
        Map<String, User> usersMap = new Map<String, User>();
        usersMap.put('ABC123', new User(Id = '0058c00000CHYHuAAP', SlackID__c = 'ABC123'));
        usersMap.put('ABC456', new User(Id = '0058c00000CHYHqWAA', SlackID__c = 'ABC456'));

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        SlackMessageObjects.MemberErrorWrapper slackMsgs = SlackCalloutService.getConversationMembers('conversationId', usersMap, 'token');
        Test.stopTest();

        System.assertEquals(slackMsgs.members.size(), 2);
    }

    @IsTest 
    static void getConversationMembersErrorTest(){
        Map<String, User> usersMap = new Map<String, User>();
        usersMap.put('ABC123', new User(Id = '0058c00000CHYHuAAP', SlackID__c = 'ABC123'));

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock('error_mock'));
        SlackMessageObjects.MemberErrorWrapper slackMsgs = SlackCalloutService.getConversationMembers('conversationId', usersMap, 'error_mock');
        Test.stopTest();

        System.assertEquals(slackMsgs, null);
    }

    @IsTest 
    static void setMessagesTest(){
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(200);
        resp.setStatus('Success');
        String testString = '{"ok":true,"messages":[{"type":"message","user":"U012AB3CDE","text":"I find you punny and would like to smell your nose letter","ts":"1512085950.000216"},{"type":"message","user":"U061F7AUR","text":"What, you want to smell my shoes better?","ts":"1512104434.000490"}],"has_more":true,"pin_count":0,"response_metadata":{"next_cursor":"bmV4dF90czoxNTEyMDg1ODYxMDAwNTQz"}}';
        resp.setBody(testString);

        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
        List<Object> messagesListObject = (List<Object> )JSON.deserializeUntyped(System.JSON.serialize(results.get('messages')));
        Map<String, User> usersMap = new Map<String, User>();
        usersMap.put('ABC123', new User(Id = '0058c00000CHYHuAAP', SlackID__c = 'ABC123'));

        Test.startTest();
        List<SlackMessageObjects.SlackMessage> sm = SlackCalloutService.setMessages(messagesListObject, usersMap);
        Test.stopTest();

        System.assertEquals(sm.size(), 2);
    }

    @IsTest 
    static void setMessagesEditTest(){
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(200);
        resp.setStatus('Success');
        String testString = '{"ok":true,"messages":[{"type":"message","user":"U012AB3CDE","edited":{"ts":"1512085950.000216"},"text":"I find you punny and would like to smell your nose letter","ts":"1512085950.000216"},{"type":"message","user":"U061F7AUR","text":"What, you want to smell my shoes better?","ts":"1512104434.000490"}],"has_more":true,"pin_count":0,"response_metadata":{"next_cursor":"bmV4dF90czoxNTEyMDg1ODYxMDAwNTQz"}}';
        resp.setBody(testString);

        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
        List<Object> messagesListObject = (List<Object> )JSON.deserializeUntyped(System.JSON.serialize(results.get('messages')));
        Map<String, User> usersMap = new Map<String, User>();
        usersMap.put('ABC123', new User(Id = '0058c00000CHYHuAAP', SlackID__c = 'ABC123'));

        Test.startTest();
        List<SlackMessageObjects.SlackMessage> sm = SlackCalloutService.setMessages(messagesListObject, usersMap);
        Test.stopTest();

        System.assertEquals(sm.size(), 2);

    }
    
}