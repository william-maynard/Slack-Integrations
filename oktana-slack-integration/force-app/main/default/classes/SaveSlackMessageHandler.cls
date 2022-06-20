public with sharing class SaveSlackMessageHandler {


    public static List<SlackMessageObjects.FullConversation> addMembersAndMessages( SlackMessageObjects.UserConversationPair pair, 
                                                                                List<SlackMessageObjects.SlackUser> allUsers, String userToken ){
        List<SlackMessageObjects.FullConversation> results = new List<SlackMessageObjects.FullConversation>();
            
        for(String conversationId : pair.conversationIds){
            SlackMessageObjects.FullConversation conversationData = new SlackMessageObjects.FullConversation();

            conversationData.conversationId = conversationId;
            conversationData.errorLogs = new List<Debug_Log__c>();
            String conversationType = '';
            conversationType = getConversationType(conversationId);

            SlackMessageObjects.MemberErrorWrapper memberWrapper = SlackCalloutService.getConversationMembers(conversationId,conversationType,allUsers,userToken);
            conversationData.members = memberWrapper.members;
            if(memberWrapper.errorLog!=null){
                conversationData.errorLogs.add(memberWrapper.errorLog);
            }
            

            if(conversationData.members.size() > 1){
                conversationData.messages = SlackCalloutService.getMessages(pair.userToken,conversationId);
                if(conversationData.messages != null && conversationData.messages.size() > 0){
                    results.add(conversationData);
                }      
            }
        }

        return results;
    } 

    public static void saveSlackConversations(List<SlackMessageObjects.FullConversation> slackConvs) {      
        SlackWorkspace__c  currentWorkspace = SlackWorkspace__c.getValues('CurrentWorkspace');
        String workspaceID = null;
        if(currentWorkspace != null){
            workspaceID = currentWorkspace.SlackWorkspaceId__c;

            List<RecordType> slackConversationRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = :ChatterConstant.SlackConversationRecordTypeDevName];
            List<String> listOfIds = new List<String>();

            List<Debug_log__c> totalDebugLogs =  new List<Debug_log__c>();

            Debug_log__c logError = new Debug_log__c();
            List<String> convId = new List<String>();
            logError.name = 'SaveSlackMessageHandler-saveSlackConversations-Line 77';
            logError.Description__c = 'The conversations to be saved in this queueable are:';

            for(SlackMessageObjects.FullConversation slackConversation : slackConvs){
                listOFIds.add(slackConversation.conversationId);
                convId.add(String.valueOf(slackConversation.conversationId));
            }
            logError.Log_Body__c = String.join(convId, ',');

            totalDebugLogs.add(logError);

            for(Integer i=0;i<slackConvs.size();i++){
                totalDebugLogs.addAll(slackConvs[i].errorLogs);
            }

            try {
                insert totalDebugLogs;
            } catch (Exception e) {
                //throw new AuraHandledException('Error trying to insert debugs');
                system.debug('Error line 65');
                System.debug(e.getMessage());
            }

            List<Conversation__c> existingConversationsOnSF = [SELECT Id, Conversation_Id__c, Message_timestamps__c,Slack_Conversation_Id__c FROM Conversation__c WHERE Slack_Workspace_Id__c = :workspaceID AND Slack_Conversation_Id__c IN :listOfIds];

            List<Network> community = [select id,name from network where name='Tok' limit 1];
            
            if(community.size()>0){
                String communityID = community[0].Id;
                for(SlackMessageObjects.FullConversation slackConversation : slackConvs){

                    //Checking if conversation isnt already saved
                    Conversation__c tokConversation = null;
                    Conversation__c foundConversation = findSlackConversation(existingConversationsOnSF,slackConversation.conversationId);

                    if(foundConversation == null){ // The conversation doesnt exist
                        conversationNoExist(tokConversation, slackConversation, slackConversationRecordType, workspaceID, communityID);         
                    }else{ //conversation exists
                        conversationExist(tokConversation, foundConversation, slackConversation, communityID);
                    }      
                }
            }
        }
    }

    public static String scheduleSaveConversations(List<SlackMessageObjects.FullConversation> conversationsToSave){
        SaveSlackMessageScheduleQueueable savingScheduler = new SaveSlackMessageScheduleQueueable(conversationsToSave);
        Datetime timestamp = Datetime.now().addSeconds(10);
        String cron = '' + timestamp.second() + ' ' + timestamp.minute() + ' ' + timestamp.hour() + ' ' + timestamp.day() + ' ' + timestamp.month() + ' ? 2022';
        String jobId = System.schedule('Saving Slack Messages Queueable ' + timestamp.getTime(), cron, savingScheduler);
        
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

    private static String getConversationType(String conversationId){
        String conversationType = '';

        if(conversationId.startsWith('C')){
            conversationType = 'channels';
        }else{
            conversationType = 'slackDirectMessages';
        }

        return conversationType;
    }

    //Method used in saveSlackConversation if conversation does not exist
    private static void conversationNoExist(Conversation__c tokConversation, SlackMessageObjects.FullConversation slackConversation, List<RecordType> slackConversationRecordType, String workspaceID, String communityID){
        tokConversation = new Conversation__c();
        tokConversation.Slack_Conversation_Id__c = slackConversation.conversationId;
        tokConversation.Slack_Workspace_Id__c = workspaceID;
        if( slackConversationRecordType.size() > 0 ){
            tokConversation.RecordTypeId = slackConversationRecordType[0].Id;
        }else{ // ERROR: RECORD TYPE NOT FOUND
            return;
        }

        //process first message
        ConnectApi.FeedElement message = ConnectAPIController.postFeedDirectMessage(communityID, slackConversation.messages[0].textMessage, slackConversation.members, false);
        tokConversation.Message_timestamps__c = slackConversation.messages[0].ts;
        
        //insert tok conv object
        tokConversation.Conversation_Id__c = message.id;

        try {
            insert tokConversation;
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
                List<SlackMessageObjects.SlackMessage> messages = copySlackMessagesList(slackConversation.messages,beginning,ending);
                SaveSlackMessageQueueable slackMessageQueueable = new SaveSlackMessageQueueable(messages, communityID, message.id, tokConversation);
                System.enqueueJob(slackMessageQueueable);
                i -= ChatterConstant.SLACK_MESSAGES_LIMIT;
                if(i< ChatterConstant.SLACK_MESSAGES_LIMIT){
                    
                    Integer lastBeginning = 0;
                    Integer lastEnding = i;
                    List<SlackMessageObjects.SlackMessage> lastMessages = copySlackMessagesList(slackConversation.messages,lastBeginning,lastEnding);
                    SaveSlackMessageQueueable lastSlackMessageQueueable = new SaveSlackMessageQueueable(lastMessages, communityID, message.id, tokConversation);
                    System.enqueueJob(lastSlackMessageQueueable);
                }
            }
        }else{
            SaveSlackMessageQueueable slackMessageQueueable = new SaveSlackMessageQueueable(slackConversation.messages, communityID, message.id, tokConversation);
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
                List<SlackMessageObjects.SlackMessage> messages = copySlackMessagesList(slackConversation.messages,beginning,ending);
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
