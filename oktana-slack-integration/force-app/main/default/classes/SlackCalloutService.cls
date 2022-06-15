public with sharing class SlackCalloutService {
    public static SlackMessageObjects.UserConversationPair getsConversationIds(String token, String nextCursor, Integer limitRecords){
        SlackMessageObjects.UserConversationPair pair = new SlackMessageObjects.UserConversationPair();
        pair.userToken = token;
        //fetch conversations from API
        String limitStr = String.valueOf(limitRecords);
        String nextCursorStr = (nextCursor != null) ? '&cursor=' + nextCursor : '';
        String endpoint = 'https://slack.com/api/conversations.list' + '?token=' + token + '&types=public_channel,private_channel,im&limit='+ limitStr + nextCursorStr ;
        Http http = new Http();
        Map<String, String> headers = new Map<String, String>();
        headers.put('Accept', 'application/x-www-form-urlencoded');
        headers.put('Content-Type','application/x-www-form-urlencoded');
        HttpRequest req = setRequest('POST', headers , endpoint);	
        HttpResponse response = http.send(req);
        //We need to set nextcursor for recursive structure of code
        Map<String, Object> conversationResults = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        if(conversationResults.containsKey('error')){
            return null;
        }else{
            pair.conversationIds = getConversationIds(conversationResults);
            pair.nextCursor = getNextCursor(conversationResults);
        }
        System.debug(pair);
        
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
        String endpoint = 'https://slack.com/api/conversations.history' + '?token=' + token + '&channel=' + conversationId + '&limit=500';

        Http http = new Http();
        Map<String, String> headers = new Map<String, String>();
        headers.put('Accept', 'application/x-www-form-urlencoded');
        headers.put('Content-Type','application/x-www-form-urlencoded');
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

    public static SlackMessageObjects.MemberErrorWrapper getConversationMembers(String conversationId, String convType, List<SlackMessageObjects.SlackUser> users, String userToken){
        SlackMessageObjects.MemberErrorWrapper memberWrapper = new SlackMessageObjects.MemberErrorWrapper();
        List<String> members = new List<String>();

        Debug_Log__c logError = null;

        String endpoint = 'https://slack.com/api/conversations.members' + '?token=' + userToken + '&channel=' + conversationId;
        Http http = new Http();
        Map<String, String> headers = new Map<String, String>();
        headers.put('Accept', 'application/x-www-form-urlencoded');
        headers.put('Content-Type','application/x-www-form-urlencoded');

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