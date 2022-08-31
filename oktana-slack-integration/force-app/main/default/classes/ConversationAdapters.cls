public without sharing class ConversationAdapters extends IConversationAdapter implements SlackIAdapter, ConversationIAdapter {
    private Map<String, SlackObjects.Chat> chatMap;
    private Map<String, List<SlackObjects.Chat>> conversationsMap;
    private Map<Id, Id> slackIdToSFIdMap;
    private Map<String, String> conversationToLastMessageIdMap;
    private Map<String, String> conversationToFeedItemIdMap;

    public void setConversationDetails(Map<String, SlackObject.ConversationDetails> details){
        for(String key : details.keySet()){
            conversationToLastMessageIdMap.put(key, details.get(key).lastMessageId);
            conversationToFeedItemIdMap.put(key, details.get(key).feedItemId);
        }
    }
    public list<SlackObjects.Chat> selectConversation(List<String> conversationIds){
        Map<String, List<SlackObjects.Chat>> conversations = new Map<String, List<SlackObjects.Chat>>();
        for(String id : conversationIds){
            conversations.put(id, conversationsMap.get(id));
        }
        return conversations;
    }
    public Set<String> selectConversationIds(){
        return conversationsMap.keySet();
    }
    public void setConversationFromSlack(List<SlackObjects.Chat> chats){
        getUserIdsFromSlackIds(getSlackIdsFromWrapper(chats));
        setMaps(setFullMessageBodyandFeedItemId(setUserIdtoWrapper(chats)));
    }
    public List<SlackObjects.Chat> selectConversationFromSlack(String conversationId){
        return conversationsMap.get(conversationId);
    }
    public Map<String,String> selectConversationDetailsFromSF(List<String> conversationIds){
        Map<String, String> conversationDetails = new Map<String,String>();
        for(String id : conversationIds){
            conversationDetails.put(id, conversationToLastMessageIdMap.get(id));
        }
        return conversationDetails;
    }
    private void getUserIdsFromSlackIds(Set<Id> slackIds){
        List<User> userList = UserSelector.getUserIdsFromSlackIds(slackIds);
        for(User u : userList){
            slackIdToSFIdMap.put(u.SlackID__c, u.Id);
        }
    }
    private List<SlackObjects.Chat> setUserIdtoWrapper(List<SlackObjects.Chat> chats){
        for (SlackObjects.Chat chat : chats){
            chat.SFUserId.clear();
            chat.SFUserId.addAll(slackIdToSFIdMap.get(chat.messageBody.userId));
        }
    }
    private List<SlackObjects.Chat> setFullMessageBodyandFeedItemId(List<SlackObjects.Chat> chats){
        for(SlackObjects.Chat chat : chats){ 
            chat.messageBody.text = chat.messageBody.userId + chat.messageBody.timestamp + chat.messageBody.text;
            chat.feedItemId = conversationToFeedItemIdMap.get(chat.slackConversationId);
        }
    }
    private void setMaps(List<SlackObjects.Chat> chats){
        for(SlackObjects.Chat chat : chats){
            chatMap.put(chat.messageBody.timestamp, chat);
            conversationsMap.put(chat.slackConversationId, conversationsMap.get(chat.slackConversationId).add(chat));
        }
    }
    private Set<Id> getSlackIdsFromWrapper(List<SlackObjects.Chat> chats){
        Set<Id> slackIds = new Set<Id>();
        for(SlackObjects.Chat chat : chats){
            slackIds.addAll(chat.SFUserId);
        }
    }
}
