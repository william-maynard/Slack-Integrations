public with sharing class SlackCalloutsService {
    // TODO: get token from custom metadata
    private static final String TOKEN = 'xoxb-3613828084480-3639337527302-IHQWaBFvlFWbM5G8Robx1jb5';
    
    private static final String API_URL = 'https://slack.com/api/';

    public static void sendMessage(String channelId, String text) {
        String endpoint = API_URL + 'chat.postMessage';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type','application/json');
        request.setHeader('Authorization','Bearer ' + TOKEN);
        request.setBody('{"channel":"'+ channelId +'", "text": "' + text + '"}');
        HttpResponse response = http.send(request);
        
        // Parse the JSON response
        if(response.getStatusCode() != 200) {
            System.debug('Error sending message. Status: ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
    }
}
