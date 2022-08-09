global with sharing class SaveMembersBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
    	String query = 'SELECT Id, Conversation_Id__c FROM Conversation__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Conversation__c> records){
        // process each batch of records
        List<Conversation__c> conversations = new List<Conversation__c>();
        for(Conversation__c conversation : records){
            List<String> members = new List<String>();
            for(DirectMessageMember directives: [SELECT MemberId 
                FROM DirectMessageMember 
                WHERE DirectMessageId IN (SELECT ParentId FROM FeedItem where Id =: conversation.Conversation_Id__c)]){
                members.add(String.valueOf(directives.get('MemberId')));
            }
            String membersString = String.join(members, '');
            conversation.Members__c = membersString;
            conversations.add(conversation);
        }
        Database.update(conversations);
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        System.debug('Members copied');
    } 

    // SaveMembersBatch runBatch = new SaveMembersBatch(); 
    // Id batchId = Database.executeBatch(runBatch);
}
