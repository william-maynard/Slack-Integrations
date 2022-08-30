/**
* @author Oktana.com
* @date 2022
* @description Conversation Selector class.
*/
public without sharing class ConversationSelector {
    
    public List<Conversation__c> getConversationsBySlackConversationIds(Set<String> slackConversationIds) {
        return [    SELECT Slack_Conversation_Id__c, Conversation_Id__c 
                    FROM Conversation__c 
                    WHERE Slack_Conversation_Id__c IN :slackConversationIds
                    WITH SECURITY_ENFORCED
                    LIMIT 10000];
    }
}
