/**
* @author Oktana.com
* @date 2022
* @description Conversation Service class.
*/
public without sharing class ConversationService {
    
    @TestVisible
    private ConnectAPIIntegrationService connectAPIIntegrationService {
        get {
            if(connectAPIIntegrationService == null) {
                connectAPIIntegrationService = new ConnectAPIIntegrationService();
            }
            return connectAPIIntegrationService;
        }
        set { 
            connectAPIIntegrationService = value;
        }
    }

    @TestVisible
    private ConversationSelector conversationSelector {
        get {
            if(conversationSelector == null) {
                conversationSelector = new ConversationSelector();
            }
            return conversationSelector;
        }
        set { 
            conversationSelector = value;
        }
    }

    /** @description Post a list of messages
     * @param messages List of chat messages to be posted
     * */
    public void postMessages(List<SlackObjects.Chat> messages) {
        
        List<SlackObjects.Chat> newMessages = new List<SlackObjects.Chat>();
        List<SlackObjects.Chat> newComments = new List<SlackObjects.Chat>();

        for (SlackObjects.Chat message : messages) {
            if(message.feedItemId == NULL) {
                newMessages.add(message);
            } else {
                newComments.add(message);
            }
        }

        if(!newMessages.isEmpty()) {
            postBulkMessages(newMessages);
        }

        if(!newComments.isEmpty()) {
            postBulkCommentsToMessages(newComments);
        }
    }

    /** @description Get Convertation details
     * @param conversationIds Set of Slack Conversation Ids
     * @return Map of Slack Convertation Ids and Conversation Details
     * */
    public Map<String, SlackObjects.ConversationDetails> getSFConversations(Set<String> conversationIds) {
        Map<String, SlackObjects.ConversationDetails> cDetails = new Map<String, SlackObjects.ConversationDetails>();

        for(Conversation__c conversation : conversationSelector.getConversationsBySlackConversationIds(conversationIds)) {
            SlackObjects.ConversationDetails cDetail = new SlackObjects.ConversationDetails();
            cDetail.lastMessageId = conversation.Slack_Conversation_Id__c;
            cDetail.feedItemId = conversation.Conversation_Id__c;
            cDetails.put(conversation.Slack_Conversation_Id__c, cDetail);
        }

        return cDetails;
    }

    /** @description process the list of messages to be posted
     * @param messages List of chat messages
     * */
    private void postBulkMessages(List<SlackObjects.Chat> messages) {
        
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

        for (SlackObjects.Chat message : messages) {

            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.subjectId = UserInfo.getUserId();
            
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
            body.messageSegments = new List<ConnectApi.MessageSegmentInput>();

            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = message.messageBody.text;

            body.messageSegments.add(textSegment);
            input.body = body;

            ConnectApi.DirectMessageCapabilityInput dmInput = new ConnectApi.DirectMessageCapabilityInput();
            dmInput.membersToAdd = new List<Id>(message.SFUserId);

            ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
            feedElementCapabilitiesInput.directMessage = dmInput;
            input.capabilities = feedElementCapabilitiesInput;

            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
            batchInputs.add(batchInput);
        }

        if(!batchInputs.isEmpty()) {
            connectAPIIntegrationService.postToChatter(batchInputs);
        } 
    }

    /** @description process the list of comments to be posted
     * @param messages List of chat messages
     * */
    private void postBulkCommentsToMessages(List<SlackObjects.Chat> messages) {
		
        Map<Id, List<ConnectApi.CommentInput>> feedItemComments = new Map<Id, List<ConnectApi.CommentInput>>();
        for (SlackObjects.Chat message : messages) {
            if(message.feedItemId != NULL) {
                ConnectApi.CommentInput commentInput = new ConnectApi.CommentInput();
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = message.messageBody.text;
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>{textSegment};
                commentInput.body = messageBodyInput;

                List<ConnectApi.CommentInput> comments = feedItemComments.get(message.feedItemId);
                if(comments == NULL) {
                    comments = new List<ConnectApi.CommentInput>();
                }
                comments.add(commentInput);
                feedItemComments.put(message.feedItemId, comments);

            }
            
        }

        if(!feedItemComments.isEmpty()) {
            connectAPIIntegrationService.postToChatter(feedItemComments);
        }
	}
}