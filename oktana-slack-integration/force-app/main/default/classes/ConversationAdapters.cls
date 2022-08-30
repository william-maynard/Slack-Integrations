public without sharing class ConversationAdapters extends IConversationAdapter implements SlackIAdapter, ConversationIAdapter {
    private Map<String, SlackObjects.Chat> chatMap;
    private Map<String, List<SlackObjects.Chat>> conversationsMap;
    private Map<Id, Id> slackIdToSFIdMap;

    public void setConversation(SlackObjects.Chat chat){
         chatMap.put(chat.messageBody.timestamp, chat);
         conversationsMap.put(chat.slackConversationId, conversationMap.get(chat.slackConversationId).add(chat));
    }
    public list<SlackObjects.Chat> selectConversation(String conversationId){
        return conversationsMap.get(conversationId);
    }
    public Set<String> selectConversationIds(){
        return conversationsMap.keySet();
    }
    public void setConversationFromSlack(List<SlackObjects.Chat> chats){
        getUserIdsFromSlackIds(getSlackIdsFromWrapper(chats));
        setMaps(setFullMessageBody(setUserIdtoWrapper(chats)));
    }
    public List<SlackObjects.Chat> selectConversationFromSlack(String conversationId){
        return conversationsMap.get(conversationId);
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
    private List<SlackObjects.Chat> setFullMessageBody(List<SlackObjects.Chat> chats){
        for(SlackObjects.Chat chat : chats){ 
            chat.messageBody.text = chat.messageBody.userId + chat.messageBody.timestamp + chat.messageBody.text;
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
