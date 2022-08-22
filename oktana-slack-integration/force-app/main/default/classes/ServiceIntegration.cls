public abstract class ServiceIntegration {
    private HttpRequest request;
    private HttpResponse response;
    public virtual HttpRequest setRequest(){
        request = new HttpRequest();
        return request;
    }
    public void performCallout(){
        this.response = new Http().send(request);
    }
    public virtual HttpResponse getResponse(){
        return response;
    }
}
