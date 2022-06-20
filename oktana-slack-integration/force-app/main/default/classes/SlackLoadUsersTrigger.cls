global class SlackLoadUsersTrigger {
    global static String triggerLoadUsers(){

        ScheduleLoadSlackUsers loadSlackIdScheduler = new ScheduleLoadSlackUsers();
        Datetime time1 = Datetime.now();
        String cronLoad = '0 0 3 * * ? *';
        String jobId = System.schedule('Load Slack Ids ' + time1.getTime(), cronLoad, loadSlackIdScheduler);
        return jobId;

    }
}
