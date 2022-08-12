@isTest
public class SaveSlackMessageScheduleQueueableTest {
    
    @isTest(seeAllData=true)
    static void testingSchedule() {

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
        testConversation.conversationName = 'TEST';
        testConversation.isDMConversation = false;
        testConversation.messages = new List<SlackMessageObjects.SlackMessage>{msg};
        testConversation.members = new String[]{users[0].Id, users[1].Id};
        conversations.add(testConversation);

        Test.startTest();
        SaveSlackMessageScheduleQueueable myClass = new SaveSlackMessageScheduleQueueable(conversations);   
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, myClass);
        Test.stopTest();

        SlackMessageObjects.FullConversation[] retrievedList = myClass.conversations;

        System.assertEquals('C0ABC123', retrievedList[0].conversationId);
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
