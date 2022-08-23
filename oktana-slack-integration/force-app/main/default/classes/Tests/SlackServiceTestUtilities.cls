public with sharing class SlackServiceTestUtilities {
  
    public static List<SlackObjects.Conversation>getPMConversations(Integer ammount) {
        List<SlackObjects.Conversation> conversationsToReturn = new List<SlackObjects.Conversation>();

        for(Integer i = 0; i < ammount; i++) {
            SlackObjects.Conversation conversation = new SlackObjects.Conversation();
            conversation.id = 'ABC'+i;
            conversation.isChannel = false;
            conversation.isDirectMessage = true;
            conversation.isGroup = false;
            conversation.name = 'Testing '+i;
            conversation.numbersMembers = 2;
            conversationsToReturn.add(conversation);
        }
        return conversationsToReturn;

    }

}
