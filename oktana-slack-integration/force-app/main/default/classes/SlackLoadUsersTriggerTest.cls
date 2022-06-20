@isTest
public with sharing class SlackLoadUsersTriggerTest {
    
    @isTest
    static void schedulerTest(){
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new SlackLoadUsersMockHttp());     
        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger LIMIT 1];  
        
        String jobId = SlackLoadUsersTrigger.triggerLoadUsers();

        Test.stopTest();
        CronTrigger job = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(job.TimesTriggered, 0);
    }
}
