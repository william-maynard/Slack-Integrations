@isTest
public class ConversationServiceTest {
    
    @isTest
    public static void givenConversationIdsWhenCallingConversationServiceDotGetSFConversationsIsSuccessfully() {
        
        Set<String> conversationIds = new Set<String>{'TEST_SLACK_ID'};
        TestDataFactory.createConversations(conversationIds);

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
        messages.addAll(TestDataFactory.createSlackChatMessages(numberNewMessages, false));
        messages.addAll(TestDataFactory.createSlackChatMessages(numberNewComments, true));
        
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