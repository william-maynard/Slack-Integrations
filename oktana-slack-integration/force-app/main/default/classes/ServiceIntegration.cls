public abstract class ServiceIntegration {
    private HttpRequest request;
    private HttpResponse response;
    private String endpoint;
    private Map<String,String> header;
    /** 
    * @author Oktana
    * @date 2022
    * @description Set a callout endpoint for Slack Integration.
    * @params Recieves a string with the remaining endpoint path.
    */
    public virtual String setSlackEndpoint(string endpointPath){
        endpoint = Constants.SLACK_ENDPOINT + endpointPath;
        return endpoint;
    }
    /** 
    * @author Oktana
    * @date 2022
    * @description Set Header map for HTTP callout.
    */
    public virtual Map<String,String> setHeader(){
        Map<String,String> header = new Map<String,String>();
        return header;
    }
    /** 
    * @author Oktana
    * @date 2022
    * @description Build the HTTP Request with endpoint, method and header.
    * @params Recieves a Constant-Value as method String, 
    *   recieves the output of setSlackEndpoint as String,
    *   and recieves the output of setHeader as a Map.
    */
    public virtual HttpRequest setRequest(String method, String endpoint, Map<String,String> header){
        request = new HttpRequest();
        request.setMethod(method);
        for(String key : header.keySet()){
            request.setHeader(key, header.get(key));
        }
        request.setEndpoint(endpoint);
        return request;
    }
    /** 
    * @author Oktana
    * @date 2022
    * @description Build the HTTP Request with endpoint, method, header, and body.
    * @params Recieves a Constant-Value as method String, 
    *   recieves the output of setSlackEndpoint as String,
    *   recieves the output of setHeader as a Map,
    *   and recieves a string for Request Body.
    */
    public virtual HttpRequest setRequestWithBody(String method, String endpoint, Map<String,String> header, String body){
        request = new HttpRequest();
        request.setMethod(method);
        for(String key : header.keySet()){
            request.setHeader(key, header.get(key));
        }
        request.setEndpoint(endpoint);
        request.setBody(body);
        return request;
    }
    /** 
    * @author Oktana
    * @date 2022
    * @description Send request to endpoint.
    */
    public void performCallout(){
        this.response = new Http().send(request);
    }
    /** 
    * @author Oktana
    * @date 2022
    * @description Return callout response.
    */
    public virtual HttpResponse getResponse(){
        return response;
    }
}
