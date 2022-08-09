public with sharing class OktanaBirthdayService {
    public enum Type {BIRTHDAY, OKTANA_BIRTHDAY}
    @TestVisible
    private static Map<Type,List<User>> getUsers(){
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
        for (User user : [SELECT Id, ContactId, SlackID__c 
                            FROM User 
                            WHERE ContactId = :contactMap.keySet() 
                            AND SlackID__c != null
                            LIMIT 9999]) {
            if (contactMap.get(user.ContactId).ThisYearBirthday__c == Date.today()) {
           		birthdays.add(user);
            } else {
                oktanaBirthdays.add(user);
            }
        }
        
        // standard user
        for (User user : [SELECT Id, okty_rrhh__ContactId__c, SlackID__c 
                            FROM User 
                            WHERE okty_rrhh__ContactId__c = :contactMap.keySet() 
                            AND SlackID__c != null
                            LIMIT 9999]) {
            if (contactMap.get(user.okty_rrhh__ContactId__c).ThisYearBirthday__c == Date.today()) {
           		birthdays.add(user);
            } else {
                oktanaBirthdays.add(user);
            }
        }

        Map<Type,List<User>> result = new Map<Type,List<User>>();
        result.put(Type.BIRTHDAY, birthdays);
        result.put(Type.OKTANA_BIRTHDAY, oktanaBirthdays);
        return result;
    }
     
    @TestVisible
    private static String getMessage(Type bType, List<User> users) {
        String message = '';
        String mentions = '';
        if (bType == Type.BIRTHDAY) {
            mentions = getMentions(users);
            message = 'Happy Birthday ' + mentions + 'from your Oktana family! 🎂';
        } else if (bType == Type.OKTANA_BIRTHDAY) {
            mentions = getMentions(users);
            message = 'Happy Oktaversary ' + mentions + 'we’re so happy you’re part of Oktana! 🎉';
        }
        
        return message;
    }

    @TestVisible
    private static String getMentions(List<User> users) {
        String mentions = '';
        for (User user : users) {
            mentions += '<@'+ user.SlackID__c +'>, ';
        }
        return mentions;
    }
    
    @future(callout=true)
    public static void sayBirthdayOnSlack(){
        String token = SlackService.getBotSlackToken();
        // get custom setting
        SlackWorkspace__c  currentWorkspace = SlackWorkspace__c.getValues('CurrentWorkspace');
        Map<Type, List<User>> userMap = getUsers();
        String message = '';
        
        if (userMap.get(Type.BIRTHDAY).size() > 0) {
            message = getMessage(Type.BIRTHDAY, userMap.get(Type.BIRTHDAY));
            // preppend mention to the channel
            message = '<#' + currentWorkspace.channelGeneralId__c + '>' + message;
            SlackCalloutService.sendMessage(token, currentWorkspace.channelGeneralId__c, message);
        }
        
        if (userMap.get(Type.OKTANA_BIRTHDAY).size() > 0) {
            message = getMessage(Type.OKTANA_BIRTHDAY, userMap.get(Type.OKTANA_BIRTHDAY));
            // preppend mention to the channel
            message = '<#' + currentWorkspace.channelGeneralId__c + '>' + message;
            SlackCalloutService.sendMessage(token, currentWorkspace.channelGeneralId__c, message);
        }
    }

}
