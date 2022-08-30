@isTest
private without sharing class UserServiceTest {

    @TestSetup
    static void setup(){
        TestDataFactory.updateActiveLocalUsersToInActive();
    }
    
    @isTest
    private static void getTheFirstNexUserTest(){
        TestDataFactory.insertStandardUsersWithSlackToken(2);
   		TestDataFactory.createCustomIndexSetting();
        
        Test.startTest();
        User user1 = UserService.getNexUser();
        //The token changes for each itaration in the last digit
        System.assertEquals('xoxp-3598964873479-3615963368372-3757017684002-b6c4aae94ffc7782311012616b9db0fc-0', user1.User_Token__c);
        Test.stopTest();
    }

    @isTest
    private static void getTheSecondNexUserTest(){
        TestDataFactory.insertStandardUsersWithSlackToken(2);
   		TestDataFactory.createCustomIndexSetting();
        
        Test.startTest();
        UserService.setNextUser();
        User user2 = UserService.getNexUser();
        //The token changes for each itaration in the last digit
        System.assertEquals('xoxp-3598964873479-3615963368372-3757017684002-b6c4aae94ffc7782311012616b9db0fc-1', user2.User_Token__c);
        Test.stopTest();
    }

    @isTest
    public static void setNextUserTest(){
        TestDataFactory.createCustomIndexSetting();
        UserService.setNextUser();

        Integer index = SFUtilities.getIterationIndex();
        System.assertEquals(1, index);
    }
}
