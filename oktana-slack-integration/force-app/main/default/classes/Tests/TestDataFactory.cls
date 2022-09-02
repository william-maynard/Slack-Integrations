@isTest
public without sharing class TestDataFactory {
    
    public static void updateActiveLocalUsersToInActive(){
        List<User> userList = new List<User>();
        for (User user : [SELECT Id, isActive FROM User WHERE SlackID__c != null AND User_Token__c != null]) {
            user.isActive = false;
            userList.add(user);
        }  
        Database.update(userList) ;
    }
    
    public static void insertStandardUsersWithSlackToken(Integer size){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> users = new List<User>();

        for (Integer i = 0; i < size; i++) {
            User user = new User(Alias = 'User'+i, Email = 'testUser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestUser'+i,
            ProfileId=p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            SlackID__c = 'slackid',
            UserName='Test'+i+'@test.org.dev',
            User_Token__c='xoxp-3598964873479-3615963368372-3757017684002-b6c4aae94ffc7782311012616b9db0fc-'+i,
            IsActive = true);

            users.add(user); 
        }
        insert users;
    }

    public static void createConversations(Set<String> slackConversationIDs) {
        List<Conversation__c> conversations = new List<Conversation__c>();
        for(String slackConversationID : slackConversationIDs) {
            conversations.add( new Conversation__c(
                Slack_Conversation_Id__c = slackConversationID,
                Conversation_Id__c = UserInfo.getUserId()
            ));
        }

        if(!conversations.isEmpty()) {
            insert conversations;
        }
    }

    public static List<SlackObjects.Chat> createSlackChatMessages(Integer numberOfChatMessages, Boolean includeFeedItem) {
        List<SlackObjects.Chat> messages = new List<SlackObjects.Chat>();
        for(Integer i = 0; i < numberOfChatMessages; i++) {
            SlackObjects.Chat chat = new SlackObjects.Chat();
            chat.sFUserId = new Set<Id>{UserInfo.getUserId()};
            if(includeFeedItem) {
                chat.feedItemId = UserInfo.getUserId();
            }
            SlackObjects.Message message = new SlackObjects.Message();
            message.text = 'Test Chat Message ' + i;
            chat.messageBody = message;
            messages.add(chat);
        }

        return messages;
    }
    public static Map<String, String> createConversationInfo(Integer numberOfMappings){
        Map<String, String> infoMap = new Map<String, String>();
        for( Integer i = 0; i < numberOfMappings; i++){
            String a = 'key '+i;
            String b = 'value '+i;
            infoMap.put(a, b);
        }
        return infoMap;
    }
    public static List<SlackObjects.Conversation> createSlackConversationWrappers(integer numberOfConversations){
        List<SlackObjects.Conversation> conversations = new List<SlackObjects.Conversation>();
        for(Integer i = 0; i < numberOfConversations; i++){
        	SlackObjects.Conversation conversation = new SlackObjects.Conversation();
            conversation.id = 'id '+i;
            conversation.name = 'name '+i;
            conversation.isDirectMessage = true;
            conversations.add(conversation);
        }
        return conversations;
    }
    public static Map<String, SlackObjects.AllMessages> createMapOfConversationIdToAllMessageWrapper(integer numberOfConversations, integer numberOfMessages){
        Map<String, SlackObjects.AllMessages> returnMap = new Map<String, SlackObjects.AllMessages>();
        for(Integer i = 0; i < numberOfConversations; i++){
        	String conversationId = 'id '+i;
            Set<String> members = new Set<String>();
            List<SlackObjects.Message> mList = new List<SlackObjects.Message>();
            SlackObjects.AllMessages am = new SlackObjects.AllMessages();
            for(Integer j = 0; j < numberOfMessages; j++){
                SlackObjects.Message m = new SlackObjects.Message();
                m.text = 'text '+j;
                m.timestamp = 'timestamp '+j;
                m.type = 'type '+j;
                m.userId = 'slackid';
                mList.add(m);
                members.add('slackid');
            }
            am.members = members;
            am.messages = mList;
            returnMap.put(conversationId, am);
        }
        return returnMap;
    }
    @TestVisible()
    private static void createCustomIndexSetting() {
        UserIndex__c userIndex = new userIndex__c();
        userIndex.Name = 'Index';
        userIndex.Index__c = 0;
        insert userIndex;
    }
}