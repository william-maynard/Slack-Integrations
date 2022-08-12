public with sharing class SlackCalloutService {

    private static final String API_URL = 'https://slack.com/api/';

    public static SlackMessageObjects.GetConversationsResponse getConversations(String token, String nextCursor, Integer limitRecords){
        String limitStr = String.valueOf(limitRecords);
        String nextCursorStr = (nextCursor != null) ? '&cursor=' + nextCursor : '';
        String endpoint = API_URL  + 'conversations.list?types=public_channel,private_channel,im&limit='+ limitStr + nextCursorStr ;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Accept', 'application/x-www-form-urlencoded');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        HttpResponse response = http.send(request);
        
        SlackMessageObjects.GetConversationsResponse customResponse = new SlackMessageObjects.GetConversationsResponse();
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        Boolean ok = (Boolean) result.get('ok');
        customResponse.ok = ok;
        if(!ok){
            customResponse.error = (String) result.get('error');
            return customResponse;
        }

        if(result.containsKey('response_metadata')) {
            Map<String, Object> responseMetadata = (Map<String, Object>)JSON.deserializeUntyped(System.JSON.serialize(result.get('response_metadata')));
            customResponse.nextCursor = (String)responseMetadata.get('next_cursor');
        }

        String channelsJson = JSON.serialize(result.get('channels'));
        customResponse.channels = (List<SlackMessageObjects.Channel>) JSON.deserialize(
            channelsJson, List<SlackMessageObjects.Channel>.class);        

        return customResponse;
    }

    public static List<SlackMessageObjects.SlackMessage> getMessages(String token, String conversationId, Map<String, User> usersMap){
        Datetime limitDateTime = Datetime.now().addDays(-1);
        Long limitTimestamp = Long.valueOf(''+limitDateTime.getTime()/1000);
        String endpoint = API_URL + 'conversations.history?channel=' + conversationId + '&limit=500';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/x-www-form-urlencoded');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        request.setHeader('Authorization', 'Bearer ' + token);
        HttpResponse response = http.send(request);

        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        List<Object> messagesListObject = (List<Object> )JSON.deserializeUntyped(JSON.serialize(results.get('messages')));
        List<SlackMessageObjects.SlackMessage> messages = setMessages(messagesListObject, usersMap);

        return messages;
    }

    @TestVisible
    private static List<SlackMessageObjects.SlackMessage> setMessages(List<Object> messagesObject, Map<String, User> usersMap){
        List<SlackMessageObjects.SlackMessage> messages = new List<SlackMessageObjects.SlackMessage>();

        for(Integer i = (messagesObject.size() - 1); i >= 0; i--) {
            Map<String, Object> messageItem = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(messagesObject.get(i)));

            SlackMessageObjects.SlackMessage parsedMessage =  new SlackMessageObjects.SlackMessage();
            if(messageItem.get('type') != null && (String)messageItem.get('type') == 'message' && messageItem.get('subtype') == null){
                if(messageItem.get('edited') != null){
                    Map<String, Object> editedMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(messageItem.get('edited')));
                    parsedMessage.editedTs = (String)editedMap.get('ts');
                    parsedMessage.isEdited = true;
                }
                parsedMessage.textMessage = (String)messageItem.get('text');
                parsedMessage.ts = (String)messageItem.get('ts');
                parsedMessage.slackUserId = (String)messageItem.get('user');
                if(usersMap.containsKey(parsedMessage.slackUserId)) {
                    parsedMessage.salesforceUserId = usersMap.get(parsedMessage.slackUserId).Id;
                }

                if(parsedMessage.textMessage != '' && parsedMessage.textMessage != null){
                    messages.add(parsedMessage);
                }
            }
        }
        return messages;    
    }

    public static SlackMessageObjects.MemberErrorWrapper getConversationMembers(String conversationId, Map<String, User> usersMap, String userToken){
        SlackMessageObjects.MemberErrorWrapper memberWrapper = new SlackMessageObjects.MemberErrorWrapper();
        List<String> members = new List<String>();

        Debug_Log__c logError = null;

        String endpoint = API_URL + 'conversations.members?channel=' + conversationId;
        Http http = new Http();        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + userToken);
        request.setHeader('Accept', 'application/x-www-form-urlencoded');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');

        HttpResponse response = http.send(request);

        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        Boolean ok = (Boolean) result.get('ok');
       
        if(!ok){
            return null;
        }

        List<String> membersIds = (List<String> )JSON.deserialize(JSON.serialize(result.get('members')), List<String>.class);
        for(String memberId : membersIds){
            if(usersMap.containsKey(memberId)) {
                members.add(usersMap.get(memberId).Id);
            }
        }

        if(members.size() <= 1){
            logError = new Debug_Log__c();
            logError.name = 'SaveSlackMessageHandler-getConversationMembers-line 379';
            logError.Description__c = 'Conversation ' + String.valueOf(conversationId) + ' does not have enough members on Salesforce: ';
            logError.Log_Body__c = String.valueOf(members);
        } else{
            logError = new Debug_Log__c();
            logError.name = 'SaveSlackMessageHandler-getConversationMembers-line 384';
            logError.Description__c = 'Conversation ' + String.valueOf(conversationId) + ' will be added with members: ';
            logError.Log_Body__c = String.valueOf(members);
        }
        
        memberWrapper.members = members;
        memberWrapper.errorLog = logError;
        return memberWrapper;
    }


    public static SlackMessageObjects.GetUsersResponse getSlackUsers(String token, String workspaceId){

        SlackMessageObjects.GetUsersResponse getUsersResponse = new SlackMessageObjects.GetUsersResponse();

        String endpoint = API_URL + 'users.list?team_id=' + workspaceId;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Accept', 'application/x-www-form-urlencoded');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        HttpResponse response = http.send(request);

        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        Boolean ok = (Boolean) result.get('ok');
        getUsersResponse.ok = ok;

        if(!ok){
            getUsersResponse.error = (String) result.get('error');
            return getUsersResponse;
        }

        getUsersResponse.users = new List<SlackMessageObjects.User>();
        
        List<Object> members = (List<Object>)JSON.deserializeUntyped(JSON.serialize(result.get('members')));
        
        for(Object member : members) {
            Map<String, Object> memberMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(member));
            SlackMessageObjects.User user = new SlackMessageObjects.User();
            user.id =  (String) memberMap.get('id');
            user.name = (String) memberMap.get('name');
            user.realName = (String) memberMap.get('real_name');

            Map<String, Object> profileMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(memberMap.get('profile')));
            user.email = (String) profileMap.get('email');

            getUsersResponse.users.add(user);
        }

        
        return getUsersResponse;
    }

    public static SlackMessageObjects.SendMessageResponse sendMessage(String token, String channelId, String text) {
        String endpoint = API_URL + 'chat.postMessage';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setHeader('Authorization','Bearer ' + token);
        request.setHeader('Content-Type','application/json');
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
        return response;
    }

    
}