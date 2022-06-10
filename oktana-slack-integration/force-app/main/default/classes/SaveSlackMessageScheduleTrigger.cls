global with sharing class SaveSlackMessageScheduleTrigger {
    global static String triggerSaveMessages(){
        //SaveSlackMessageScheduler savingScheduler = new SaveSlackMessageScheduler();
        //System.schedule('Saving Slack Messages 1', '0 0 * * * ?', savingScheduler);
        //System.schedule('Saving Slack Messages 1', '0 15 * * * ?', savingScheduler);
        //System.schedule('Saving Slack Messages 1', '0 30 * * * ?', savingScheduler);
        //System.schedule('Saving Slack Messages 1', '0 45 * * * ?', savingScheduler);

        SaveSlackMessageScheduler savingScheduler = new SaveSlackMessageScheduler();
        Datetime time1 = Datetime.now().addMinutes(1);
        String cron1 = '' + time1.second() + ' ' + time1.minute() + ' ' + time1.hour() + ' ' + time1.day() + ' ' + time1.month() + ' ? ' + time1.year();
        String jobId = System.schedule('Saving Slack Messages Trigger ' + time1.getTime(), cron1, savingScheduler);
        return jobId;
    }
}
