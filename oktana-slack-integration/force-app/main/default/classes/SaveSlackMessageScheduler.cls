global with sharing class SaveSlackMessageScheduler implements Schedulable, Database.AllowsCallouts {

    private String nextCursor = null;

	global SaveSlackMessageScheduler(){
		this.nextCursor = null;
	}

    global SaveSlackMessageScheduler(String newNextCursor){
		this.nextCursor = newNextCursor;
    }
    
    global void execute(SchedulableContext sc) {

		//SaveSlackMessageScheduleHandler.saveSlackMessagesAllUsers();
		
	}
}
