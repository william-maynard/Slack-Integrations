global class SaveSlackMessageScheduleQueueable implements Schedulable {
    @testVisible
    private List<SlackMessageObjects.FullConversation> conversationsList;

    public SaveSlackMessageScheduleQueueable(List<SlackMessageObjects.FullConversation> convList){
        this.conversationsList = convList;
    }

	global void execute(SchedulableContext sc) {

        //SaveSlackMessageHandler.saveSlackConversations(this.conversationsList);
		
	}

}