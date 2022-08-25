public without sharing class ConvserationServiceAdapter implements IConversationAdapter {
    private List<ConnectApiService.ChatMessage> chatMessages;
    private ConnectAPIService.ChatMessage connectMessage = new ConnectAPIService.ChatMessage();
    private SlackObjects.ConversationChatMessages conversationMessages = new SlackObjects.ConversationChatMessages();
    private Set<String> slackConversationIds;
    private Set<String> totalMembers;
    private Map<String, Id> slacktoSF;
    private List<SlackObjects.ConversationChatMessages> conversationList;
    /** 
    * @author Oktana
    * @date 2022
    * @description Interface Method, passes data to ConnectAPIService in formatted manner.
    * @params Map with ConversationID as Key, ConversationChatMessages Wrapper from SlackObjects as value
    */
    public void postMessage(Map<String, SlackObjects.ConversationChatMessages> conversationChatMessages){
        chatMessages = buildMessages(conversationChatMessages);
        ConnectAPIService.postMessages(chatMessages);
    }
    /** 
    * @author Oktana
    * @date 2022
    * @description Interface Method, returns a Map to SlackService with SlackConversationID keyed to ConversationDetails Wrapper.
    * @params Map with ConversationId as Key, Conversations Wrapper from SlackObjects
    */
    public Map<String, SlackObjects.ConversationDetails> fetchConversationDetails(Map<String, SlackObjects.Conversation> conversations){
        return ConnectApiService.fetchConversationDetails(conversations.keySet());
    }
    /** 
    * @author Oktana
    * @date 2022
    * @description this method takes all the raw data and passes it to private methods to format, and builds the list that is sent to ConnectAPIService from returned values 
    * @params Map with ConversationID as Key, ConversationChatMessages Wrapper from SlackObjects as value
    */
    @TestVisible
    private List<ConnectApiService.ChatMessage> buildMessages(Map<String, SlackObjects.ConversationChatMessages> conversationChatMessages){
        slackConversationIds = conversationChatMessages.keySet();
        for(String key : slackConversationIds){
            conversationMessages = conversationChatMessages.get(key);
            totalMembers.addAll(conversationMessages.members);
        }
        slacktoSF = mapSlackIdToSFId(totalMembers);
        for(String key : slackConversationIds){
            conversationMessages = conversationChatMessages.get(key);
            for(conversationMessages.members cm : conversationMessages.members){
                conversationMessages.members = slacktoSF.get(cm);
            }
            chatMessages.addAll(createChatMessage(conversationMessages));
        }
        return chatMessages;
    }
    /** 
    * @author Oktana
    * @date 2022
    * @description Creates ConnectAPIService ChatMessage Wrapper, including SalesforceIds and Formatted messageBody
    * @params ConversationChatMessages Wrapper from SlackObjects
    */
    @TestVisible
    private List<ConnectAPIService.ChatMessage> createChatMessage(SlackObjects.ConversationChatMessages conversation){
        for(SlackObjects.Messages message : conversation.messages){
            connectMessage.recipients = conversation.members;
            connectMessage.feedItem = conversation.feedItemId;
            connectMessage.messageBody = slacktosf.get(message.UserID) + message.ts + message.text;
            chatMessages.add(connectMessage);
        }
        return chatMessages;
    }
     /** 
    * @author Oktana
    * @date 2022
    * @description this method maps the SlackUserId as a key to the SalesforceUserId, returns this map.
    * @params Set of SlackUserIds
    */
    @TestVisible
    private Map<String, Id> mapSlackIdToSFId(Set<String> totalMembers){
        slacktoSF = new Map<String,Id>();
        List<User> userIDs = [SELECT Id, SlackID__c FROM USER WHERE SlackID__c in :totalMembers WITH SECURITY_ENFORCED];
        for(user u : userIDs){
            slacktoSF.put(u.SlackID__c, u.Id);
        }
        return slacktoSF;
    }
}