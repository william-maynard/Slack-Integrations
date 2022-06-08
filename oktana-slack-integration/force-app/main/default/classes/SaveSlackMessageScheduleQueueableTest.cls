@isTest
public class SaveSlackMessageScheduleQueueableTest {
    
    @isTest
    static void testingSchedule() {        
        List<SlackMessageObjects.FullConversation> convList = new List<SlackMessageObjects.FullConversation> ();

        SlackMessageObjects.FullConversation testConv = new SlackMessageObjects.FullConversation();
        testConv.conversationId = 'convID';

        convList.add(testConv);

        test.startTest();
        SaveSlackMessageScheduleQueueable myClass = new SaveSlackMessageScheduleQueueable(convList);   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();

        SlackMessageObjects.FullConversation[] retrievedList = myClass.conversationsList;

        System.assertEquals('convID', retrievedList[0].conversationId);


   }
}
