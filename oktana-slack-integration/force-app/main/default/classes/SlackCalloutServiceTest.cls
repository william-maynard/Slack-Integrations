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
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        SlackMessageObjects.UserConversationPair convPair = SlackCalloutService.getConversationPairs('error_mock', 'nextcursor', CONVERSATION_PAIR_LIMIT_SIZE);
        Test.stopTest();
        System.assertEquals(convPair, null);
    }

    @IsTest 
    static void getMessagesTest(){
        //setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        List<SlackMessageObjects.SlackMessage> slackMsgs = SlackCalloutService.getMessages('token','conversationId');
        Test.stopTest();

        System.assertNotEquals(slackMsgs, null);
    }

    @IsTest 
    static void getConversationMembersInsufficientTest(){
        SlackMessageObjects.SlackUser user = new SlackMessageObjects.SlackUser();
        List<SlackMessageObjects.SlackUser> users = new List<SlackMessageObjects.SlackUser>();
        user.slackUserId = '0';
        users.add(user);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        SlackMessageObjects.MemberErrorWrapper slackMsgs = SlackCalloutService.getConversationMembers('conversationId','convType', users,'tokens');
        Test.stopTest();

        System.assertEquals(slackMsgs.members.size(), 0);
    }

    @IsTest 
    static void getConversationMembersSufficientTest(){
        List<SlackMessageObjects.SlackUser> users = new List<SlackMessageObjects.SlackUser>();
        SlackMessageObjects.SlackUser user = new SlackMessageObjects.SlackUser();
        user.slackUserId = '0';
        user.salesforceUserId = 'id1';
        SlackMessageObjects.SlackUser user2 = new SlackMessageObjects.SlackUser();
        user2.slackUserId = '2';
        user2.salesforceUserId = 'id2';
        
        users.add(user);
        users.add(user2);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        SlackMessageObjects.MemberErrorWrapper slackMsgs = SlackCalloutService.getConversationMembers('conversationId','convType', users,'token');
        Test.stopTest();

        System.assertEquals(slackMsgs.members.size(), 2);
    }

    @IsTest 
    static void getConversationMembersErrorTest(){
        SlackMessageObjects.SlackUser user = new SlackMessageObjects.SlackUser();
        List<SlackMessageObjects.SlackUser> users = new List<SlackMessageObjects.SlackUser>();
        user.slackUserId = '0';
        users.add(user);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        SlackMessageObjects.MemberErrorWrapper slackMsgs = SlackCalloutService.getConversationMembers('conversationId','convType', users,'error_mock');
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

        Test.startTest();
        List<SlackMessageObjects.SlackMessage> sm = SlackCalloutService.setMessages(messagesListObject);
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

        Test.startTest();
        List<SlackMessageObjects.SlackMessage> sm = SlackCalloutService.setMessages(messagesListObject);
        Test.stopTest();

        System.assertEquals(sm.size(), 2);

    }

    @IsTest
    static void setRequestTest() {
        HttpRequest response = new HttpRequest();
        response.setEndpoint('https://slack.com/api/conversations.list?token=xoxp-3331607868951-3348554113556-3579730000528-0bab6fe771a836e8fb95f3de4ecb004e&types=public_channel,private_channel,im&limit=301');
        response.setMethod('POST');

        String token = 'xoxp-3331607868951-3348554113556-3579730000528-0bab6fe771a836e8fb95f3de4ecb004e';
        Map<String, String> headers = new Map<String, String>();
        headers.put('Accept', 'application/x-www-form-urlencoded');
        headers.put('Content-Type','application/x-www-form-urlencoded');
        String endpoint = 'https://slack.com/api/conversations.list' + '?token=' + token + '&types=public_channel,private_channel,im&limit='+ 30 + 1 ;

        HttpRequest req = SlackCalloutService.setRequest('POST', headers , endpoint);	

        System.assertNotEquals(response, req);
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