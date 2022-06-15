@isTest
global class SlackCalloutsServiceErrorMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"ok": false, "error": "channel_not_found", "warning": "missing_charset"}');
        response.setStatusCode(200);
        return response; 
    }
}