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
    public static void testScheduleSaveConversations(){
        List<SlackMessageObjects.FullConversation> convList = new List<SlackMessageObjects.FullConversation>();
        SlackMessageObjects.FullConversation testConv = new SlackMessageObjects.FullConversation();
        testConv.conversationId = 'convID';

        convList.add(testConv);

        Test.startTest();
            String jobId = SaveSlackMessageHandler.scheduleSaveConversations(convList);

            list<CronTrigger> ct = [SELECT Id,CronJobDetail.Name,CronJobDetail.Id,State FROM CronTrigger WHERE Id = :'08e8c00001SxASW'];
            System.assertNotEquals(ct.size(), 1);
        
            List<CronTrigger> ct2 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId]; 
            System.assertEquals(ct2.size(), 1);  
        Test.stopTest();        
    }

    @isTest(SeeAllData=true)
    public static void testSaveSlackConversations(){
        
        // List<Debug_Log__c> error = new List<Debug_Log__c>();
        // error.add(new Debug_Log__c(Log_Body__c='error',Description__c='description'));
        // List<SlackMessageObjects.FullConversation> convList = new List<SlackMessageObjects.FullConversation>();
        // SlackMessageObjects.FullConversation testConv = new SlackMessageObjects.FullConversation();
        // testConv.conversationId = 'convID';
        // testConv.errorLogs = error; 

        // Conversation__c conversation = new Conversation__c(Conversation_Id__c='dfs333',Slack_Conversation_Id__c='T03HBSQKZEX');

        // insert conversation;

    

        // convList.add(testConv);
        
        // Test.startTest();
        
        // 	SaveSlackMessageHandler.saveSlackConversations(convList);
        	
        // Test.stopTest();
    }


}
