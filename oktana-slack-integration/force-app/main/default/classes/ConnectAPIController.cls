public with sharing class ConnectAPIController {
    /** @description postFeedDirectMessage this methods is sent a message to a list of recipients
     * @param communityID the id of the community
	 * @param text the text that a user sent to another user
     * @param recipients the users who will receive the message 
     * @param changeOwnerCrossOrg flag to know which feedItem has to change its owner
     * @return a FeedElement Object With all the details of the conversation
     * */
    public static ConnectApi.FeedElement postFeedDirectMessage(String communityId, String messageText, List<String> recipients, Boolean changeOwnerCrossOrg) {
        // Define the FeedItemInput object to pass to postFeedElement
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = messageText;

        // The MessageBodyInput object holds the text in the post
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;

        // The FeedElementCapabilitiesInput object holds the capabilities of the feed item.
        // For this feed item, we define a direct message capability to hold the member(s) and the subject.

        ConnectApi.DirectMessageCapabilityInput dmInput = new ConnectApi.DirectMessageCapabilityInput();
        if (changeOwnerCrossOrg)//we add a flag to know which feedItem has to change its owner
            dmInput.subject = 'Starting crossorg conversation';
        dmInput.membersToAdd = recipients;

        ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
        feedElementCapabilitiesInput.directMessage = dmInput;

        feedItemInput.capabilities = feedElementCapabilitiesInput;

        // Post the feed item.
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(communityId, feedItemInput);
        return feedElement;
    }

    /** @description updateFeedDirectMessage this methods is used to reply a direct message
     * @param communityID the id of the community
     * @param feedId the id of the conversation
	 * @param text the text that a user sent to another user
     * @return a Comment Object With all the details of the message  
     * */
    public static ConnectApi.Comment updateFeedDirectMessage(String communityId, String feedId, String text) {
		ConnectApi.CommentInput commentInput = new ConnectApi.CommentInput();
		ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
		ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
		textSegment.text = text;
		messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
		messageBodyInput.messageSegments.add(textSegment);
		commentInput.body = messageBodyInput;

		ConnectApi.Comment comment = ConnectApi.ChatterFeeds.postCommentToFeedElement(communityId, feedId, commentInput, null);
		return comment;
	}
}
