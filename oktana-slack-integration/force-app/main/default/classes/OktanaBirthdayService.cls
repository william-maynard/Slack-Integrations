public with sharing class OktanaBirthdayService {
    
    private static Map<String,List<User>> getUsers(){
        Id contactEmployeeRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Employee').getRecordTypeId();
       
        Map<Id,Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, ThisYearBirthday__c, OktanaDay__c 
            FROM Contact 
            WHERE RecordTypeId = :contactEmployeeRecordTypeId 
            AND (ThisYearBirthday__c = TODAY OR (OktanaDay__c = TODAY AND okty_rrhh__StartDate__c != TODAY))
        ]);
        
        List<User> birthdays = new List<User>();
        List<User> oktanaBirthdays = new List<User>();
        
        // community user
        for (User u : [SELECT Id, Name, ContactId FROM User WHERE ContactId = :contactMap.keySet() limit 9999]) {
            if (contactMap.get(u.ContactId).ThisYearBirthday__c == Date.today()) {
           		birthdays.add(u);
            } else {
                oktanaBirthdays.add(u);
            }
        }
        
        // standard user
        for (User u : [SELECT Id, Name, okty_rrhh__ContactId__c FROM User WHERE okty_rrhh__ContactId__c = :contactMap.keySet() limit 9999]) {
            if (contactMap.get(u.okty_rrhh__ContactId__c).ThisYearBirthday__c == Date.today()) {
           		birthdays.add(u);
            } else {
                oktanaBirthdays.add(u);
            }
        }

        Map<String,List<User>> result = new Map<String,List<User>>();
        result.put('birthdays', birthdays);
        result.put('oktanaBirthdays', oktanaBirthdays);
        return result;
    }
    
    private static ConnectApi.MessageBodyInput getMessage( List<User> users) {

        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    
        ConnectApi.MentionSegmentInput mentionGroup = new ConnectApi.MentionSegmentInput();
        mentionGroup.id = '0F94T000000CyhrSAC';
        
        ConnectApi.TextSegmentInput startText = new ConnectApi.TextSegmentInput();
        startText.text = ' Happy Birthday ';
        
        ConnectApi.TextSegmentInput endText = new ConnectApi.TextSegmentInput();
        endText.text = ' from your Oktana family! 🎂';
        
        // add to segment
        messageBodyInput.messageSegments.add(mentionGroup);
        messageBodyInput.messageSegments.add(startText);
        
        for (User u : users) {
            ConnectApi.MentionSegmentInput userMention = new ConnectApi.MentionSegmentInput();
            userMention.id = u.id;
            messageBodyInput.messageSegments.add(userMention);
            ConnectApi.TextSegmentInput separator = new ConnectApi.TextSegmentInput();
            separator.text = ',';
            messageBodyInput.messageSegments.add(separator);
        }    
        
        messageBodyInput.messageSegments.add(endText);
        return messageBodyInput;
    }
             
    private static ConnectApi.MessageBodyInput getOktanaBirthdayMessage( List<User> users) {

        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    
        ConnectApi.MentionSegmentInput mentionGroup = new ConnectApi.MentionSegmentInput();
        mentionGroup.id = '0F94T000000CyhrSAC';
        
        ConnectApi.TextSegmentInput startText = new ConnectApi.TextSegmentInput();
        startText.text = ' Happy Oktaversary ';
        
        ConnectApi.TextSegmentInput endText = new ConnectApi.TextSegmentInput();
        endText.text = ' we’re so happy you’re part of Oktana! 🎉';
        
        // add to segment
        messageBodyInput.messageSegments.add(mentionGroup);
        messageBodyInput.messageSegments.add(startText);
        
        for (User u : users) {
            ConnectApi.MentionSegmentInput userMention = new ConnectApi.MentionSegmentInput();
            userMention.id = u.id;
            messageBodyInput.messageSegments.add(userMention);
            ConnectApi.TextSegmentInput separator = new ConnectApi.TextSegmentInput();
            separator.text = ',';
            messageBodyInput.messageSegments.add(separator);
        }    
        
        messageBodyInput.messageSegments.add(endText);
        return messageBodyInput;
    }
    
    public static void sayBirthday(){
        Map<String,List<User>> userMap = getUsers();
        
        if (userMap.get('birthdays').size() > 0) {
            ConnectApi.MessageBodyInput body = HappyBirthdayController.getMessage(userMap.get('birthdays'));
            
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            feedItemInput.body = body;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = '0F94T000000CyhrSAC';
        
            ConnectApi.ChatterFeeds.postFeedElement('0DB4T000000CapoWAC', feedItemInput);
        }
        
        if (userMap.get('oktanaBirthdays').size() > 0) {
            ConnectApi.MessageBodyInput body = HappyBirthdayController.getOktanaBirthdayMessage(userMap.get('oktanaBirthdays'));
            
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            feedItemInput.body = body;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = '0F94T000000CyhrSAC';
         
            ConnectApi.ChatterFeeds.postFeedElement('0DB4T000000CapoWAC', feedItemInput);
        }

    }

}
