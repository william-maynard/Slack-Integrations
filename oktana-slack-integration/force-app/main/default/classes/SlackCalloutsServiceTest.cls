@isTest
public with sharing class SlackCalloutsServiceTest {
    
    @isTest
    private static void sendMessageTest() {
        Test.setMock(HttpCalloutMock.class, new SlackCalloutsServiceMock()); 
        // Set Params
        String token = 'aaaa1-bbbb2-cccc3-dddd4';
        String channelId = 'AAAAAAAAAA1';
        String text = 'Test Message';
        // Make fake callout
        SlackMessageObjects.SendMessageResponse response = SlackCalloutService.sendMessage(token, channelId, text);
        // Verify that the response received contains fake values
        System.assert(response.ok, 'Ok attribute should be true');
        String expected = '1655154135.667139';
        System.assertEquals(expected, response.ts);
    }
    
    @isTest
    private static void sendMessageErrorTest() {
        Test.setMock(HttpCalloutMock.class, new SlackCalloutsServiceErrorMock()); 
        // Set Params
        String token = 'aaaa1-bbbb2-cccc3-dddd4';
        String channelId = 'AAAAAAAAAA2';
        String text = 'Test Message';
        // Make fake callout
        SlackMessageObjects.SendMessageResponse response = SlackCalloutService.sendMessage(token, channelId, text);
        // Verify that the response received contains fake values
        System.assert(!response.ok, 'Ok attribute should be false');
        System.assert(response.ts == null);
        String expected = 'channel_not_found';
        System.assertEquals(expected, response.error);
    }
}