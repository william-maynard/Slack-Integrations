global class SaveSlackMessageScheduleQueueable implements Schedulable {
    @testVisible
    private List<SlackMessageObjects.FullConversation> conversations;

    public SaveSlackMessageScheduleQueueable(List<SlackMessageObjects.FullConversation> conversations){
        this.conversations = conversations;
    }

	global void execute(SchedulableContext sc) {

        SaveSlackMessageHandler.saveSlackConversations(this.conversations);
		
	}

}