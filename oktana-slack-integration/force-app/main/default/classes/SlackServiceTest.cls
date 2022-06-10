@isTest
private with sharing class SlackServiceTest {

    // static void setup(){
    //     ChatterUser__c cu = new ChatterUser__c();
    //     List<User> userList = createTestUsers();
    //     List<ChatterUser__c> chatterUsers = new List<ChatterUser__c>();

    //     System.debug('Before encryption');
    //     //String encryptedString = SlackIntegration.encrypt('xoxb-1234567890');
    //     System.debug('After encryption');

    //     for(Integer i = 0; i<userList.size(); i++){
    //         ChatterUser__c chatterUser = new ChatterUser__c();
    //         chatterUser.User__c = userList[i].Id;
    //         chatterUser.Slack_user_tokens__c = '{"tokens":[{"slackUserId":"U03A8GA3BGC","accessToken":"xoxp-3331607868951-3348554113556-3579730000528-0bab6fe771a836e8fb95f3de4ecb004e","workspace":"SavingPlayground"}]}';
    //         chatterUsers.add(chatterUser);
    //     }
    //     insert chatterUsers;

    //     //adding CustomSettings
    //     SlackWorkspace__c wspaceToInsert = new SlackWorkspace__c();
    //     wspaceToInsert.Name = 'CurrentWorkspace';
    //     wspaceToInsert.SlackWorkspaceId__c = 'T039RHVRJTZ';
    //     wspaceToInsert.SlackWorkspaceLabel__c = 'SavingPlayground';
    //     insert wspaceToInsert;
    // }

    private static List<User> createTestUsers(){
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'TestUser', Email = 'testUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='TestUser', ProfileId=p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        LanguageLocaleKey = 'en_US',
        SlackID__c = '12',
        UserName='tokuser@testorg.com' );
        insert u;

        userList.add(u);

        return userList;
    }

    @isTest static void TestGetSlackConversationsInformationAndSave() {
        List<User> users = createTestUsers();
        String[] conversations = new String[1];
        conversations[0]='1';
        SlackMessageObjects.UserConversationPair user_ConversationPair = new SlackMessageObjects.UserConversationPair();
        user_ConversationPair.userToken='';
        user_ConversationPair.conversationIds=conversations;
        String token = '{"tokens":[{"slackUserId":"U03A8GA3BGC","accessToken":"xoxp-3331607868951-3348554113556-3579730000528-0bab6fe771a836e8fb95f3de4ecb004e","workspace":"SavingPlayground"}]}';
        String nextCursor = '1';
        List<Debug_Log__c> errorLogs = new List<Debug_Log__c>();

        SlackService.getSlackConversationsInformationAndSave(user_ConversationPair,token,nextCursor,errorLogs);
        
    
    }

    @isTest(SeeAllData=true)
    private static void TestGetSlackToken() {
        String tokens = SlackService.getSlackToken();
        System.assertEquals((tokens != ''), true);     
    }
}