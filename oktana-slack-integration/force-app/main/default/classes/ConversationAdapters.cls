public without sharing class ConversationAdapters extends IConversationAdapter implements ConversationIAdapter, SlackIAdapter{
    public Map<String, SlackObjects.Chat> chatMap = new Map<String, SlackObjects.Chat>();
    public Map<String, List<SlackObjects.Chat>> conversationsMap = new Map<String, List<SlackObjects.Chat>>();
    public List<SlackObjects.Chat> chatList = new List<SlackObjects.Chat>();
    public Map<String, Id> slackIdToSFIdMap = new Map<String,Id>();
    public Map<String, String> conversationToLastMessageIdMap = new Map<String, String>();
    public Map<String, String> conversationIds = new Map<String, String>();
    public Iterator<String> iterate;

    public void setConversationInfo(Map<String, String> details){
        this.conversationToLastMessageIdMap = details;
        setIterator();
    }
    public List<SlackObjects.Chat> selectConversation(){
        for(List<SlackObjects.Chat> chat : this.conversationsMap.values()){
            this.chatList.addAll(chat);
        }
        return this.chatList;
    }
    public Map<String, String> selectConversationIds(){
        return this.conversationIds;
    }
    public void setConversationInfoFromSlack(List<SlackObjects.Conversation> conversations){
        for(SlackObjects.Conversation c : conversations){
            SlackObjects.Chat chat = new SlackObjects.Chat();
            chat.conversationName = c.name;
            chat.isDirectMessage = c.isDirectMessage;
            chat.slackConversationId = c.id;
            this.conversationIds.put(c.id, null);
            this.chatMap.put(c.Id, chat);
        }
    }

    public void setConversationFromSlack(map<String, SlackObjects.AllMessages> messages){
        getUserIdsFromSlackIds(getSlackIdsFromWrapper(messages));
        setUserIdtoWrapper(messages);
        setFullMessageBody(messages);
    }
    public Map<String,String> getNextConversation(){
        String conversationId = this.iterate.next();
        return new Map<String,String>{conversationId => this.conversationToLastMessageIdMap.get(conversationId)};
    }
    public Boolean hasNextConversation(){
       return this.iterate.hasNext();     
    }
    private Set<String> getSlackIdsFromWrapper(map<String, SlackObjects.AllMessages> messages){
        Set<String> slackIds = new Set<String>();
        for(SlackObjects.AllMessages message : messages.values()){
            slackIds.addAll(message.members);
        }
        return slackIds;
    }
    private void getUserIdsFromSlackIds(Set<String> slackIds){
        List<User> userList = UserSelector.getUserIdsFromSlackIds(slackIds);
        for(User u : userList){
            this.slackIdToSFIdMap.put(u.SlackID__c, u.Id);
        }
    }
    private void setUserIdtoWrapper(map<String, SlackObjects.AllMessages> messages){
        for (String key : messages.keySet()){
            SlackObjects.AllMessages am = messages.get(key);
            SlackObjects.Chat chat = chatMap.get(key);
            List<Id> idList = new List<Id>();
            for(String id : am.members){
                idList.add(this.slackIdToSFIdMap.get(id));
            }
            if(chat.SFUserID == null){
                chat.SFUserId = new Set<Id>();
               } 
            	chat.SFUserId.addAll(idList);
                chatMap.put(key, chat);
        }
    }
    private void setFullMessageBody(map<String, SlackObjects.AllMessages> messages){
        List<SlackObjects.Chat> chatsList = new List<SlackObjects.Chat>();
        for(String key : messages.keySet()){ 
            SlackObjects.AllMessages am = messages.get(key);
            SlackObjects.Chat chat = chatMap.get(key);
            for(SlackObjects.Message message : am.messages){
                SlackObjects.Chat c = new SlackObjects.Chat();
                c.conversationName = chat.conversationName;
                c.isDirectMessage = chat.isDirectMessage;
                c.slackConversationId = key;
                c.SFUserId = chat.SFUserId;
                if(c.messageBody == null){
                   c.messageBody = new SlackObjects.Message();
                }
                c.messageBody.text = message.userId + message.timestamp + message.text;
                chatsList.add(c);
            }
            conversationsMap.put(key, chatsList);
        }
    }
    private void setIterator(){
        this.iterate = this.conversationToLastMessageIdMap.keySet().iterator();
    }
}