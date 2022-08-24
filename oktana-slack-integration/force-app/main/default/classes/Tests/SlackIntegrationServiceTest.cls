@isTest
public with sharing class SlackIntegrationServiceTest {
    private static final String TOKEN = 'xopb-abc123';

    @isTest
    private static void givenATokenWhenCallingSlackIntegrationServiceDotFetchConversationsIsSuccessfully() {
        String responseBody = '{"ok": true, "channels": ['
                + '{"id": "ABC123", "name": "channel 1", "is_channel": true, "is_group": false, "is_im": false}'
                + '{"id": "ABC456", "name": "channel 2", "is_channel": true, "is_group": false, "is_im": false}]'
                + '"response_metadata": {"next_cursor": "dGVhbTpDMDYxRkE1UEI="}}';
        
        HttpRequestMock httpMock = createSlackSuccessRequestMockWithBody(responseBody);
        Test.setMock(HttpCalloutMock.class, httpMock);

        SlackIntegrationService slackIntegrationService = new SlackIntegrationService(TOKEN);
        Integer recordsLimit = 100;
        String nextCursor = null;

        Test.startTest();
        HttpResponse response = slackIntegrationService.fetchConversations(recordsLimit, nextcursor);
        Test.stopTest();

        System.assertEquals(responseBody, response.getBody(), 'Fetch conversations response body not match the expected result');
    }

    @isTest
    private static void givenATokenAndConversationIdWhenCallingSlackIntegrationServiceDotFetchConversationsMembersIsSuccessfully() {
        String responseBody = '{"ok": true, "members": ["U023BECGF", "U061F7AUR", "W012A3CDE"],'
                            + '"response_metadata": {"next_cursor": "e3VzZXJfaWQ6IFcxMjM0NTY3fQ=="}}';
        
        HttpRequestMock httpMock = createSlackSuccessRequestMockWithBody(responseBody);
        Test.setMock(HttpCalloutMock.class, httpMock);

        SlackIntegrationService slackIntegrationService = new SlackIntegrationService(TOKEN);
        String conversationId = 'C0ABC123';

        Test.startTest();
        HttpResponse response = slackIntegrationService.fetchConversationMembers(conversationId);
        Test.stopTest();

        System.assertEquals(responseBody, response.getBody(), 
            'Fetch conversations members response body not match the expected result');
    }

    @isTest
    private static void givenATokenWhenCallingSlackIntegrationServiceDotFetchMessagesIsSuccessfully() {
        String responseBody = '{"ok": true, '
                            + '"messages": ['
                            + '{"type": "message", "user": "U012AB3CDE", "text": "Text 1", "ts": "1512085950.000216"},'
                            + '{"type": "message", "user": "U061F7AUR", "text": "Text 2", "ts": "1512104434.000490"}'
                            + '],'
                            + '"has_more": true, "response_metadata": {"next_cursor": "bmV4dF90czoxNTEyMDg1ODYxMDAwNTQz"}}';
        
        HttpRequestMock httpMock = createSlackSuccessRequestMockWithBody(responseBody);
        Test.setMock(HttpCalloutMock.class, httpMock);
        
        SlackIntegrationService slackIntegrationService = new SlackIntegrationService(TOKEN);
        String conversationId = 'C0ABC123';
        String lastMessageId = null;
        
        Test.startTest();
        HttpResponse response = slackIntegrationService.fetchMessages(conversationId, lastMessageId);
        Test.stopTest();

        System.assertEquals(responseBody, response.getBody(), 'Fetch messages response body not match the expected result');
    }

    @isTest
    private static void givenATokenWhenCallingSlackIntegrationServiceDotFetchUsersIsSuccessfully() {
        String responseBody = '{"ok": true, "members": ['
                            + '{'
                                + '"id": "W012A3CDE", '
                                + '"team_id": "T012AB3C4",'
                                + '"name": "spengler",'
                                + '"real_name": "spengler",'
                                + '"profile": {"email": "spengler@mail.example.com"}'
                            + '},{'
                                + '"id": "W07QCRPA4",'
                                + '"team_id": "T0G9PQBBK",'
                                + '"name": "glinda",'
                                + '"real_name": "Glinda Southgood",'
                                + '"profile": {"email": "glenda@mail.examaple.com"}'
                            + '}],'
                            + '"response_metadata": {"next_cursor": "dXNlcjpVMEc5V0ZYTlo="}}';
        
        HttpRequestMock httpMock = createSlackSuccessRequestMockWithBody(responseBody);
        Test.setMock(HttpCalloutMock.class, httpMock);
        
        SlackIntegrationService slackIntegrationService = new SlackIntegrationService(TOKEN);
        String wokspaceId = 'T0ABC123';

        Test.startTest();
        HttpResponse response = slackIntegrationService.fetchUsers(wokspaceId);
        Test.stopTest();

        System.assertEquals(responseBody, response.getBody(), 'Fetch users response body not match the expected result');
    }

    @isTest
    private static void givenATokenWhenCallingSlackIntegrationServiceDotSendTextMessageIsSuccessfullySent() {
        String responseBody = '{"ok": true, "channel": "C123456", "ts": "1503435956.000247", '
                            + '"message": {'
                                + '"text": "Text Message", '
                                + '"username": "ecto1", '
                                + '"bot_id": "B123456", '
                                + '"attachments": [], '
                                + '"type": "message", '
                                + '"subtype": "bot_message", '
                                + '"ts": "1503435956.000247" '
                            + '}}';
        
        HttpRequestMock httpMock = createSlackSuccessRequestMockWithBody(responseBody);
        Test.setMock(HttpCalloutMock.class, httpMock);
        
        SlackIntegrationService slackIntegrationService = new SlackIntegrationService(TOKEN);
        String conversationId = 'C0ABC123';
        String text = 'Test message sent';

        Test.startTest();
        HttpResponse response = slackIntegrationService.sendTextMessage(conversationId, text);
        Test.stopTest();

        System.assertEquals(responseBody, response.getBody(), 'Send message response body not match the expected result');
    }

    private static HttpRequestMock createSlackSuccessRequestMockWithBody(String responseBody) {
        Map<String, String> headers = new Map<String, String>();
        headers.put(Constants.CALLOUT_HEADER_CONTENT_TYPE, Constants.CALLOUT_HEADER_CONTENT_TYPE_APPLICATION_JSON);
        return new HttpRequestMock(200, 'OK', responseBody, headers);
    }
}
