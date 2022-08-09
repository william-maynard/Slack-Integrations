public with sharing class SaveSlackMessageHandler {
    public class SlackSavingMessageException extends Exception {

    }
    public static List<SlackMessageObjects.FullConversation> addMembersAndMessages(List<String> conversationsIds, 
                                                                                Map<String, User> usersMap, String userToken ){
        List<SlackMessageObjects.FullConversation> results = new List<SlackMessageObjects.FullConversation>();
            
        for(String conversationId : conversationsIds) {
            SlackMessageObjects.FullConversation conversationData = new SlackMessageObjects.FullConversation();

            conversationData.conversationId = conversationId;
            conversationData.errorLogs = new List<Debug_Log__c>();

            SlackMessageObjects.MemberErrorWrapper memberWrapper = SlackCalloutService.getConversationMembers(conversationId, usersMap, userToken);
            conversationData.members = memberWrapper.members;
            if(memberWrapper.errorLog != null) {
                conversationData.errorLogs.add(memberWrapper.errorLog);
            }
            

            if(conversationData.members.size() > 1) {
                conversationData.messages = SlackCalloutService.getMessages(userToken, conversationId, usersMap);
                if(conversationData.messages != null && conversationData.messages.size() > 0){
                    results.add(conversationData);
                }      
            }
        }

        return results;
    } 

    public static void saveSlackConversations(List<SlackMessageObjects.FullConversation> slackConvs) {      
        SlackWorkspace__c  currentWorkspace = SlackWorkspace__c.getValues('CurrentWorkspace');
        if(currentWorkspace == null) {
            throw new SlackSavingMessageException('Can\'t find SlackWorkspace__c custom setting with name: CurrentWorkspace');
        }
        String workspaceId = currentWorkspace.SlackWorkspaceId__c;

        RecordType slackConversationRecordType = getSlackConversationRecordType();
        List<String> listOfIds = new List<String>();

        List<Debug_log__c> totalDebugLogs =  new List<Debug_log__c>();

        Debug_log__c logError = new Debug_log__c();
        logError.name = 'SaveSlackMessageHandler-saveSlackConversations-Line 77';
        logError.Description__c = 'The conversations to be saved in this queueable are:';

        for(SlackMessageObjects.FullConversation slackConversation : slackConvs){
            if(slackConversation.errorLogs != null && slackConversation.errorLogs.size() > 0) {
                totalDebugLogs.addAll(slackConversation.errorLogs);
            }
            listOFIds.add(slackConversation.conversationId);
        }
        logError.Log_Body__c = String.join(listOFIds, ',');

        totalDebugLogs.add(logError);

        try {
            insert totalDebugLogs;
        } catch (Exception e) {
            //throw new AuraHandledException('Error trying to insert debugs');
            system.debug('Error line 65');
            System.debug(e.getMessage());
        }

        List<Conversation__c> existingConversationsOnSF = [
            SELECT Id, Conversation_Id__c, Message_timestamps__c,Slack_Conversation_Id__c 
            FROM Conversation__c 
            WHERE Slack_Workspace_Id__c = :workspaceID 
            AND Slack_Conversation_Id__c IN :listOfIds];

        String communityId = getCommunityIdByName('Tok');
            
        for(SlackMessageObjects.FullConversation slackConversation : slackConvs){
            //Checking if conversation isnt already saved
            Conversation__c tokConversation = null;
            Conversation__c foundConversation = findSlackConversation(existingConversationsOnSF, slackConversation.conversationId);

            if(foundConversation == null){ // The conversation doesnt exist
                conversationNoExist(tokConversation, slackConversation, slackConversationRecordType, workspaceID, communityId);         
            } else{ //conversation exists
                conversationExist(tokConversation, foundConversation, slackConversation, communityId);
            }      
        }
    }

    private static RecordType getSlackConversationRecordType() {
        List<RecordType> result = [
            SELECT Id 
            FROM RecordType 
            WHERE DeveloperName = :ChatterConstant.SlackConversationRecordTypeDevName];
        
        if (result.size() == 0) {
            throw new SlackSavingMessageException('Can\'t find Slack Conversation Record Type');
        }

        return result[0];
    }

    private static String getCommunityIdByName(String name) {
        List<Network> community = [SELECT Id, Name 
                                FROM Network 
                                WHERE Name = :name
                                Limit 1];

        if(community.size() == 0) {
            throw new SlackSavingMessageException('Can\'t find Community with name: ' + name);
        }
        return community[0].Id;
    }

    public static String scheduleSaveConversations(List<SlackMessageObjects.FullConversation> conversationsToSave){
        SaveSlackMessageScheduleQueueable savingScheduler = new SaveSlackMessageScheduleQueueable(conversationsToSave);
        Datetime dateDT = Datetime.now().addSeconds(10);
        String cron = dateDT.format('ss mm HH dd MM ? yyyy');
        String jobId = System.schedule('Saving Slack Messages Queueable ' + dateDT.getTime(), cron, savingScheduler);
        
        return jobId; 
    }

    public static List<SlackMessageObjects.SlackMessage> copySlackMessagesList(List<SlackMessageObjects.SlackMessage> theList, Integer firstIndex, Integer lastIndex){
        
        List<SlackMessageObjects.SlackMessage> result = new List<SlackMessageObjects.SlackMessage>();

        for(Integer i = lastIndex-1; i>=firstIndex; i--){
            result.add(theList[i]);
        }

        return result;
    }

    public static Conversation__c findSlackConversation(List<Conversation__c> slackConvs, String slackId) {

        for(Conversation__c conversation : slackConvs){
            if(conversation.Slack_Conversation_Id__c == slackId){
                return conversation;
            }
        }
        return null;
    }

    //Method used in saveSlackConversation if conversation does not exist
    private static void conversationNoExist(Conversation__c conversation, SlackMessageObjects.FullConversation slackConversation, RecordType slackConversationRecordType, String workspaceID, String communityID){
        conversation = new Conversation__c();
        conversation.Slack_Conversation_Id__c = slackConversation.conversationId;
        conversation.Slack_Workspace_Id__c = workspaceID;
        conversation.Members__c = String.join(slackConversation.members, '');
        conversation.RecordTypeId = slackConversationRecordType.Id;
        
        //process first message
        ConnectApi.FeedElement message = ConnectAPIController.postFeedDirectMessage(communityID, slackConversation.messages[0].textMessage, slackConversation.members, false);
        conversation.Message_timestamps__c = slackConversation.messages[0].ts;
        
        //insert tok conv object
        conversation.Conversation_Id__c = message.id;

        try {
            insert conversation;
        } catch (Exception e) {        
           // throw new  AuraHandledException('Error trying to insert the conversation')
            System.debug('Error line 164');
            System.debug(e.getMessage());
        }

        //process rest of messages

        Integer i = slackConversation.messages.size();
        if(i > ChatterConstant.SLACK_MESSAGES_LIMIT){
            while((i / ChatterConstant.SLACK_MESSAGES_LIMIT ) >= 1){
                Integer beginning = i - ChatterConstant.SLACK_MESSAGES_LIMIT;
                Integer ending = i;
                List<SlackMessageObjects.SlackMessage> messages = copySlackMessagesList(slackConversation.messages, beginning, ending);
                SaveSlackMessageQueueable slackMessageQueueable = new SaveSlackMessageQueueable(messages, communityID, message.id, conversation);
                System.enqueueJob(slackMessageQueueable);
                i -= ChatterConstant.SLACK_MESSAGES_LIMIT;
                if(i< ChatterConstant.SLACK_MESSAGES_LIMIT){
                    
                    Integer lastBeginning = 0;
                    Integer lastEnding = i;
                    List<SlackMessageObjects.SlackMessage> lastMessages = copySlackMessagesList(slackConversation.messages,lastBeginning,lastEnding);
                    SaveSlackMessageQueueable lastSlackMessageQueueable = new SaveSlackMessageQueueable(lastMessages, communityID, message.id, conversation);
                    System.enqueueJob(lastSlackMessageQueueable);
                }
            }
        } else {
            SaveSlackMessageQueueable slackMessageQueueable = new SaveSlackMessageQueueable(slackConversation.messages, communityID, message.id, conversation);
            System.enqueueJob(slackMessageQueueable);
        }
    }

    //Method used in saveSlackConversation if conversation exist
    private static void conversationExist(Conversation__c tokConversation, Conversation__c foundConversation, SlackMessageObjects.FullConversation slackConversation, String communityID){
        tokConversation = foundConversation;
        Integer i = slackConversation.messages.size();
        if(i>ChatterConstant.SLACK_MESSAGES_LIMIT){
            while((i / ChatterConstant.SLACK_MESSAGES_LIMIT ) >= 1){
                Integer beginning = i - ChatterConstant.SLACK_MESSAGES_LIMIT;
                Integer ending = i;
                List<SlackMessageObjects.SlackMessage> messages = copySlackMessagesList(slackConversation.messages, beginning, ending);
                SaveSlackMessageQueueable slackMessageQueueable = new SaveSlackMessageQueueable(messages, communityID, tokConversation.Conversation_Id__c, tokConversation);
                System.enqueueJob(slackMessageQueueable);
                i -= ChatterConstant.SLACK_MESSAGES_LIMIT;
                if(i< ChatterConstant.SLACK_MESSAGES_LIMIT){
                
                    Integer lastBeginning = 0;
                    Integer lastEnding = i;
                    List<SlackMessageObjects.SlackMessage> lastMessages = copySlackMessagesList(slackConversation.messages,lastBeginning,lastEnding);
                    SaveSlackMessageQueueable lastSlackMessageQueueable = new SaveSlackMessageQueueable(lastMessages, communityID, tokConversation.Conversation_Id__c, tokConversation);
                    System.enqueueJob(lastSlackMessageQueueable);
                }
            }
        }else{
            SaveSlackMessageQueueable slackMessageQueueable = new SaveSlackMessageQueueable(slackConversation.messages, communityID, tokConversation.Conversation_Id__c, tokConversation);
            System.enqueueJob(slackMessageQueueable);
        }
    }

}
