@isTest
public with sharing class SaveSlackMessageHandlerTest {

    @isTest
    public static void testAddMembersAndMessages(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        Map<String, User> usersMap = new Map<String, User>();
        usersMap.put('ABC123', new User(Id = '0058c00000CHYHuAAP', SlackID__c = 'ABC123'));
        usersMap.put('ABC456', new User(Id = '0058c00000CHYHqWAA', SlackID__c = 'ABC456'));

        String token = 'xopABC123';

        List<SlackMessageObjects.Channel> channels = new List<SlackMessageObjects.Channel>();        
        for(Integer i = 1; i <= 2; i++) {
            SlackMessageObjects.Channel channel = new SlackMessageObjects.Channel();
            channel.id = 'C0ABC10' + i;
            channel.name = 'Channel ' + i;
            channel.is_im = false;
            channels.add(channel);
        }

        List<SlackMessageObjects.FullConversation> slackConversationsToSave = SaveSlackMessageHandler.addMembersAndMessages(channels, usersMap, token);
        System.assertEquals(channels.size(), slackConversationsToSave.size(), 
            'Expected conversations to save ' + channels.size() + '. Actual: ' + slackConversationsToSave.size());
        Test.stopTest();
    }


    @isTest(SeeAllData=true)
    public static void testScheduleSaveConversations(){

        Account account = new Account(Name = 'Test Account');
        insert account;

        Contact contact1 = createContact('Test', 'Contact 1', account.Id, null, false);
        Contact contact2 = createContact('Test', 'Contact 2', account.Id, null, false);
        List<Contact> contacts = new List<Contact>{contact1, contact2};
        insert contacts;

        User user1 = createCommunityUser(contacts[0], 'ABC123', false);
        User user2 = createCommunityUser(contacts[1], 'ABC456', false);
        List<User> users = new List<User>{user1, user2};
        insert users;
        
        SlackMessageObjects.SlackMessage msg = new SlackMessageObjects.SlackMessage();
        msg.textMessage = 'Text Msg 1';
        msg.ts = '123456.789';
        msg.isEdited = false;
        msg.editedTS = 'editedTs';
        msg.slackUserId = users[1].SlackID__c;
        msg.salesforceUserId = users[1].Id;

        List<SlackMessageObjects.FullConversation> conversations = new List<SlackMessageObjects.FullConversation>();
        SlackMessageObjects.FullConversation testConversation = new SlackMessageObjects.FullConversation();
        testConversation.conversationId = 'C0ABC123';
        testConversation.isDMConversation = false;
        testConversation.conversationName = 'TEST';
        testConversation.messages = new List<SlackMessageObjects.SlackMessage>{msg};
        testConversation.members = new String[]{users[0].Id, users[1].Id};
        conversations.add(testConversation);

        Test.startTest();
            String jobId = SaveSlackMessageHandler.scheduleSaveConversations(conversations);
        
            Integer cronTriggerCount = [SELECT COUNT()
                                    FROM CronTrigger WHERE Id = :jobId]; 
            System.assertEquals(1, cronTriggerCount, 'Expected one cron trigger');  
        Test.stopTest();        
    }

    @isTest(SeeAllData=true)
    public static void testSaveSlackConversations(){
        
        Account account = new Account(Name = 'Test Account');
        insert account;

        Contact contact1 = createContact('Test', 'Contact 1', account.Id, null, false);
        Contact contact2 = createContact('Test', 'Contact 2', account.Id, null, false);
        List<Contact> contacts = new List<Contact>{contact1, contact2};
        insert contacts;

        User user1 = createCommunityUser(contacts[0], 'ABC123', false);
        User user2 = createCommunityUser(contacts[1], 'ABC456', false);
        List<User> users = new List<User>{user1, user2};
        insert users;

        List<SlackMessageObjects.SlackMessage> messages = new List<SlackMessageObjects.SlackMessage>();
        for(Integer i = 1; i <= 55; i++){
            SlackMessageObjects.SlackMessage msg = new SlackMessageObjects.SlackMessage();
            msg.textMessage = 'Text Msg ' + i;
            msg.ts = String.valueOf(i);
            msg.isEdited = false;
            msg.editedTS = 'editedTs';
            msg.slackUserId = users[0].SlackID__c;
            msg.salesforceUserId = users[0].Id;

            messages.add(msg);
        }

        for(Integer i = 56; i <= 110; i++){
            SlackMessageObjects.SlackMessage msg = new SlackMessageObjects.SlackMessage();
            msg.textMessage = 'Text Msg ' + i;
            msg.ts = String.valueOf(i);
            msg.isEdited = false;
            msg.editedTS = 'editedTs';
            msg.slackUserId = users[1].SlackID__c;
            msg.salesforceUserId = users[1].Id;

            messages.add(msg);
        }

        List<SlackMessageObjects.FullConversation> conversations = new List<SlackMessageObjects.FullConversation>();
        SlackMessageObjects.FullConversation testConversation = new SlackMessageObjects.FullConversation();
        testConversation.conversationId = 'C0ABC123';
        testConversation.isDMConversation = false;
        testConversation.conversationName = 'TEST';
        testConversation.messages = messages;
        testConversation.members = new String[]{users[0].Id, users[1].Id};

        conversations.add(testConversation);

        Test.startTest();      
        	SaveSlackMessageHandler.saveSlackConversations(conversations);    	
        Test.stopTest();
        
        List<Conversation__c> result = [
            SELECT Id, Conversation_Id__c, Members__c
            FROM Conversation__c
            WHERE Slack_Conversation_Id__c = :testConversation.conversationId];
        System.assert(result.size() > 0, 'There should be 1 conversation saved');
        System.assertEquals(users[0].Id + '' + users[1].Id, result[0].Members__c, 
            'Members field should be populated with users ids');

        Integer msgResult = [SELECT COUNT() 
                            FROM FeedComment 
                            WHERE FeedItemId = :result[0].Conversation_Id__c];
        System.assertEquals(messages.size(), msgResult);
    }

    public static Contact createContact(String firstName, String lastName, 
        String accountId, String recordTypeId, Boolean insertRecord) {
        if (accountId == null) {
          	Account acc = new Account(Name='Test Account');
        	insert acc;
            
            accountId = acc.Id;
        }

        if (recordTypeId == null) {
            recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee').getRecordTypeId();
        }

        Contact contact      = new Contact();
        contact.FirstName    = firstName; 
		contact.Lastname     = lastName; 
        contact.AccountId    = accountId;
        contact.RecordTypeId = recordTypeId;
        contact.Email        = System.now().millisecond() + '@oktSlackTest.com';
        if(insertRecord) {
            insert contact;
        }       
        return contact;
    }
    
    public static User createCommunityUser(Contact contact,
        String slackId, Boolean insertRecord) {
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name='Customer Community User' 
                        LIMIT 1];
        
        User user = new User(
            Alias 		      = contact.FirstName,
            ContactId         = contact.Id,
            Email 		      = contact.Email,
            FirstName         = contact.FirstName,
            LastName 	      = contact.LastName,
            Username 	      = contact.Email,
            LocaleSidKey      = 'en_US',
            ProfileId         = prof.Id,
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey    = 'America/Los_Angeles',
            SlackID__c        = slackId
        );       
        if(insertRecord) {
            insert user;
        }  
        
        return user;
    }

}
