global class SaveSlackMessageScheduleQueueable implements Schedulable {
    @testVisible
    private List<SaveSlackMessageHandler.FullConversation> conversationsList;

    public SaveSlackMessageScheduleQueueable(List<SaveSlackMessageHandler.FullConversation> convList){
        this.conversationsList = convList;
    }

	global void execute(SchedulableContext sc) {

        SaveSlackMessageHandler.saveSlackConversations(this.conversationsList);
		
	}

}