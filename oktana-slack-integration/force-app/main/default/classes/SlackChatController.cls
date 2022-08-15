public with sharing class SlackChatController {
    
    
    @AuraEnabled(cacheable=true)
    public static List<Conversation> getConversations() {
        
        //Helper inner class
        SecureSOQL soql = new SecureSOQL();

        //Get Current User Conversations     
        Map<ID, Conversation__c> mapConversations = soql.getConversations(UserInfo.getUserId());
        
        //Get Conversation Members
        Set<String> memberIds = new Set<String>();
        for(Conversation__c conv : mapConversations.values()) {
            for(String member : conv.Members__c.split('005')) {
                if(member.length() == 15) {
                    memberIds.add('005' + member);
                }
            }
        }

        //Get Users Data
        Map<ID, User> mapUsers = soql.getUsersData(memberIds);
        
        //Create Consversations Picklist Options
        List<Conversation> conversations = new List<Conversation>();
        for(Conversation__c conv : mapConversations.values()) {
            List<String> labels = new List<String>();
            for(String member : conv.Members__c.split('005')) {
                if(member.length() == 15 && ('005' + member) != UserInfo.getUserId()) {
                    labels.add(mapUsers.get('005' + member).Name);
                }
            }

            conversations.add(new Conversation(String.join(labels, ', '), conv.Conversation_Id__c));
        } 


        return conversations;
    }

    @AuraEnabled(cacheable=true)
    public static Chat getChat(String conversationID) {
        SecureSOQL soql = new SecureSOQL();
        Chat chat = new Chat();
        List<ChatMessage> chatMessages = new List<ChatMessage>();

        //Get Conversation Data
        Map<ID, Conversation__c> mapConversations = soql.getConversationsByFeedItem(conversationID);

        //Get Conversation Members
        Set<String> memberIds = new Set<String>();
        for(Conversation__c conv : mapConversations.values()) {
            for(String member : conv.Members__c.split('005')) {
                if(member.length() == 15) {
                    memberIds.add('005' + member);
                }
            }
        }

        //Get Users Data
        Map<ID, User> mapUsers = soql.getUsersData(memberIds);

        //Get Feed Conversations based on FeedItem
        Map<ID, FeedComment> feedComments = soql.getFeedCommentData(conversationID);
            
        //Get Chat Messages
        for(FeedComment feedComment : feedComments.values()) {

            String userId = feedComment.CommentBody.mid(1, 18);
            String commentDate = feedComment.CommentBody.mid(20, 19);
            String comment = feedComment.CommentBody.mid(40, feedComment.CommentBody.length());
            
            chatMessages.add(new ChatMessage(
                feedComment.Id,
                mapUsers.get(userId),
                comment,
                commentDate,
                mapUsers.get(userId).Name
            ));
        }                                                            

        chat.messages = chatMessages;
        return chat;
    }

    /** 
    * @author Oktana
    * @date 2022
    * @description Slack Chat Conversations Picklist Options inner class.
    */
    public class Conversation {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public Conversation(String pLabel, String pValue) {
			label = pLabel;
            value = pValue;
		}
    }

    /** 
    * @author Oktana
    * @date 2022
    * @description Slack Chat inner class.
    */
    public class Chat {
        @AuraEnabled public List<ChatMessage> messages;
        public Chat() {
			messages = new List<ChatMessage>();
		}
    }

	/** 
    * @author Oktana
    * @date 2022
    * @description Slack Messages inner class.
    */
    public class ChatMessage {
        @AuraEnabled public String Id;
        @AuraEnabled public User messageOwner;
		@AuraEnabled public String messageBody;
		@AuraEnabled public String messageDateTime;
        @AuraEnabled public String ownerName;
        public ChatMessage(String pId, User pMessageOwner, String pMessageBody, String pMessageDateTime, String pOwnerName) {
			Id = pId;
            messageOwner = pMessageOwner;
			messageBody = pMessageBody;
			messageDateTime = pMessageDateTime;
            ownerName = pOwnerName;
		}
    }

    private without sharing class SecureSOQL {
        
        public Map<Id, Conversation__c> getConversations(String userId) {
            String conversationQuery = 'SELECT Name, Conversation_Id__c, Members__c '
                                    + 'FROM Conversation__c '
                                    + 'WHERE IsDirectMessage__c = true AND Members__c LIKE \'%' + userId + '%\' '
                                    + 'LIMIT 10000';

            return new Map<Id, Conversation__c>((List<Conversation__c>)Database.query(conversationQuery));
        }

        public Map<Id, Conversation__c> getConversationsByFeedItem(String feedId) {
            return new Map<Id, Conversation__c>([SELECT Name, Conversation_Id__c, Members__c FROM Conversation__c WHERE Conversation_Id__c = :feedId LIMIT 10000]);
        }
        
        public Map<ID, User> getUsersData(Set<String> recordIds) {
            return new Map<ID, User>([   SELECT Name,
                                            SmallPhotoURL
                                        FROM User
                                        WHERE Id IN :recordIds]);
        }

        public Map<ID, FeedComment> getFeedCommentData(String conversationID) {
            
            return new Map<ID, FeedComment>([  SELECT CommentBody 
                                                FROM FeedComment 
                                                WHERE FeedItemId = :conversationID
                                                LIMIT 10000 ]);
        }
    }
}