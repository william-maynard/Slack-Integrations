public without sharing class SlackMessageSavedTriggerHandler {
    public static void run(){
        SlackMessageCollector smc = new SlackMessageCollector();
        smc.collect();
    }
}
