public with sharing class SlackCalloutsService {
    
    private static final String API_URL = 'https://slack.com/api/';

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
}
