@isTest
public with sharing class SaveSlackMessageScheduleTriggerTest {
    @isTest
    static void schedulerTest(){
        Test.startTest();      
        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger LIMIT 1];
        String jobId = SaveSlackMessageScheduleTrigger.triggerSaveMessages();
        List<CronTrigger> emptyList = new List<CronTrigger>();
        System.assertEquals(emptyList,ct);     

        Test.stopTest();
        CronTrigger job = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(job.TimesTriggered, 0);
    }

    @isTest
    static void schedulerAlternateConstructorTest(){
        Test.startTest();      
        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger LIMIT 1];

        SaveSlackMessageScheduler savingScheduler = new SaveSlackMessageScheduler('Test');
        Datetime time1 = Datetime.now().addMinutes(1);
        String cron1 = '' + time1.second() + ' ' + time1.minute() + ' ' + time1.hour() + ' ' + time1.day() + ' ' + time1.month() + ' ? ' + time1.year();
        String jobId = System.schedule('Saving Slack Messages Trigger ' + time1.getTime(), cron1, savingScheduler);
        
        List<CronTrigger> emptyList = new List<CronTrigger>();
        System.assertEquals(emptyList,ct);     
       
        Test.stopTest();
        CronTrigger job = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(job.TimesTriggered, 0);
    }
}
