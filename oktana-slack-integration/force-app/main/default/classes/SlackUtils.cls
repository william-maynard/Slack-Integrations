public with sharing class SlackUtils {

    public static List<SlackMessageObjects.SlackUser> mapSlackIdsToAllUsers(List<User> chatterUsersList){
        List<SlackMessageObjects.SlackUser> results = new List<SlackMessageObjects.SlackUser>();

        Boolean ver = verifyWorkspace();
        
        if(ver){
            for(User chatterUser : chatterUsersList){
                if(chatterUser.SlackID__c != null){
                    SlackMessageObjects.SlackUser mapUser = new SlackMessageObjects.SlackUser();
                    //mapUser.token = (String)tokenItem.get('accessToken');
                    mapUser.salesforceUserId = chatterUser.Id;
                    mapUser.slackUserId = chatterUser.SlackID__c;
                    results.add(mapUser);
                }
            }
        }
        return results;
    }
    
    private static Boolean verifyWorkspace(){
        
        SlackWorkspace__c  currentWorkspace = SlackWorkspace__c.getValues('CurrentWorkspace');
        String workspaceLabel = null;
    
        if(currentWorkspace != null){
    
            workspaceLabel = currentWorkspace.SlackWorkspaceLabel__c;
            String tokenString = '{"tokens":[{"slackUserId":"U03EY7KMV3R","accessToken":"xoxp-3525214328980-3508257743127-3523040523586-2a293bff380dd63342b7d207fb9081c8","workspace":"OktanaDemo"}]}';
            Object slackTokensJson = JSON.deserializeUntyped(tokenString);
            Map<String,Object> mresults = (Map<String, Object>)System.JSON.deserializeUntyped(System.JSON.serialize(slackTokensJson));
            Object tokens = mresults.get('tokens');
            //tokens it's a json with all the tokens for a user using this structure: accessToken, slackUserId, workspace
            List<Object> tokensList = new List<Object>();
            tokensList = (List<Object>)System.JSON.deserializeUntyped(System.JSON.serialize(tokens));
    
            for (Integer i = (tokensList.size()-1) ; i>= 0 ; i--){
                Map<String, Object> tokenItem = (Map<String, Object>)System.JSON.deserializeUntyped(System.JSON.serialize(tokensList[i]));
                String workspace = (String)tokenItem.get('workspace');
                if(workspace.equals(workspaceLabel)){
                    return true;
                }
            }
        }

        return false;
    }

    public static String getNewMessageTimestampField( String oldTimestamp, String timestampToInsert){
		// The field has a max capacity of 131072, each timestamp has 17 chars + 1 for the comma
		// We can support 131072/18 = 7281 total message timestamps, once we reach this we eliminate the oldest 5281 timestamps
		if( oldTimestamp.length() + timestampToInsert.length() > ChatterConstant.MAX_FIELD_LENGTH ){
			// To eliminate the oldest we have to cut the string after the first comma in the index 5281 * 18 = 95058
			return oldTimestamp.substring( oldTimestamp.indexOf(',', ChatterConstant.MAX_CHARS_UNTIL_TS_FIELD_RESET ) + 1 ) + ',' + timestampToInsert;
		}else{
			return oldTimestamp + ',' + timestampToInsert;
		}
	}

    public static String getSalesforceId(Object slackId, List<SlackMessageObjects.SlackUser> users){
        String salesforceID = '';
        for(SlackMessageObjects.SlackUser us : users){
            if(us.slackUserId == (String)slackId){
                salesforceID = us.salesforceUserId;
                break;
            }
        }   
        return salesforceID;
    }

    public static Conversation__c findSlackConversation(List<Conversation__c> slackConvs, String slackId) {

        for(Conversation__c conversation : slackConvs){
            if(conversation.Slack_Conversation_Id__c == slackId){
                return conversation;
            }
        }
        return null;
    }

    public static List<SlackMessageObjects.SlackMessage> copySlackMessagesList(List<SlackMessageObjects.SlackMessage> theList, Integer firstIndex, Integer lastIndex){
        
        List<SlackMessageObjects.SlackMessage> result = new List<SlackMessageObjects.SlackMessage>();

        for(Integer i = lastIndex-1; i>=firstIndex; i--){
            result.add(theList[i]);
        }
        return result;
    }
}
