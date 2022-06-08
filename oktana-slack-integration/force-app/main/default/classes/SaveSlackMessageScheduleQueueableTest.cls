@isTest
public class SaveSlackMessageScheduleQueueableTest {
    
    @isTest
    static void testingSchedule() {        
        List<SaveSlackMessageHandler.FullConversation> convList = new List<SaveSlackMessageHandler.FullConversation> ();

        SaveSlackMessageHandler.FullConversation testConv = new SaveSlackMessageHandler.FullConversation();
        testConv.conversationId = 'convID';

        convList.add(testConv);

        test.startTest();
        SaveSlackMessageScheduleQueueable myClass = new SaveSlackMessageScheduleQueueable(convList);   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();

        SaveSlackMessageHandler.FullConversation[] retrievedList = myClass.conversationsList;

        System.assertEquals('convID', retrievedList[0].conversationId);


   }
}
