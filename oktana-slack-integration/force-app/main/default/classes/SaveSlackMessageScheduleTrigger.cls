global with sharing class SaveSlackMessageScheduleTrigger {
    global static String triggerSaveMessages(){
        //SaveSlackMessageScheduler savingScheduler = new SaveSlackMessageScheduler();
        //System.schedule('Saving Slack Messages 1', '0 0 * * * ?', savingScheduler);
        //System.schedule('Saving Slack Messages 1', '0 15 * * * ?', savingScheduler);
        //System.schedule('Saving Slack Messages 1', '0 30 * * * ?', savingScheduler);
        //System.schedule('Saving Slack Messages 1', '0 45 * * * ?', savingScheduler);

        SaveSlackMessageScheduler savingScheduler = new SaveSlackMessageScheduler();
        Datetime dateDT = Datetime.now().addMinutes(1);
        String cron = dateDT.format('ss mm HH dd MM ? yyyy');
        String jobId = System.schedule('Saving Slack Messages Trigger ' + dateDT.getTime(), cron, savingScheduler);
        return jobId;
    }
}
