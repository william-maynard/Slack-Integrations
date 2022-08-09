@isTest
public with sharing class SaveSlackMessageScheduleTriggerTest {
    @isTest
    static void schedulerTest(){
        SlackWorkspace__c currentWorkspace = new SlackWorkspace__c();
        currentWorkspace.Name = 'CurrentWorkspace';
        currentWorkspace.SlackWorkspaceId__c = 'T0ABC123';
        currentWorkspace.SlackWorkspaceLabel__c = 'Test Workspace';
        currentWorkspace.channelGeneralId__c = 'C0ABC123';
        insert currentWorkspace;

        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());     
        List<CronTrigger> ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime 
            FROM CronTrigger 
            LIMIT 1];  
        
        String jobId = SaveSlackMessageScheduleTrigger.triggerSaveMessages();

        Test.stopTest();
        CronTrigger job = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime 
            FROM CronTrigger 
            WHERE id = :jobId];
        System.assertEquals(job.TimesTriggered, 0);
    }

    @isTest
    static void schedulerAlternateConstructorTest(){
        SlackWorkspace__c currentWorkspace = new SlackWorkspace__c();
        currentWorkspace.Name = 'CurrentWorkspace';
        currentWorkspace.SlackWorkspaceId__c = 'T0ABC123';
        currentWorkspace.SlackWorkspaceLabel__c = 'Test Workspace';
        currentWorkspace.channelGeneralId__c = 'C0ABC123';
        insert currentWorkspace;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SaveSlackMock());
        List<CronTrigger> ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime 
            FROM CronTrigger 
            LIMIT 1];

        SaveSlackMessageScheduler savingScheduler = new SaveSlackMessageScheduler('Test');
        Datetime dateDT = Datetime.now().addMinutes(1);
        String cron = dateDT.format('ss mm HH dd MM ? yyyy');
        String jobId = System.schedule('Saving Slack Messages Trigger ' + dateDT.getTime(), cron, savingScheduler);
       
        Test.stopTest();
        CronTrigger job = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime 
            FROM CronTrigger 
            WHERE id = :jobId];
        System.assertEquals(job.TimesTriggered, 0);
    }
}
