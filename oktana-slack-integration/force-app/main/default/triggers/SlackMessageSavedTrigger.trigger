trigger SlackMessageSavedTrigger on SlackMessageSaved__e (after insert) {
    if(trigger.isAfter && trigger.isInsert){
        SlackMessageSavedTriggerHandler.run();
    }
}