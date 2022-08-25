public without sharing class ConvserationServiceAdapter implements IConversationAdapter {
    private List<ConnectApiService.ChatMessage> chatMessages;
    private ConnectAPIService.ChatMessage connectMessage = new ConnectAPIService.ChatMessage();
    private SlackObjects.ConversationChatMessages conversationMessages = new SlackObjects.ConversationChatMessages();
    private Set<String> slackConversationIds;
    private List<SlackObjects.ConversationChatMessages> conversationList;
    public void postMessage(Map<String, SlackObjects.ConversationChatMessages> conversationChatMessages){
        chatMessages = buildMessages(conversationChatMessages);
        ConnectAPIService.postMessages(chatMessages);
    }
    public Map<String, SlackObjects.ConversationDetails> fetchConversationDetails(Map<String, SlackObjects.Conversation> conversations){
        return ConnectApiService.fetchConversationDetails(conversations.keySet());
    }
    private List<ConnectApiService.ChatMessage> buildMessages(Map<String, SlackObjects.ConversationChatMessages> conversationChatMessages){
        slackConversationIds = conversationChatMessages.keySet();
        for(String key : slackConversationIds){
            conversationMessages = conversationChatMessages.get(key);
            conversationList.add(conversationMessages);
        }
        return createChatMessage(conversationList);
    }
    private List<ConnectAPIService.ChatMessage> createChatMessage(List<SlackObjects.ConversationChatMessages> conversationsList){
        for(SlackObjects.ConversationChatMessages ccm : conversationList){
            connectMessage.feedId = ccm.feedItemId;
            connectMessage.recipients = ccm.members;
            for(SlackObjects.Messages message : ccm.messages){
                connectMessage.messageBody = message;
                chatMessages.add(connectMessage);
            }
        }
        return chatMessages;
    }
}