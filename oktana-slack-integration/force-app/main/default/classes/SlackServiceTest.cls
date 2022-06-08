@isTest
private with sharing class SlackServiceTest {

    @isTest(SeeAllData=true)
    private static void TestGetSlackToken() {
        String tokens = SlackService.getSlackToken();
        System.assertEquals((tokens != ''), true);     
    }
}