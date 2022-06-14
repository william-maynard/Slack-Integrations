@isTest
public with sharing class SlackCalloutServiceTest {

    static final Integer CONVERSATION_PAIR_LIST_SIZE = 40;
    static final Integer CONVERSATION_PAIR_LIMIT_SIZE = 40;

    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWithIgnoreCase('https://slack.com/api/conversations.list?token=error_mock')) {
                HttpResponse resp = new HttpResponse();
                resp.setStatusCode(200);
                resp.setStatus('error');
                resp.setBody('{"error": true}');
                return resp;
            } else if (req.getEndpoint().startsWithIgnoreCase('https://slack.com/api/conversations.list')) {

                String ids = '';
                String aux1 = '{"id":"';
                String aux2 = '","name":"general","is_channel":true,"is_group":false,"is_im":false,"created":1449252889,"creator":"U012A3CDE","is_archived":false,"is_general":true,"unlinked":0,"name_normalized":"general","is_shared":false,"is_ext_shared":false,"is_org_shared":false,"pending_shared":[],"is_pending_ext_shared":false,"is_member":true,"is_private":false,"is_mpim":false,"topic":{"value":"Company-wide announcements and work-based matters","creator":"","last_set":0},"purpose":{"value":"This channel is for team-wide communication and announcements. All team members are in this channel.","creator":"","last_set":0},"previous_names":[],"num_members":4}';
                for(Integer i = 0; i<CONVERSATION_PAIR_LIST_SIZE-1; i++){
                    String idString=aux1+'C'+i+aux2+',';
                    ids = ids+idString;
                }

                ids=ids + aux1+'C'+'lst'+aux2;

                String strBody = '{"ok":true,"channels":[' + ids+'],"response_metadata":{"next_cursor":"dGVhbTpDMDYxRkE1UEI="}}';

                HttpResponse resp = new HttpResponse();
                resp.setStatusCode(200);
                resp.setStatus('Success');
                //resp.setBody('{"ok":true,"channels":[{"id":"C012AB3CD","name":"general","is_channel":true,"is_group":false,"is_im":false,"created":1449252889,"creator":"U012A3CDE","is_archived":false,"is_general":true,"unlinked":0,"name_normalized":"general","is_shared":false,"is_ext_shared":false,"is_org_shared":false,"pending_shared":[],"is_pending_ext_shared":false,"is_member":true,"is_private":false,"is_mpim":false,"topic":{"value":"Company-wide announcements and work-based matters","creator":"","last_set":0},"purpose":{"value":"This channel is for team-wide communication and announcements. All team members are in this channel.","creator":"","last_set":0},"previous_names":[],"num_members":4},{"id":"C061EG9T2","name":"random","is_channel":true,"is_group":false,"is_im":false,"created":1449252889,"creator":"U061F7AUR","is_archived":false,"is_general":false,"unlinked":0,"name_normalized":"random","is_shared":false,"is_ext_shared":false,"is_org_shared":false,"pending_shared":[],"is_pending_ext_shared":false,"is_member":true,"is_private":false,"is_mpim":false,"topic":{"value":"Non-work banter and water cooler conversation","creator":"","last_set":0},"purpose":{"value":"A place for non-work-related flimflam, faffing, hodge-podge or jibber-jabber you\'d prefer to keep out of more focused work-related channels.","creator":"","last_set":0},"previous_names":[],"num_members":4}],"response_metadata":{"next_cursor":"dGVhbTpDMDYxRkE1UEI="}}');
                resp.setBody(strBody);
                return resp;
            } 
            else if (req.getEndpoint().startsWithIgnoreCase('https://slack.com/api/conversations.history')) {
                HttpResponse resp = new HttpResponse();
                resp.setStatusCode(200);
                resp.setStatus('Success');
                resp.setBody('{"ok":true,"messages":[{"type":"message","user":"U012AB3CDE","text":"I find you punny and would like to smell your nose letter","ts":"1512085950.000216"},{"type":"message","user":"U061F7AUR","text":"What, you want to smell my shoes better?","ts":"1512104434.000490"}],"has_more":true,"pin_count":0,"response_metadata":{"next_cursor":"bmV4dF90czoxNTEyMDg1ODYxMDAwNTQz"}}');
                return resp;
            }
            else if (req.getEndpoint().startsWithIgnoreCase('https://slack.com/api/conversations.members?token=error_mock')) {
                HttpResponse resp = new HttpResponse();
                resp.setStatusCode(200);
                resp.setStatus('Success');
                resp.setBody('{"error": true}');
                return resp;
            }
            else if (req.getEndpoint().startsWithIgnoreCase('https://slack.com/api/conversations.members')) {
                HttpResponse resp = new HttpResponse();
                resp.setStatusCode(200);
                resp.setStatus('Success');
                resp.setBody('{"ok":true, "members":["0","2","21"],"response_metadata":{"next_cursor": "e3VzZXJfaWQ6IFcxMjM0NTY3fQ=="}}');
                return resp;
            }
            else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    @isTest 
    static void getsConversationIdsSucessTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        SlackMessageObjects.UserConversationPair convPair = SlackCalloutService.getsConversationIds('token', 'nextcursor', CONVERSATION_PAIR_LIMIT_SIZE);
        Test.stopTest();
        System.assertEquals(convPair.conversationIds.size(), CONVERSATION_PAIR_LIST_SIZE);
    }

    @isTest 
    static void getsConversationIdsErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
        SlackMessageObjects.UserConversationPair convPair = SlackCalloutService.getsConversationIds('error_mock', 'nextcursor', CONVERSATION_PAIR_LIMIT_SIZE);
        Test.stopTest();
        System.assertEquals(convPair, null);
    }

    @IsTest 
    static void getMessagesTest(){
        //setup();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock());
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
        Test.setMock(HttpCalloutMock.class, new Mock());
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
        Test.setMock(HttpCalloutMock.class, new Mock());
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
        Test.setMock(HttpCalloutMock.class, new Mock());
        SlackMessageObjects.MemberErrorWrapper slackMsgs = SlackCalloutService.getConversationMembers('conversationId','convType', users,'error_mock');
        Test.stopTest();

        System.assertEquals(slackMsgs, null);
    }
    
}