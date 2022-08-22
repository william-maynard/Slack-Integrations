public abstract class ServiceIntegration {
    private HttpRequest request;
    private HttpResponse response;
    private String endpoint;
    private Map<String,String> header;
    public virtual String setSlackEndpoint(string endpointPath){
        endpoint = Constants.SLACK_ENDPOINT + endpointPath;
        return endpoint;
    }
    public virtual Map<String,String> setHeader(){
        Map<String,String> header = new Map<String,String>();
        return header;
    }
    public virtual HttpRequest setRequest(String method, String endpoint, Map<String,String> header){
        request = new HttpRequest();
        request.setMethod(method);
        for(String key : header.keySet()){
            request.setHeader(key, header.get(key));
        }
        request.setEndpoint(endpoint);
        return request;
    }
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
    public void performCallout(){
        this.response = new Http().send(request);
    }
    public virtual HttpResponse getResponse(){
        return response;
    }
}
