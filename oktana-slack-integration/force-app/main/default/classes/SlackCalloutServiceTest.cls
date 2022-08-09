@isTest
public with sharing class SlackCalloutServiceTest {

    static final Integer CONVERSATION_PAIR_LIMIT_SIZE = 40;
    static final Integer CONVERSATION_PAIR_LIST_SIZE = 40;

    @isTest 
    static void getConversationPairsSucessTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        SlackMessageObjects.UserConversationPair convPair = SlackCalloutService.getConversationPairs('token', 'nextcursor', CONVERSATION_PAIR_LIMIT_SIZE);
        Test.stopTest();
        System.assertEquals(convPair.conversationIds.size(), CONVERSATION_PAIR_LIST_SIZE);
    }

    @isTest 
    static void getConversationPairsErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock('error_mock'));
        SlackMessageObjects.UserConversationPair convPair = SlackCalloutService.getConversationPairs('error_mock', 'nextcursor', CONVERSATION_PAIR_LIMIT_SIZE);
        Test.stopTest();
        System.assertEquals(convPair, null);
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
    static void getNextCursorSuccessTest(){
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(200);
        resp.setStatus('Success');
        String testString = '{"response_metadata":{"next_cursor":"nextcursorvalue"}}';
        resp.setBody(testString);

        Map<String, Object> conversationResults = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());

        Test.startTest();
        String nc = SlackCalloutService.getNextCursor(conversationResults);
        Test.stopTest();

        System.assertEquals(nc, 'nextcursorvalue');
    }

    @IsTest 
    static void getNextCursorErrorTest(){
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(200);
        resp.setStatus('Success');
        String testString = '{"error":true}';
        resp.setBody(testString);

        Map<String, Object> conversationResults = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());

        Test.startTest();
        String nc = SlackCalloutService.getNextCursor(conversationResults);
        Test.stopTest();

        System.assertEquals(nc, null);
        
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

    @IsTest 
    static void getConversationIdsTest(){
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(200);
        resp.setStatus('Success');
        String testString = '{"channels":[{"id":"C1"},{"id":"C2"}]}';
        resp.setBody(testString);

        Map<String, Object> conversationResults = (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());

        Test.startTest();
        String[] cids = SlackCalloutService.getConversationIds(conversationResults);
        Test.stopTest();

        System.assertEquals(cids.size(), 2);
    }
    
}