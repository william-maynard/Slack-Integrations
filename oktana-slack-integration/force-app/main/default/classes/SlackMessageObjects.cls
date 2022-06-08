public with sharing class SlackMessageObjects {
    public class SlackMessage{
        public String textMessage;
        public String ts;
        public Boolean isEdited;
        public String editedTs;
        public String slackUserId;
    }

    public class FullConversation{
        public String conversationId;
        public List<SlackMessage> messages;
        public List<String> members; 
    }

    public class SlackUser{
        public String slackUserId;
        //public String token;
        public String salesforceUserId;
    }

    public class UserConversationPair{
        //public String userToken;
        public String[] conversationIds;
    }
}
