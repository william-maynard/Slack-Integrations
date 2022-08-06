public with sharing class SlackCalloutService {

    private static final String API_URL = 'https://slack.com/api/';

    public static SlackMessageObjects.UserConversationPair getConversationPairs(String token, String nextCursor, Integer limitRecords){
        SlackMessageObjects.UserConversationPair pair = new SlackMessageObjects.UserConversationPair();
        pair.userToken = token;
        //fetch conversations from API
        String limitStr = String.valueOf(limitRecords);
        String nextCursorStr = (nextCursor != null) ? '&cursor=' + nextCursor : '';
        String endpoint = API_URL  + 'conversations.list?types=public_channel,private_channel,im&limit='+ limitStr + nextCursorStr ;
        Http http = new Http();
        Map<String, String> headers = new Map<String, String>();
        headers.put('Accept', 'application/x-www-form-urlencoded');
        headers.put('Content-Type','application/x-www-form-urlencoded');
        headers.put('Authorization', 'Bearer ' + token);
        HttpRequest req = setRequest('POST', headers , endpoint);	
        HttpResponse response = http.send(req);
        //We need to set nextcursor for recursive structure of code
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        if(result.containsKey('error')){
            return null;
        }

        pair.conversationIds = getConversationIds(result);
        pair.nextCursor = getNextCursor(result);
        
        return pair;
    }

    @TestVisible
    private static String getNextCursor(Map<String, Object> conversationResults){
        if(conversationResults.containsKey('response_metadata')){
            Map<String, Object> responseMetadata = (Map<String, Object>)JSON.deserializeUntyped(System.JSON.serialize(conversationResults.get('response_metadata')));
            if(responseMetadata.containsKey('next_cursor')){
                System.debug((String)responseMetadata.get('next_cursor'));
                if( (String)responseMetadata.get('next_cursor') !='' && (String)responseMetadata.get('next_cursor') !=' '){
                    return (String)responseMetadata.get('next_cursor');                        
                }
            }
        }
        return null;
    }

    @TestVisible
    private static String[] getConversationIds(Map<String, Object> conversationResults){
        String[] conversationids = new String[]{};
        List<Object> channels = (List<Object> )JSON.deserializeUntyped(System.JSON.serialize(conversationResults.get('channels')));
        for(Object channelObject : channels){
            Map<String, Object> channelItem = (Map<String, Object>)System.JSON.deserializeUntyped(System.JSON.serialize(channelObject));                    
            conversationids.add((String)channelItem.get('id'));
        }
        return conversationids;
    }

    public static List<SlackMessageObjects.SlackMessage> getMessages(String token, String conversationId){
        Datetime limitDateTime = Datetime.now().addDays(-1);
        Long limitTimestamp = Long.valueOf(''+limitDateTime.getTime()/1000);
        String endpoint = API_URL + 'conversations.history?channel=' + conversationId + '&limit=500';

        Http http = new Http();
        Map<String, String> headers = new Map<String, String>();
        headers.put('Accept', 'application/x-www-form-urlencoded');
        headers.put('Content-Type','application/x-www-form-urlencoded');
        headers.put('Authorization', 'Bearer ' + token);
        HttpRequest req = setRequest('POST', headers , endpoint);
        HttpResponse response = http.send(req);

        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        List<Object> messagesListObject = (List<Object> )JSON.deserializeUntyped(System.JSON.serialize(results.get('messages')));
        List<SlackMessageObjects.SlackMessage> messages = setMessages(messagesListObject);

        return messages;
    }

    @TestVisible
    private static List<SlackMessageObjects.SlackMessage> setMessages(List<Object> messagesListObject){
        List<SlackMessageObjects.SlackMessage> messages = new List<SlackMessageObjects.SlackMessage>();

        for(Object messageObj : messagesListObject){
            Map<String, Object> messageItem = (Map<String, Object>)System.JSON.deserializeUntyped(System.JSON.serialize(messageObj));
            SlackMessageObjects.SlackMessage parsedMessage =  new SlackMessageObjects.SlackMessage();
            if(messageItem.get('type') != null && (String)messageItem.get('type') == 'message' && messageItem.get('subtype') == null){
                if(messageItem.get('edited') != null){
                    Map<String, Object> editedMap = (Map<String, Object>)System.JSON.deserializeUntyped(System.JSON.serialize(messageItem.get('edited')));
                    parsedMessage.editedTs = (String)editedMap.get('ts');
                    parsedMessage.isEdited = true;
                }
                parsedMessage.textMessage = (String)messageItem.get('text');
                parsedMessage.ts = (String)messageItem.get('ts');
                parsedMessage.slackUserId = (String)messageItem.get('user');
                if(parsedMessage.textMessage != '' && parsedMessage.textMessage != null){
                    messages.add(parsedMessage);
                }
            }
        }      
        return messages;    
    }

    public static SlackMessageObjects.MemberErrorWrapper getConversationMembers(String conversationId, List<SlackMessageObjects.SlackUser> users, String userToken){
        SlackMessageObjects.MemberErrorWrapper memberWrapper = new SlackMessageObjects.MemberErrorWrapper();
        List<String> members = new List<String>();

        Debug_Log__c logError = null;

        String endpoint = API_URL + 'conversations.members?channel=' + conversationId;
        Http http = new Http();
        Map<String, String> headers = new Map<String, String>();
        headers.put('Accept', 'application/x-www-form-urlencoded');
        headers.put('Content-Type','application/x-www-form-urlencoded');
        headers.put('Authorization', 'Bearer ' + userToken);
        HttpRequest req = setRequest('GET', headers , endpoint);
        HttpResponse response = http.send(req);

        Map<String, Object> membersResults = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        if(membersResults.containsKey('error')){
            return null;
        }else{
            List<Object> membersList = (List<Object> )JSON.deserializeUntyped(System.JSON.serialize(membersResults.get('members')));
            for(Object memberObject : membersList){
                String salesforceID = SlackUtils.getSalesforceId(memberObject,users);                    
                if(salesforceID != null && salesforceID != '' && !members.contains(salesforceID)){
                    members.add(salesforceID);
                }
            }
            if(members.size() <= 1){
                logError = new Debug_Log__c();
                logError.name = 'SaveSlackMessageHandler-getConversationMembers-line 379';
                logError.Description__c = 'Conversation ' + String.valueOf(conversationId) + ' does not have enough members on Salesforce: ';
                logError.Log_Body__c = String.valueOf(membersList);
            } else{
                logError = new Debug_Log__c();
                logError.name = 'SaveSlackMessageHandler-getConversationMembers-line 384';
                logError.Description__c = 'Conversation ' + String.valueOf(conversationId) + ' will be added with members: ';
                logError.Log_Body__c = String.valueOf(membersList);
            }
        }
        memberWrapper.members = members;
        memberWrapper.errorLog = logError;
        return memberWrapper;
    }

    public static List<SlackMessageObjects.SlackUser> getSlackUsers(String token, String workspaceId){

        List<SlackMessageObjects.SlackUser> slackUsers = new List<SlackMessageObjects.SlackUser>();

        String endpoint = API_URL + 'users.list?team_id=' + workspaceId;
        Http http = new Http();
        Map<String, String> headers = new Map<String, String>();
        headers.put('Accept', 'application/x-www-form-urlencoded');
        headers.put('Content-Type','application/x-www-form-urlencoded');
        headers.put('Authorization', 'Bearer ' + token);
        HttpRequest req = setRequest('GET', headers , endpoint);
        HttpResponse response = http.send(req);
        Map<String, Object> usersResults = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

        if(usersResults.containsKey('error')){
            return null;
        }
            
        List<Object> usersListObject = (List<Object> )JSON.deserializeUntyped(System.JSON.serialize(usersResults.get('members')));
        for(Object userObj : usersListObject){
                Map<String, Object> userMap = (Map<String, Object>)System.JSON.deserializeUntyped(System.JSON.serialize(userObj));
                String userId = (String)userMap.get('id');
                Map<String, Object> userProfileMap = (Map<String, Object>)System.JSON.deserializeUntyped(System.JSON.serialize(userMap.get('profile')));
                String email = (String)userProfileMap.get('email');
                SlackMessageObjects.SlackUser slackUser = new SlackMessageObjects.SlackUser();
                slackUser.slackUserID = userId;
                slackUser.email = email;
                slackUsers.add(slackUser);
        }

        return slackUsers;
    }

    

    public static SlackMessageObjects.SendMessageResponse sendMessage(String token, String channelId, String text) {
        String endpoint = API_URL + 'chat.postMessage';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type','application/json');
        request.setHeader('Authorization','Bearer ' + token);
        request.setBody('{"channel":"'+ channelId +'", "text": "' + text + '"}');
        HttpResponse apiResponse = http.send(request);

        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(apiResponse.getBody());
        SlackMessageObjects.SendMessageResponse response = new SlackMessageObjects.SendMessageResponse();
        response.ok = (Boolean) result.get('ok');
        if (response.ok) {
            response.ts = (String) result.get('ts');
        } else {
            response.error = (String) result.get('error');
        }
        System.debug(response);
        return response;
    }

    @TestVisible
    private static HttpRequest setRequest(String method, Map<String, String> headers, String endpoint){
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        for(String key : headers.keySet()){
             request.setHeader(key, headers.get(key));
        }
        request.setEndpoint(endpoint);	

        return request;
    }

    
}