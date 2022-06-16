@isTest
public with sharing class SlackLoadUsersTest {



    private static List<User> createStandardUser(Integer amount) {
        
        List<User> usersToInsert = new List<User>();
        String userName = 'standarUser@testorg.com';
        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

        for(Integer i = 0; i < amount; i++){

            Long time = Datetime.now().getTime();
            
            User user = new User(
                Alias 		 = 'testUser',
                Email 		 = USER_EMAIL,
                LastName 	 = 'LastName',
                Username 	 = USER_EMAIL + time,
                LocaleSidKey = 'en_US',
                ProfileId    = prof.Id,
                EmailEncodingKey  = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey    = 'America/Los_Angeles'
            );  
            usersToInsert.add(user);
        }
             
        insert usersToInsert;
        
        return usersToInsert;
    }
}
