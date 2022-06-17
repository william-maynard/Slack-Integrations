public with sharing class SlackUtils {

    public static List<SlackMessageObjects.SlackUser> mapSlackIdsToAllUsers(List<User> chatterUsersList){
        List<SlackMessageObjects.SlackUser> results = new List<SlackMessageObjects.SlackUser>();
        
        SlackWorkspace__c  currentWorkspace = SlackWorkspace__c.getValues('CurrentWorkspace');
        
        if(currentWorkspace != null){
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
