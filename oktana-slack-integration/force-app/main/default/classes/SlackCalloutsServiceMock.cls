@isTest
global class SlackCalloutsServiceMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"ok": true, "channel": "AAAAAAAAAA1", "ts": "1655154135.667139", "message": {}}');
        response.setStatusCode(200);
        return response; 
    }
}