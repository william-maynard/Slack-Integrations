public abstract class IConversationAdapter {
   public interface ConversationIAdapter{
        void setConversation(SlackObject.Chat conversation);
        List<SlackObjects.Chat> selectConversation(String conversationId);
        Set<String> selectConversationIds();
   }
   public interface SlackIAdapter{
        void setConversationFromSlack(List<SlackObject.Chat> conversation);
        List<SlackObjects.Chat> selectConversationFromSlack(String conversationId);
   }
}

