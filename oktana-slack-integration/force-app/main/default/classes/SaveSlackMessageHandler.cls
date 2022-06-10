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

            SlackMessageObjects.MemberErrorWrapper memberWrapper = getConversationMembers(conversationId,conversationType,allUsers,userToken);
            conversationData.members = memberWrapper.members;
            if(memberWrapper.errorLog!=null){
                conversationData.errorLogs.add(memberWrapper.errorLog);
            }
            

            if(conversationData.members.size() > 1){
                conversationData.messages = getMessages(pair.userToken,conversationId);
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

            insert totalDebugLogs;
            /*
            System.debug('The conversations to be saved in this queueable are:');
            for(FullConversation slackConversation : slackConvs){
                listOFIds.add(slackConversation.conversationId);
                //System.debug(slackConversation.conversationId);
                convId.add(String.valueOf(slackConversation.conversationId));
            }
            */

            List<Conversation__c> existingConversationsOnSF = [SELECT Id, Conversation_Id__c, Message_timestamps__c,Slack_Conversation_Id__c FROM Conversation__c WHERE Slack_Workspace_Id__c = :workspaceID AND Slack_Conversation_Id__c IN :listOfIds];

            List<Network> community = [select id,name from network where name='Tok' limit 1];
            
            if(community.size()>0){
                String communityID = community[0].Id;
                for(SlackMessageObjects.FullConversation slackConversation : slackConvs){

                    //Checking if conversation isnt already saved
                    Conversation__c tokConversation = null;
                    Conversation__c foundConversation = findSlackConversation(existingConversationsOnSF,slackConversation.conversationId);

                    if(foundConversation == null){ // The conversation doesnt exist
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

                        insert tokConversation;

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
            
                    }else{
                        //conversation exists
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

    /*
    *   METHOD TO DELETE
    */
    public static SlackMessageObjects.MemberErrorWrapper getConversationMembers(String conversationId, String convType, 
                                                                                List<SlackMessageObjects.SlackUser> users, String userToken){
        Debug_Log__c errorLog = new Debug_Log__c();
        errorLog.name = 'SaveSlackMessageHandler-getConversationMembers-line 384';
        errorLog.Description__c = 'Conversation ' + String.valueOf(conversationId) + ' will be added with members: ';
        errorLog.Log_Body__c = 'menbersList';

        List<String> members = new List<String>();
        members.add('12');
        members.add('3');

        SlackMessageObjects.MemberErrorWrapper error = new SlackMessageObjects.MemberErrorWrapper();
        error.members = members;
        error.errorLog = errorLog;

        return error;
        // SlackMessageObjects.MemberErrorWrapper memberWrapper = new SlackMessageObjects.MemberErrorWrapper();
        // List<String> members = new List<String>();

        // Debug_Log__c logError = null;

        // String endpoint = 'https://slack.com/api/conversations.members' + '?token=' + userToken + '&channel=' + conversationId;
        // Http http = new Http();
        // HttpRequest req = new HttpRequest();
        // req.setMethod('GET');
        // req.setHeader('Accept', 'application/x-www-form-urlencoded');
        // req.setHeader('Content-Type','application/x-www-form-urlencoded');
        // req.setEndpoint(endpoint);	
        // HttpResponse response = http.send(req);

        // Map<String, Object> membersResults = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        // if(membersResults.containsKey('error')){
        //     return null;
        // }else{
        //     List<Object> membersList = (List<Object> )JSON.deserializeUntyped(System.JSON.serialize(membersResults.get('members')));
        //     for(Object memberObject : membersList){
        //         String salesforceID = getSalesforceId(memberObject,users);                    
        //         if(salesforceID != null && salesforceID != '' && !members.contains(salesforceID)){
        //             members.add(salesforceID);
        //         }
        //     }
        //     if(members.size() <= 1){
        //         logError = new Debug_Log__c();
        //         logError.name = 'SaveSlackMessageHandler-getConversationMembers-line 379';
        //         logError.Description__c = 'Conversation ' + String.valueOf(conversationId) + ' does not have enough members on Salesforce: ';
        //         logError.Log_Body__c = String.valueOf(membersList);
        //     } else{
        //         logError = new Debug_Log__c();
        //         logError.name = 'SaveSlackMessageHandler-getConversationMembers-line 384';
        //         logError.Description__c = 'Conversation ' + String.valueOf(conversationId) + ' will be added with members: ';
        //         logError.Log_Body__c = String.valueOf(membersList);
        //     }
        // }
        // memberWrapper.members = members;
        // memberWrapper.errorLog = logError;
        // return memberWrapper;
    }

    /*
    *   METHOD TO DELETE
    */
    public static List<SlackMessageObjects.SlackMessage> getMessages(String token, String conversationId){
        List<SlackMessageObjects.SlackMessage> messages = new List<SlackMessageObjects.SlackMessage>();
        SlackMessageObjects.SlackMessage message = new SlackMessageObjects.SlackMessage();
        message.textMessage = 'Test Message';
        message.ts = 'ts';
        message.isEdited = false;
        message.editedTs = 'ts editeable';
        message.slackUserId = '12';

        messages.add(message);

        return messages;
        // List<SlackMessage> messages = new List<SlackMessage>();
        // Datetime limitDateTime = Datetime.now().addDays(-1);
        // Long limitTimestamp = Long.valueOf(''+limitDateTime.getTime()/1000);
        // String messagesEndpoint = 'https://slack.com/api/conversations.history' + '?token=' + token + '&channel=' + conversationId + '&limit=500';

        // Http http = new Http();
        //     HttpRequest req = new HttpRequest();
        //     req.setMethod('POST');
        //     req.setHeader('Accept', 'application/x-www-form-urlencoded');
        //     req.setHeader('Content-Type','application/x-www-form-urlencoded'); 
        //     req.setEndpoint(messagesEndpoint);
        //     HttpResponse response = http.send(req);
        //     Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        //     List<Object> messagesListObject = (List<Object> )JSON.deserializeUntyped(System.JSON.serialize(results.get('messages')));
        //     for(Object messageObj : messagesListObject){
        //         Map<String, Object> messageItem = (Map<String, Object>)System.JSON.deserializeUntyped(System.JSON.serialize(messageObj));
        //         SlackMessage parsedMessage =  new SlackMessage();
        //         if(messageItem.get('type') != null && (String)messageItem.get('type') == 'message' && messageItem.get('subtype') == null){
        //             if(messageItem.get('edited') != null){
        //                 Map<String, Object> editedMap = (Map<String, Object>)System.JSON.deserializeUntyped(System.JSON.serialize(messageItem.get('edited')));
        //                 parsedMessage.editedTs = (String)editedMap.get('ts');
        //                 parsedMessage.isEdited = true;
        //             }
        //             parsedMessage.textMessage = (String)messageItem.get('text');
        //             parsedMessage.ts = (String)messageItem.get('ts');
        //             parsedMessage.slackUserId = (String)messageItem.get('user');
        //             if(parsedMessage.textMessage != '' && parsedMessage.textMessage != null){
        //                 messages.add(parsedMessage);
        //             }
        //         }
        //     }       
        // return messages;
    }

}
