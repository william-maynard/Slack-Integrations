public without sharing class SlackIntegrationService {

    private static final String API_URL = 'https://slack.com/api/';

    public static HttpResponse fetchConversations(String token, Integer recordsLimit, String nextCursor){
        String limitStr = String.valueOf(recordsLimit);
        String nextCursorStr = (nextCursor != null) ? '&cursor=' + nextCursor : '';
        String endpoint = API_URL  + 'conversations.list?types=public_channel,private_channel,mpim,im&limit='+ limitStr + nextCursorStr ;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Accept', 'application/x-www-form-urlencoded');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        
        return http.send(request);
        
    }

    public static HttpResponse fetchMessages(String token, String conversationId){
        
        String endpoint = API_URL + 'conversations.history?channel=' + conversationId + '&limit=500';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/x-www-form-urlencoded');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        request.setHeader('Authorization', 'Bearer ' + token);
        
        return http.send(request);

    }

    public static HttpResponse fetchConversationMembers(String token, String conversationId) {

        String endpoint = API_URL + 'conversations.members?channel=' + conversationId;
        Http http = new Http();        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Accept', 'application/x-www-form-urlencoded');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');

        return http.send(request);

    }


    public static HttpResponse fetchUsers(String token, String workspaceId){

        String endpoint = API_URL + 'users.list?team_id=' + workspaceId;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Accept', 'application/x-www-form-urlencoded');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        
        return http.send(request);
    }

    public static HttpResponse sendTextMessage(String token, String conversationId, String text) {
        String endpoint = API_URL + 'chat.postMessage';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setHeader('Authorization','Bearer ' + token);
        request.setHeader('Content-Type','application/json');
        request.setBody('{"channel":"'+ conversationId +'", "text": "' + text + '"}');
        
        return http.send(request);

    }

    
}