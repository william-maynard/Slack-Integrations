public with sharing class SlackLoadUsers {
    public class SlackLoadUsersException extends Exception {}

    @Future(callout=true)
    public static void loadSlackUsers(){

        if(!User.SObjectType.getDescribe().isUpdateable() 
            && !Schema.SObjectType.User.fields.SlackID__c.isUpdateable()){
            throw new SlackLoadUsersException('Insuficient permissions');
        }

        String token = SlackService.getSlackToken();
        String workspaceID = getWorkspaceId();

        SlackMessageObjects.GetUsersResponse response = SlackCalloutService.getSlackUsers(token, workspaceID);
        if(!response.ok) {
            throw new SlackLoadUsersException('Error getting users from slack. Error: ' + response.error);
        }

        mapAndUpdateSlackUsers(response.users);
    }

    public static String getWorkspaceId(){
        SlackWorkspace__c  currentWorkspace = SlackWorkspace__c.getValues('CurrentWorkspace');
        if(currentWorkspace != null){
            return currentWorkspace.SlackWorkspaceId__c;
        }

        return null;
    }

    public static void mapAndUpdateSlackUsers(List<SlackMessageObjects.User> users){

        Map<String, String> emailsIdsMap = getEmailsIdsMap(users);

        List<User> sfUsers = [SELECT Id, Email 
                                FROM User 
                                WHERE Email IN :emailsIdsMap.keySet() 
                                AND IsActive = true
                                WITH SECURITY_ENFORCED];
        for(User user : sfUsers){
            user.SlackID__c = emailsIdsMap.get(user.Email);
        }

        update sfUsers;
        
    }

    public static Map<String, String> getEmailsIdsMap(List<SlackMessageObjects.User> users){
        
        Map<String, String> result = new Map<String, String>();
        for(SlackMessageObjects.User user : users){
            result.put(user.email, user.id);
        }
        return result;
    }
}
