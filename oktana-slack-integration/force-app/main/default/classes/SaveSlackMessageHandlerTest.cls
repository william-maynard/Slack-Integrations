@isTest
public with sharing class SaveSlackMessageHandlerTest {

    @isTest
    public static void testAddMembersAndMessages(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        List<SlackMessageObjects.SlackUser> allUser = new List<SlackMessageObjects.SlackUser>();
        SlackMessageObjects.SlackUser newSlackUser1 = new SlackMessageObjects.SlackUser();
        SlackMessageObjects.SlackUser newSlackUser2 = new SlackMessageObjects.SlackUser();
        newSlackUser1.salesforceUserId='0058c00000CHYHuAAP';
        newSlackUser1.slackUserId='0';

        newSlackUser2.salesforceUserId='0058c00000CHYHqWAA';
        newSlackUser2.slackUserId='2';

        String token = '{"tokens":[{"slackUserId":"U03A8GA3BGC","accessToken":"xoxp-3331607868951-3348554113556-3579730000528-0bab6fe771a836e8fb95f3de4ecb004e","workspace":"SavingPlayground"}]}';
        SlackMessageObjects.UserConversationPair conversationsPair = new  SlackMessageObjects.UserConversationPair();

        allUser.add(newSlackUser1);
        allUser.add(newSlackUser2);

        String[] conversations = new String[2];
        conversations[0]='1';
        conversations[1]='3';
        
        conversationsPair.conversationIds = conversations;

        List<SlackMessageObjects.FullConversation> slackConversationsToSave = SaveSlackMessageHandler.addMembersAndMessages(conversationsPair, allUser, token);
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
        List<SlackMessageObjects.FullConversation> convList = new List<SlackMessageObjects.FullConversation>();

        List<Debug_Log__c> error = new List<Debug_Log__c>();
        error.add(new Debug_Log__c(Log_Body__c='error',Description__c='description'));

        List<SlackMessageObjects.SlackMessage> messages = new List<SlackMessageObjects.SlackMessage>();
        for(Integer i=0; i<105; i++){
            SlackMessageObjects.SlackMessage sm1 = new SlackMessageObjects.SlackMessage();
            sm1.textMessage = 'Text';
            sm1.ts = 'ts';
            sm1.isEdited = false;
            sm1.editedTS = 'editedTs';
            sm1.slackUserId = 'slackUserId';
    
            messages.add(sm1);
        }

        List<String> memberString = new List<String>();
        User us = [select id from user limit 1];
        memberString.add(us.id);

        SlackMessageObjects.FullConversation testConv = new SlackMessageObjects.FullConversation();
        testConv.conversationId = 'convID';
        testConv.messages = messages;
        testConv.errorLogs = error; 
        testConv.members = memberString;
        
        Conversation__c conversation = new Conversation__c(Conversation_Id__c='dfs333',Slack_Conversation_Id__c='T03HBSQKZEX');
        insert conversation;

        convList.add(testConv);
        
        Test.startTest();      
        	SaveSlackMessageHandler.saveSlackConversations(convList);    	
        Test.stopTest();
    }


}
