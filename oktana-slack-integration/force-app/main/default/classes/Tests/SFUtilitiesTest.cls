@isTest
private without sharing class SFUtilitiesTest { 

    @TestSetup
    static void setup(){
        TestDataFactory.updateActiveLocalUsersToInActive();
    }

    @isTest
    private static void givenAListOfUsersGetFirstUserWithToken() {
        TestDataFactory.insertStandardUsersWithSlackToken(2);
        User userResponse = SFUtilities.getUserWithToken(0);
        //The token changes for each itaration in the last digit
        System.assertEquals('xoxp-3598964873479-3615963368372-3757017684002-b6c4aae94ffc7782311012616b9db0fc-0', userResponse.User_Token__c);
    }

    @isTest
    private static void indexFirstInterationTest(){
        TestDataFactory.createCustomIndexSetting();
        Integer index = SFUtilities.getIterationIndex();
        System.assertEquals(0, index);
    }

    @isTest
    private static void IndexNextInterationTest(){
        TestDataFactory.createCustomIndexSetting();
        Integer index = SFUtilities.getIterationIndex();
        index = index + 1;
        SFUtilities.setIterationIndex(index);
        Integer index2 = SFUtilities.getIterationIndex();
        System.assertEquals(1, index2);
    }
}
