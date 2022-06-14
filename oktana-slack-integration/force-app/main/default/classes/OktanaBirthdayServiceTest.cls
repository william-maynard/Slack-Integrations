@isTest
public with sharing class OktanaBirthdayServiceTest {
    @isTest
    private static void getMentionsTest() {
        List<User> users = new List<User>();
        for(Integer i = 1; i <= 3; i++) {
            users.add(new User(SlackID__c = 'AAAAAAA' + i));
        }
        String result = OktanaBirthdayService.getMentions(users);

        String expected = '<@AAAAAAA1>, <@AAAAAAA2>, <@AAAAAAA3>, ';
        System.assertEquals(expected, result);
    }
    
    @isTest
    private static void getMessageTest() {
        List<User> users = new List<User>();
        for(Integer i = 1; i <= 3; i++) {
            users.add(new User(SlackID__c = 'AAAAAAA' + i));
        }
        // Test for Type BIRTHDAY
        String result1 = OktanaBirthdayService.getMessage(OktanaBirthdayService.Type.BIRTHDAY, users);
        String expected1 = 'Happy Birthday <@AAAAAAA1>, <@AAAAAAA2>, <@AAAAAAA3>, from your Oktana family! 🎂';
        System.assertEquals(expected1, result1);
        
        // Test for Type OKTANA_BIRTHDAY
        String result2 = OktanaBirthdayService.getMessage(OktanaBirthdayService.Type.OKTANA_BIRTHDAY, users);
        String expected2 = 'Happy Oktaversary <@AAAAAAA1>, <@AAAAAAA2>, <@AAAAAAA3>, we’re so happy you’re part of Oktana! 🎉';
        System.assertEquals(expected2, result2);
    }
    
    @isTest
    private static void getUsersTest() {
        //Create account
        Account acc = new Account(Name = 'TestAccount');
        insert(acc);
        
        Id contactEmployeeRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee').getRecordTypeId();
        //Create contact and user for oktana birthday
        Contact testContact1 = buildContact(acc.Id, contactEmployeeRecordTypeId);
        testContact1.okty_rrhh__StartDate__c = System.today().addYears(-1);
        insert testContact1;
        createUser(testContact1);
        
        //Create contact and user for birthday
        Contact testContact2 = buildContact(acc.Id, contactEmployeeRecordTypeId);
        testContact2.Birthdate = System.today().addYears(-1);
        insert testContact2;
        createUser(testContact2);

        Map<OktanaBirthdayService.Type,List<User>> result = OktanaBirthdayService.getUsers();
        System.assert(result.get(OktanaBirthdayService.Type.OKTANA_BIRTHDAY).size() > 0);
        System.assert(result.get(OktanaBirthdayService.Type.BIRTHDAY).size() > 0);
    }
    
    @isTest
    private static void sayMessageOnSlackTest() {
        //Create account
        Account acc = new Account(Name = 'TestAccount');
        insert(acc);
        
        Id contactEmployeeRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee').getRecordTypeId();
        //Create contact and user for oktana birthday
        Contact testContact1 = buildContact(acc.Id, contactEmployeeRecordTypeId);
        testContact1.okty_rrhh__StartDate__c = System.today().addYears(-1);
        insert testContact1;
        createUser(testContact1);
        
        //Create contact and user for birthday
        Contact testContact2 = buildContact(acc.Id, contactEmployeeRecordTypeId);
        testContact2.Birthdate = System.today().addYears(-1);
        insert testContact2;
        createUser(testContact2);
        // create custom setting
        createCustomSetting();
        
        Test.setMock(HttpCalloutMock.class, new SlackCalloutsServiceMock()); 
        Test.startTest();
        OktanaBirthdayService.sayBirthdayOnSlack();
        Test.stopTest();
    }
    
    private static Contact buildContact(String accountId, String recordTypeId) {
        Contact testContact = new Contact();
        testContact.FirstName = 'User'; 
		testContact.Lastname = 'Test'; 
        testContact.AccountId = accountId;
        testContact.RecordTypeId = recordTypeId;
        testContact.Email = System.now().millisecond() + '@oktSlackTest.com';        
        
        return testContact;
    }
    
    private static User createUser(Contact testContact) {
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User user = new User(
            Alias 		 = 'testUser',
            Email 		 = testContact.Email,
            LastName 	 = 'LastName',
            Username 	 = testContact.Email,
            LocaleSidKey = 'en_US',
            ProfileId    = prof.Id,
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey    = 'America/Los_Angeles',
            okty_rrhh__ContactId__c = testContact.Id,
            SlackID__c = 'ABCD123'
        );       
        insert user;
        
        return user;
    }
    
    private static SlackWorkspace__c createCustomSetting() {
        SlackWorkspace__c setting = new SlackWorkspace__c();
		setting.Name = 'CurrentWorkspace';
		setting.channelGeneralId__c = 'ABC123';
		insert setting;
        
        return setting;
    }
}