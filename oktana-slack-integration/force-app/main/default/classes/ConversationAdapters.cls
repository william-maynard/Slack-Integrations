public without sharing class ConversationAdapters extends IConversationAdapter implements SlackIAdapter, ConversationIAdapter {
    private Map<String, SlackObjects.Chat> chatMap;
    private Map<String, List<SlackObjects.Chat>> conversationsMap;
    private Map<Id, Id> slackIdToSFIdMap;
    private Map<String, String> conversationToLastMessageIdMap;
    private Map<String, String> conversationToFeedItemIdMap;
    private Set<String> conversationIds;
    public class ConversationIAdapter{
        public void setConversationInfo(Map<String, String> details){
          
        }
        public list<SlackObjects.Chat> selectConversation(List<String> conversationIds){
           
        }
        public Set<String> selectConversationIds(){
          
        }
    }
    public class SlackIAdapter{
        public void setConversationIdsFromSlack(List<SlackObjects.Conversation> conversations){
           
        }
        public void setConversationFromSlack(List<SlackObjects.Chat> chats){
            getUserIdsFromSlackIds(getSlackIdsFromWrapper(chats));
            setMap(setFullMessageBodyandFeedItemId(setUserIdtoWrapper(chats)));
        }
        public List<SlackObjects.Chat> selectConversationFromSlack(String conversationId){
           
        }
        public Map<String,String> selectConversationDetailsFromSF(List<String> conversationIds){
           
        }
        private void getUserIdsFromSlackIds(Set<Id> slackIds){
           
        }
        private List<SlackObjects.Chat> setUserIdtoWrapper(List<SlackObjects.Chat> chats){
           
        }
        private List<SlackObjects.Chat> setFullMessageBodyandFeedItemId(List<SlackObjects.Chat> chats){
          
        }
        private void setMap(List<SlackObjects.Chat> chats){
            
        }
        private Set<Id> getSlackIdsFromWrapper(List<SlackObjects.Chat> chats){
           
        }
    }
}
