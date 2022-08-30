@isTest
public class ConversationServiceTest {
    
    @isTest
    public static void givenConversationIdsWhenCallingConversationServiceDotGetSFConversationsIsSuccessfully() {
        
        //TODO: Move this to TestFactory
        Conversation__c conversation = new Conversation__c();
        conversation.Slack_Conversation_Id__c = 'TEST_SLACK_ID';
        conversation.Conversation_Id__c = UserInfo.getUserId();
        insert conversation;

        Set<String> conversationIds = new Set<String>{'TEST_SLACK_ID'};
        //END - TODO: Move this to TestFactory

        ConversationService cService = new ConversationService();

        Test.startTest();
        Map<String, SlackObjects.ConversationDetails> result = cService.getSFConversations(conversationIds);
        Test.stopTest();

        system.assertEquals(1, result.size(), 'It should return 1 conversation detail per conversation');
    }

    @isTest
    public static void givenChatMessagesWhenCallingConversationServiceDotPostMessagesIsSuccessfully() {
        
        Integer numberNewMessages = 2;
        Integer numberNewComments = 1;
        
        List<SlackObjects.Chat> messages = new List<SlackObjects.Chat>();
        
        //TODO: Move this to TestFactory
        for(Integer i = 0; i < numberNewMessages; i++) {
            SlackObjects.Chat chat = new SlackObjects.Chat();
            chat.sFUserId = new Set<Id>{UserInfo.getUserId()};
            SlackObjects.Message message = new SlackObjects.Message();
            message.text = 'Test Chat Message ' + i;
            chat.messageBody = message;
            messages.add(chat);
        }

        for(Integer i = 0; i < numberNewComments; i++) {
            SlackObjects.Chat chat = new SlackObjects.Chat();
            chat.sFUserId = new Set<Id>{UserInfo.getUserId()};
            chat.feedItemId = UserInfo.getUserId();
            SlackObjects.Message message = new SlackObjects.Message();
            message.text = 'Test Chat Message ' + i;
            chat.messageBody = message;
            messages.add(chat);
        }
        //END - TODO: Move this to TestFactory
        
        ConnectAPIIntegrationService ciService = new ConnectAPIIntegrationService();
        ciService.myPoster = new MockChatterPoster();
        
        ConversationService cService = new ConversationService();
        cService.connectAPIIntegrationService = ciService;

        Test.startTest();
        cService.postMessages(messages);
        Test.stopTest();

        system.assertEquals(2, ((MockChatterPoster)ciService.myPoster).timesCalled, 'It should call only 2 time the ConnectAPI, 1 to insert Feeds and 1 to insert each Comment');
    }

    private class MockChatterPoster implements ConnectAPIIntegrationService.ChatterPoster {

        public Integer timesCalled = 0;

        public void postToChatter(List<ConnectApi.BatchInput> batchInputs) {
            System.assertEquals(batchInputs.isEmpty(), false, 'Should be calling ConnectAPI with batch imputs');
            timesCalled++;
        }

        public void postToChatter(ID feedItemId, ConnectApi.CommentInput commentInput) {
            System.assertEquals(commentInput == NULL, false, 'Should be calling ConnectAPI with the comments');
            timesCalled++;
        }
    }
}