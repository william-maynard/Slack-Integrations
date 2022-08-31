public abstract class IConversationAdapter {
   public interface ConversationIAdapter{
        void setConversationInfo(Map<String, String> details);
        List<SlackObjects.Chat> selectConversation(String conversationId);
        Set<String> selectConversationIds();
   }
   public interface SlackIAdapter{
        void setConversationIdsFromSlack(List<SlackObjects.Conversation> conversations);
        void setConversationFromSlack(List<SlackObject.Chat> conversation);
        List<SlackObjects.Chat> selectConversationFromSlack(String conversationId);
        Map<String, String> selectConversationDetailsFromSF(List<String> conversationIds);
   }
}

