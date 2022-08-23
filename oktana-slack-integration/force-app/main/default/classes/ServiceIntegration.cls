public abstract class ServiceIntegration {
    protected HttpRequest request;
    protected HttpResponse response;
    protected String endpoint;
    protected Map<String,String> header;
    /** 
    * @author Oktana
    * @date 2022
    * @description Set a callout endpoint for Slack Integration.
    * @params Recieves a string with the remaining endpoint path.
    */
    protected virtual String setEndpoint(String endpoint){return endpoint;}
    /** 
    * @author Oktana
    * @date 2022
    * @description Set Header map for HTTP callout.
    */
    protected virtual Map<String,String> setHeader(){return header;}
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
