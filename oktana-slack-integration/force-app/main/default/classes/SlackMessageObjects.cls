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
        public List<Debug_Log__c> errorLogs;
    }

    public class SlackUser{
        public String slackUserId;
        //public String token;
        public String salesforceUserId;
    }

    public class UserConversationPair{
        public String userToken;
        public String[] conversationIds;
        public String nextCursor;
    }

    public class MemberErrorWrapper{
        public List<String> members;
        public Debug_Log__c errorLog;
    }
}
