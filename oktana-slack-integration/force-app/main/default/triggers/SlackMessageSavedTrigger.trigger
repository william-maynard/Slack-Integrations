trigger SlackMessageSavedTrigger on SlackMessageSaved__e (after insert) {
    System.debug('im in trigger');
    if(trigger.isAfter && trigger.isInsert){
        SlackMessageSavedTriggerHandler.run();
    }
}