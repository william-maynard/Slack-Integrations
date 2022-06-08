public with sharing class ConectAPIController {
    public static ConnectApi.FeedElement postFeedDirectMessage(String communityId, String messageText, List<String> recipients, List<String> files, Boolean crossOrgOwner) {
        Boolean changeOwnerCrossOrg = false;
        // Define the FeedItemInput object to pass to postFeedElement
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        if (crossOrgOwner) {
            changeOwnerCrossOrg = true;
        } 
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

        if(files != null && !files.isEmpty()){
            feedElementCapabilitiesInput.files = new ConnectApi.FilesCapabilityInput();
            feedElementCapabilitiesInput.files.items = new List<ConnectApi.FileIdInput>();
            for (String contentDocuemntID : files) {
                ConnectApi.FileIdInput content = new ConnectApi.FileIdInput();
                content.id = ChatterDesktopController.getDocumentId(contentDocuemntID);
                feedElementCapabilitiesInput.files.items.add(content);
            }
        }

        feedItemInput.capabilities = feedElementCapabilitiesInput;


        // Post the feed item.
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(communityId, feedItemInput);
        return feedElement;
    }

    public static ConnectApi.Comment updateFeedDirectMessage(String communityId, String feedId, String text, String files) {
		ConnectApi.CommentInput input = new ConnectApi.CommentInput();
		ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
		ConnectApi.TextSegmentInput textSegment;
		textSegment = new ConnectApi.TextSegmentInput();
		textSegment.text = text;
		messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
		messageInput.messageSegments.add(textSegment);
		input.body = messageInput;

		if(files != null){
			ConnectApi.CommentCapabilitiesInput commentCapabilitiesInput = new ConnectApi.CommentCapabilitiesInput();
			ConnectApi.ContentCapabilityInput contentCapabilityInput = new ConnectApi.ContentCapabilityInput();
			commentCapabilitiesInput.content = contentCapabilityInput;
			String documentId = ChatterDesktopController.getDocumentId(files);
			contentCapabilityInput.contentDocumentId = documentId;
			input.capabilities = commentCapabilitiesInput;
		}

		ConnectApi.Comment comment = ConnectApi.ChatterFeeds.postCommentToFeedElement(communityId, feedId, input, null);
		return comment;
	}
}
