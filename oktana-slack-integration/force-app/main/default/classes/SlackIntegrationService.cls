/**
* @author Oktana.com
* @date 2022
* @description Slack Integration Service class.
*/
public without sharing class SlackIntegrationService extends ServiceIntegration {
    private String token;

    public SlackIntegrationService(String token) {
        this.token = token;
        setHeader();
    }

    /** 
    * @author Oktana
    * @date 2022
    * @description Set slack request endpoint
    * @params Recieves the endpoint as String.
    * returns HttpResponse object with the results of the request
    */
    public override String setEndpoint(String endpoint) {
        this.endpoint = Constants.SLACK_ENDPOINT + endpoint;
        return this.endpoint;
    }

    /** 
    * @author Oktana
    * @date 2022
    * @description Set slack request headers
    * @params Recieves the endpoint as String.
    * returns HttpResponse object with the results of the request
    */
    public override Map<String,String> setHeader() {
        header = new Map<String, String>();
        header.put(Constants.CALLOUT_HEADER_CONTENT_TYPE, Constants.CALLOUT_HEADER_CONTENT_TYPE_APPLICATION_URLENCODED);
        header.put(Constants.CALLOUT_HEADER_AUTH, Constants.CALLOUT_HEADER_BEARER_AUTH + token);
        return header;
    }

    /** 
    * @author Oktana
    * @date 2022
    * @description Fetch conversations from the slack api.
    * @params Recieves a records limit as Integer, 
    *   and recieves a next cursor as String.
    * returns HttpResponse object with the results of the request
    */
    public HttpResponse fetchConversations(Integer recordsLimit, String nextCursor){
        String typesParams = 'types=public_channel,private_channel,mpim,im';
        String limitParam = '&limit=' + recordsLimit;
        String nextCursorParam = (nextCursor != null && !nextCursor.equals('')) ? '&cursor=' + nextCursor : '';

        String endpoint = 'conversations.list?' + typesParams + limitParam + nextCursorParam ;

        this.setRequest(Constants.HTTP_POST, setEndpoint(endpoint), header);
        this.performCallout();
        
        return this.getResponse();    
    }

    /** 
    * @author Oktana
    * @date 2022
    * @description Fetch members of a conversation from the slack api
    * @params Recieves the conversation id as String.
    * returns HttpResponse object with the results of the request
    */
    public HttpResponse fetchConversationMembers(String conversationId) {

        String endpoint =  'conversations.members?channel=' + conversationId;

        this.setRequest(Constants.HTTP_GET, this.setEndpoint(endpoint), header);
        this.performCallout();

        return this.getResponse();
    }

    /** 
    * @author Oktana
    * @date 2022
    * @description 
    * @params Fetch messages of a conversation from the slack api
    * and the last message id as String.
    * returns HttpResponse object with the results of the request 
    */
    public HttpResponse fetchMessages(String conversationId, String lastMessageId) {

        String oldestParam = (lastMessageId == null || lastMessageId.equals('') ? '' : '&oldest=' + lastMessageId);

        String endpoint = 'conversations.history?channel=' + conversationId + oldestParam;

        this.setRequest(Constants.HTTP_GET, this.setEndpoint(endpoint), header);
        this.performCallout();
        
        return this.getResponse();
    }

    /** 
    * @author Oktana
    * @date 2022
    * @description Fetch users of a workspace from the slack api
    * @params Recieves the id of the workspace as String.
    * returns HttpResponse object with the results of the request
    */
    public HttpResponse fetchUsers(String workspaceId){

        String endpoint = 'users.list?team_id=' + workspaceId;

        this.setRequest(Constants.HTTP_GET, this.setEndpoint(endpoint), header);
        this.performCallout();
        
        return this.getResponse();
    }

    /** 
    * @author Oktana
    * @date 2022
    * @description Send a text message to a conversation using the slack api
    * @params Recieves the conversation id as String
    *   and the message text as String
    * returns HttpResponse object with the results of the request    
    */
    public HttpResponse sendTextMessage(String conversationId, String text) {
        String endpoint =  'chat.postMessage';
        header.put(Constants.CALLOUT_HEADER_CONTENT_TYPE, Constants.CALLOUT_HEADER_CONTENT_TYPE_APPLICATION_JSON);
        String body = '{"channel":"'+ conversationId +'", "text": "' + text + '"}';

        this.setRequestWithBody(Constants.HTTP_POST, this.setEndpoint(endpoint), header, body);
        this.performCallout();
        
        return this.getResponse();
    }
    
}