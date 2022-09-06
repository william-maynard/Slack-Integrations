/**
* @author Oktana.com
* @date 2022
* @description Slack Integration Adapter class.
*/
public without sharing class ConversationAdapters extends IConversationAdapter implements ConversationIAdapter, SlackIAdapter{
    public Map<String, SlackObjects.Chat> chatMap = new Map<String, SlackObjects.Chat>();
    public Map<String, List<SlackObjects.Chat>> conversationsMap = new Map<String, List<SlackObjects.Chat>>();
    public List<SlackObjects.Chat> chatList = new List<SlackObjects.Chat>();
    public Map<String, Id> slackIdToSFIdMap = new Map<String,Id>();
    public Map<String, String> conversationToLastMessageIdMap = new Map<String, String>();
    public Map<String, String> conversationIds = new Map<String, String>();
    public Iterator<String> iterate;
    /**
    * @author Oktana.com
    * @date 2022
    * @params Recieves a Map of SlackConversationId as key, LastMessageId as value.
    * @description sets class attribute with map returned from ConversationService, sets iterator.
    */
    public void setConversationInfo(Map<String, String> details){
        this.conversationToLastMessageIdMap = details;
        setIterator();
    }
    /**
    * @description returns all SlackObjects.Chat as a list for posting to SF.
    */
    public List<SlackObjects.Chat> selectConversation(){
        for(List<SlackObjects.Chat> chat : this.conversationsMap.values()){
            this.chatList.addAll(chat);
        }
        return this.chatList;
    }
    /**
    * @description returns a Map of SlackConversationId as key, null values.
    */
    public Map<String, String> selectConversationIds(){
        return this.conversationIds;
    }
    /**
    * @params receives a list of SlackObjects.Conversation from initial callout to Slack
    * @description iterates through list of conversations to set null map for Conversation Service and creates SlackObject.Chat to add to ChatMap for value mapping.
    */
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
    /**
    * @params recieves a map of SlackConversationId as key and SlackObjects.AllMessages as value
    * @description sets the value of conversationsMap to be retrieved by ConversationService.
    */
    public void setConversationFromSlack(map<String, SlackObjects.AllMessages> messages){
        getUserIdsFromSlackIds(getSlackIdsFromWrapper(messages));
        setUserIdtoWrapper(messages);
        setFullMessageBody(messages);
    }
    /**
    * @description provides iteration for the Slack Service callout to retrieve all messages
    */
    public Map<String,String> getNextConversation(){
        String conversationId = this.iterate.next();
        return new Map<String,String>{conversationId => this.conversationToLastMessageIdMap.get(conversationId)};
    }
    /**
    * @description Boolean value that Slack Service uses to determine if there are any more slack conversations to retrieve messages for.
    */
    public Boolean hasNextConversation(){
       return this.iterate.hasNext();     
    }
    /**
    * @params recieves the map passed to setConversationFromSlack
    * @description returns slackIds stored in AllMessages.members object field
    */
    private Set<String> getSlackIdsFromWrapper(map<String, SlackObjects.AllMessages> messages){
        Set<String> slackIds = new Set<String>();
        for(SlackObjects.AllMessages message : messages.values()){
            slackIds.addAll(message.members);
        }
        return slackIds;
    }
    /**
    * @params recieves the set of slackIds returned from getSlackIdsFromWrapper
    * @description queries SF through UserSelector to retrieve User Id for users with a SlackID__c, stores the values in a map with SlackUserId as key and User Id as value.
    */
    private void getUserIdsFromSlackIds(Set<String> slackIds){
        List<User> userList = UserSelector.getUserIdsFromSlackIds(slackIds);
        for(User u : userList){
            this.slackIdToSFIdMap.put(u.SlackID__c, u.Id);
        }
    }
    /**
    * @params recieves the map passed to setConversationFromSlack
    * @description sets the SlackObject.Chat SFUserId values from the slackIdToSFIdMap created in getUserIdsFromSlackIds
    */
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
    /**
    * @params recieves the map passed to setConversationFromSlack
    * @description sets the SlackObject.Chat for each message retrieved by Slack Service, uses the values in ChatMap to create Chat objects and store them in a new map ConversationsMap.
    */
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
    /**
    * @description set the iterator value from a set of SlackConversationIds
    */
    private void setIterator(){
        this.iterate = this.conversationToLastMessageIdMap.keySet().iterator();
    }
}