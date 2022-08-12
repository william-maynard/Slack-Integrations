global with sharing class SaveMembersBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
    	String query = 'SELECT Id, Conversation_Id__c FROM Conversation__c LIMIT 50000000';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Conversation__c> records){
        // process each batch of records
        
        Set<Id> conversationIds = new Set<Id>();
        for(Conversation__c conversation : records) {
            conversationIds.add(conversation.Conversation_Id__c);
        }
        Map<Id, Id> mapConIdFIParentId = new Map<Id, Id>();
        for(FeedItem feedItem : [	SELECT ParentId 
                                 	FROM FeedItem 
                                 	WHERE Id IN :conversationIds
                                	LIMIT 50000]) {
            mapConIdFIParentId.put(feedItem.ParentId, feedItem.Id);
        }
        System.debug(mapConIdFIParentId.size());
        Map<Id, Set<Id>> mapConIdMemberId = new Map<Id, Set<Id>>();
        for(DirectMessageMember dmm : [	SELECT MemberId, DirectMessageId 
                                       	FROM DirectMessageMember 
                                       	WHERE DirectMessageId IN :mapConIdFIParentId.keySet()
                                      	LIMIT 50000]) {   
            Set<Id> memberIds = mapConIdMemberId.get(mapConIdFIParentId.get(dmm.DirectMessageId));
            if(memberIds == null){
                memberIds = new Set<Id>();
            }
            
            memberIds.add(dmm.MemberId);
            mapConIdMemberId.put(mapConIdFIParentId.get(dmm.DirectMessageId), memberIds);
        }
        for(Conversation__c conversation : records){
            conversation.Members__c = String.join(new List<Id>(mapConIdMemberId.get(conversation.Conversation_Id__c)), '');
            if (conversation.Members__c.length() > 255) {
                conversation.Members__c = conversation.Members__c.substring(0, 255);
            }
        }
        Database.upsert(records);
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        System.debug('Members copied');
    } 

    // SaveMembersBatch runBatch = new SaveMembersBatch(); 
    // Id batchId = Database.executeBatch(runBatch);
}
