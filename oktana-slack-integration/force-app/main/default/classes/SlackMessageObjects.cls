public with sharing class SlackMessageObjects {
    public class SlackMessage{
        public String textMessage;
        public String ts;
        public Boolean isEdited;
        public String editedTs;
        public String slackUserId;
        public String salesforceUserId;
    }

    public class FullConversation{
        public String conversationId;
        public List<SlackMessage> messages;
        public List<String> members;
        public List<Debug_Log__c> errorLogs;
    }

    public class SlackUser{
        public String slackUserId;
        //public String token;
        public String salesforceUserId;
        public String email;
    }

    public class Channel {
        public String id;
        public String name;
        public Integer num_members;
        public Boolean is_im;
        public Boolean is_channel;
        public Boolean is_group;
    }

    public class SendMessageResponse {
        public boolean ok;
        public String ts;
        public String error;
    }

    public class GetConversationResponse {
        public boolean ok;
        public String nextCursor;
        public List<Channel> channels;
        public String error;
    }

    public class UserConversationPair{
        public String[] conversationIds;
        public String nextCursor;
    }

    public class MemberErrorWrapper{
        public List<String> members;
        public Debug_Log__c errorLog;
    }
}
