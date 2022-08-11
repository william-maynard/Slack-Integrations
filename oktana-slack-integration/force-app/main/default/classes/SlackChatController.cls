public with sharing class SlackChatController {
    
    
    @AuraEnabled(cacheable=true)
    public static List<Conversation> getConversations() {
        
        //Get Current User Conversations
        String conversationQuery = 'SELECT Name, Conversation_Id__c, Members__c '
                                    + 'FROM Conversation__c '
                                    + 'WHERE IsDirectMessage__c = true AND Members__c LIKE \'%' + UserInfo.getUserId() + '%\' '
                                    + 'LIMIT 10000';

        Map<ID, Conversation__c> mapConversations = new Map<Id, Conversation__c>((List<Conversation__c>)Database.query(conversationQuery));

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
        Map<ID, User> mapUsers = new Map<ID, User>([    SELECT Name,
                                                            SmallPhotoURL
                                                        FROM User
                                                        WHERE Id IN :memberIds]);
        
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
        Chat chat = new Chat();
        List<ChatMessage> chatMessages = new List<ChatMessage>();

        //Get Conversation Data
        Map<ID, Conversation__c> mapConversations = new Map<Id, Conversation__c>([  SELECT Name, Conversation_Id__c, Members__c 
                                                                                    FROM Conversation__c 
                                                                                    WHERE Conversation_Id__c = :conversationID ]);
        
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
        Map<ID, User> mapUsers = new Map<ID, User>([    SELECT Name,
                                                            SmallPhotoURL
                                                        FROM User
                                                        WHERE Id IN :memberIds]);

        //Get Feed Conversations based on FeedItem
        Map<ID, FeedComment> feedComments = new Map<ID, FeedComment>([  SELECT CommentBody 
                                                                        FROM FeedComment 
                                                                        WHERE FeedItemId = :conversationID
                                                                        LIMIT 10000 ]);
            
        //Get Chat Messages
        for(FeedComment feedComment : feedComments.values()) {

            String userId = feedComment.CommentBody.mid(1, 18);
            String commentDate = feedComment.CommentBody.mid(20, 19);
            String comment = feedComment.CommentBody.mid(40, feedComment.CommentBody.length());
            
            chatMessages.add(new ChatMessage(
                feedComment.Id,
                mapUsers.get(userId),
                comment,
                commentDate
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
        public ChatMessage(String pId, User pMessageOwner, String pMessageBody, String pMessageDateTime) {
			Id = pId;
            messageOwner = pMessageOwner;
			messageBody = pMessageBody;
			messageDateTime = pMessageDateTime;
		}
    }
}