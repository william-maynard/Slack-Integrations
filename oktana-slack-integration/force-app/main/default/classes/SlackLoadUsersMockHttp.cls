@isTest
global class SlackLoadUsersMockHttp implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"ok": true, "members": [{"id":"U1234","profile":{"email":"standarUser@testorg.com"}},{"id":"U5678","profile":{"email":"standarUser2@testorg.com"}}]}');
        response.setStatusCode(200);
        return response;
    }
}