@isTest
public with sharing class SaveSlackMessageScheduleTriggerTest {
    @isTest
    static void schedulerTest(){
        Test.startTest();      
        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger LIMIT 1];
        String jobId = SaveSlackMessageScheduleTrigger.triggerSaveMessages();
        List<CronTrigger> emptyList = new List<CronTrigger>();
        System.assertEquals(emptyList,ct);     
       
        //System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
        CronTrigger job = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(job.TimesTriggered, 0);
    }
}
