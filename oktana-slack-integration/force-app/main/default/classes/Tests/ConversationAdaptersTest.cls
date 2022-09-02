@isTest
public class ConversationAdaptersTest {
    @isTest
    public static void givenASlackConversationIdAndLastMessageIdCreateMapToBeUsed(){
        Map<String,String> testMap = TestDataFactory.createConversationInfo(3);
        ConversationAdapters ca = new ConversationAdapters();
        test.startTest();
        ca.setConversationInfo(testMap);
        test.stopTest();
        System.assertEquals(testMap, ca.conversationToLastMessageIdMap, 'Expecting the detail Map to match the last messageID map');
    }
    @isTest
    public static void givenAListOfSlackConversationWrappersSetValuesOnAdapter(){
        List<SlackObjects.Conversation> testList = TestDataFactory.createSlackConversationWrappers(3);
        ConversationAdapters ca = new ConversationAdapters();
		test.startTest();
        ca.setConversationInfoFromSlack(testList);
        test.stopTest();
        System.assertEquals(3, ca.conversationIds.keySet().size(), 'Expecting the size of the map to match the integer passed to the factory');
    }
    @isTest
    public static void givenConversationDetailsFromSFTestIterationForGettingAndHasNextIterator(){
        Map<String,String> testMap = TestDataFactory.createConversationInfo(3);
        ConversationAdapters ca = new ConversationAdapters();
        ca.setConversationInfo(testMap);
        test.startTest();
        if(ca.hasNextConversation()){
            ca.getNextConversation();
        }
        test.stopTest();
        system.assertEquals(1, ca.getNextConversation().keySet().size(), 'Expect the getNextConversation Method to return a map of size 1');
    }
    @isTest
    public static void givenSetConversationInfoFromSlackMethodHasRunReturnTheKeySet(){
        List<SlackObjects.Conversation> testList = TestDataFactory.createSlackConversationWrappers(5);
        ConversationAdapters ca = new ConversationAdapters();
        ca.setConversationInfoFromSlack(testList);
        test.startTest();
        ca.selectConversationIds();
        test.stopTest();
        system.assertEquals(5, ca.selectConversationIds().keySet().size(), 'Expecting to return a Map keyset of size 5');
    }
    @isTest
    public static void givenSlackServiceHasRetrievedAllMessagesFromSlackConversation(){
        TestDataFactory.insertStandardUsersWithSlackToken(1);
        ConversationAdapters ca = new ConversationAdapters();
        List<SlackObjects.Conversation> testList = TestDataFactory.createSlackConversationWrappers(2);
		ca.setConversationInfoFromSlack(testList);
        Map<String, SlackObjects.AllMessages> testMap = TestDataFactory.createMapOfConversationIdToAllMessageWrapper(2,1);
		test.startTest();
        ca.setConversationFromSlack(testMap);
        test.stopTest();
        system.assertEquals(2, ca.conversationsMap.keySet().size(), 'We expect there to be 2 conversations since the factory is returning 2 conversations with 1 messages each');
    }

}