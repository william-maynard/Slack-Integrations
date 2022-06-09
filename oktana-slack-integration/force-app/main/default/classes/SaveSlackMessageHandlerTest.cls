@isTest
public with sharing class SaveSlackMessageHandlerTest {


    @isTest
    public static void testAddMembersAndMessages(){
        Test.startTest();
            List<SlackMessageObjects.SlackUser> allUser = new List<SlackMessageObjects.SlackUser>();
            SlackMessageObjects.SlackUser newSlackUser = new SlackMessageObjects.SlackUser();
            newSlackUser.salesforceUserId='0058c00000CHYHuAAP';
            newSlackUser.slackUserId='12';
            newSlackUser.salesforceUserId='0058c00000CHYHqWAA';
            newSlackUser.slackUserId='10';

            String token = '{"tokens":[{"slackUserId":"U03A8GA3BGC","accessToken":"xoxp-3331607868951-3348554113556-3579730000528-0bab6fe771a836e8fb95f3de4ecb004e","workspace":"SavingPlayground"}]}';
            SlackMessageObjects.UserConversationPair conversationsPair = new  SlackMessageObjects.UserConversationPair();

            allUser.add(newSlackUser);


            String[] conversations = new String[2];
            conversations[0]='1';
            conversations[1]='3';
            
            conversationsPair.conversationIds = conversations;
            conversationsPair.userToken = token;

            List<SlackMessageObjects.FullConversation> slackConversationsToSave = SaveSlackMessageHandler.addMembersAndMessages(conversationsPair,allUser,token);
            System.assertEquals(slackConversationsToSave.size(), 2, 'the size is not equals to the conversationIds');
        Test.stopTest();
    }


    @isTest
    public static testmethod void test1(){
        SlackMessageObjects.FullConversation testConv = new SlackMessageObjects.FullConversation();
        testConv.conversationId = 'convID';

        convList.add(testConv);

        Test.startTest();
            String CRON_EXP = '0 0 23 * * ?'; 
            String jboId = system.schedule('Test Territory Check', CRON_EXP, new SaveSlackMessageHandler.scheduleSaveConversations(convList)); 

        //CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
           // System.debug(ct);
           System.debug(jboId);

            // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
            // Verify the job has not run 
            //System.assertEquals(0, ct.TimesTriggered); 
            // Verify the next time the job will run 
            //System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));   
        Test.stopTest();        
    }


}
