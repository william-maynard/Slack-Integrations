@isTest
public with sharing class SlackMessageCollectorTest {

    @isTest
    public static void givenSplitConversationsToCollectIsCalledThenASplitedListIsReturned() {

        List<SlackObjects.Conversation> conversationList = SlackServiceTestUtilities.getPMConversations(100);
        SlackMessageCollector smc = new SlackMessageCollector();
        test.startTest();
        List<SlackObjects.Conversation> splitedConversationList = smc.splitConversationsToCollect(conversationList);
        test.stopTest();
        system.assert(splitedConversationList.size() == Constants.SPLIT_LIMIT);
    }

    @isTest
    public static void givenSplitConversationsToCollectIsCalledThenRemainingConversationListIsStoredOnConfig() {

        List<SlackObjects.Conversation> conversationList = SlackServiceTestUtilities.getPMConversations(100);
        SlackMessageCollector smc = new SlackMessageCollector();
        test.startTest();
        smc.splitConversationsToCollect(conversationList);
        test.stopTest();
        system.assert(smc.state.remainingConversations.size() == 100 - Constants.SPLIT_LIMIT);
    }

    @isTest
    public static void givenSplitConversationsToCollectIsCalledWithNullListThenExceptionIsThrown() {

        List<SlackObjects.Conversation> conversationList = null;
        SlackMessageCollector smc = new SlackMessageCollector();
        test.startTest();
        try {
            smc.splitConversationsToCollect(conversationList);
            test.stopTest();
            system.assert(false,'No exception thrown');
        }catch (SlackMessageCollector.SlackMessageCollectorException e){
            system.assert(e.getMessage() == 'Recieved Null conversation List');
        }
    }


    @isTest
    public static void givenSplitConversationsToCollectIsCalledWithEmptyListThenExceptionIsThrown() {

        List<SlackObjects.Conversation> conversationList = new List<SlackObjects.Conversation>();
        SlackMessageCollector smc = new SlackMessageCollector();
        test.startTest();
        try {
            smc.splitConversationsToCollect(conversationList);
            test.stopTest();
            system.assert(false,'No exception thrown');
        }catch (SlackMessageCollector.SlackMessageCollectorException e){
            system.assert(e.getMessage() == 'Recieved Empty conversation List');
        }

    }

    @isTest
    public static void fireMessageEventTest(){

        SlackMessageCollector smc = new SlackMessageCollector();
        test.startTest();
        Boolean fired = smc.fireMessageEvent();
        test.stopTest();

        System.assertEquals(fired,true);
    }
}
