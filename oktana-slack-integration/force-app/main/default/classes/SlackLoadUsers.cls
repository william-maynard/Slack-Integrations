public with sharing class SlackLoadUsers {
    
    @Future(callout=true)
    public static void loadSlackUsers(){

        //fetch tokens
        String token = SlackService.getSlackToken();

        //fetch the slack id
        String workspaceID = getWorkspaceId();

        //call the slack api with the token
        List<SlackMessageObjects.SlackUser> slackUsers = SlackCalloutService.getSlackUsers(token,workspaceID);

        //get the email and map with the users
        mapAndUpdateSlackUsers(slackUsers);
    }

    public static String getWorkspaceId(){
        SlackWorkspace__c  currentWorkspace = SlackWorkspace__c.getValues('CurrentWorkspace');
        if(currentWorkspace != null){
            return currentWorkspace.SlackWorkspaceId__c;
        }

        return null;
    }

    public static void mapAndUpdateSlackUsers(List<SlackMessageObjects.SlackUser> slackUsers){

        List<String> emailList = getEmailList(slackUsers);

        List<User> foundUsers = [SELECT Id, email FROM User WHERE email in :emailList WITH SECURITY_ENFORCED];

        for(User u : foundUsers){
            u.SlackID__c = getSlackIdByEmail(slackUsers, u.Email);
        }

        if(User.SObjectType.getDescribe().isUpdateable() && Schema.SObjectType.User.fields.SlackID__c.isUpdateable()){
                update foundUsers;
        }
        
    }

    public static List<String> getEmailList(List<SlackMessageObjects.SlackUser> slackUsers){
        
        List<String> result = new List<String>();
        for(SlackMessageObjects.SlackUser sUser : slackUsers){
            result.add(sUser.email);
        }

        return result;
    }

    public static String getSlackIdByEmail(List<SlackMessageObjects.SlackUser> slackUsers, String email){

        for(SlackMessageObjects.SlackUser sUser : slackUsers){
            if(sUser.email == email){
                return sUser.slackUserId;
            }
        }

        return null;

    }
}
