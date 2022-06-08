public with sharing class SaveSlackMessageHandler {

    public static List<SlackMessageObjects.FullConversation> addMembersAndMessages( SlackMessageObjects.UserConversationPair pair, 
                                                                    List<SlackMessageObjects.SlackUser> allUsers, String userToken ){

       return new List<SlackMessageObjects.FullConversation>();

    } 

    public static List<SlackMessageObjects.SlackUser> mapSlackIdsToAllUsers(List<User> usersList){
        return new List<SlackMessageObjects.SlackUser>();
    }

    public static void scheduleSaveConversations(List<SlackMessageObjects.FullConversation> conversationsToSave){}

}
