@isTest
global class SlackLoadUsersMockHttp implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"ok": true, '
            + '"members": [{"id":"U1234", "name": "user.test", "real_name": "test real name", "profile":{"email":"standaruser@testorg.com"}}]}');
        response.setStatusCode(200);
        return response;
    }
}