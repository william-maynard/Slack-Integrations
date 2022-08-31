public with sharing class SlackObjects {
   
    public class SFUser{
        public String id;
        public String token;

        public SFUser(String id, String token){
            this.id = id;
            this.token = token;
        }
    }

    public class Conversation {
        public String id;
        public String name;
        public Integer numbersMembers;
        public Boolean isDirectMessage;
        public Boolean isChannel;
        public Boolean isGroup;
    }
    public class ConversationDetails{
        public String lastMessageId;
        public String feedItemId;
    }
    public class ConversationChatMessages{
        public Set<String> members;
        public list<Message> messages;
        public String feedItemId;
    }
    public class Message {
        public String timestamp;
        public String text;
        public String userId;
        public String type;
    }
    public class Chat{
        public String slackConversationId;
        public String feedItemId;
        public Set<Id> SFUserId;
        public String conversationName;
        public boolean isDirectMessage;
        public Message messageBody;
    }
}
