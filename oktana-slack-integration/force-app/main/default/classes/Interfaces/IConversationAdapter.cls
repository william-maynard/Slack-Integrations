public abstract class IConversationAdapter {
   public interface ConversationIAdapter{
        void setConversationInfo(Map<String, String> details);
        List<SlackObjects.Chat> selectConversation();
        Map<String, String> selectConversationIds();
   }
   public interface SlackIAdapter{
        void setConversationInfoFromSlack(List<SlackObjects.Conversation> conversations);
        void setConversationFromSlack(map<String, SlackObjects.AllMessages> chats);
        Map<String, String> getNextConversation();
        Boolean hasNextConversation();
   }
}

