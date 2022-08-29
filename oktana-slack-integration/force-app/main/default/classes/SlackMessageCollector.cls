public with sharing class SlackMessageCollector {

    public class SlackMessageCollectorException extends Exception{}

    @testVisible
    private class CollectorState{
        @testVisible
        private List<SlackObjects.Conversation> remainingConversations = new List<SlackObjects.Conversation>();
    }

    @testVisible
    private CollectorState state;

    public SlackMessageCollector() {
        state = new CollectorState();
    }
 
    @testVisible
    private List<SlackObjects.Conversation> splitConversationsToCollect(List<SlackObjects.Conversation> conversationList) {

        checkForNullOrEmpty(conversationList);

        List<SlackObjects.Conversation> splitedConversationList = new List<SlackObjects.Conversation>();
        List<SlackObjects.Conversation> remainingConversationList = new List<SlackObjects.Conversation>();
        Integer i = 0;

        for(SlackObjects.Conversation conversation : conversationList) {
            if(i < Constants.SPLIT_LIMIT) {
                splitedConversationList.add(conversationList.get(i));
            }
            else{
                remainingConversationList.add(conversationList.get(i));
            }
            i ++;
            if(conversationList.size() == i) break;
        }
        this.state.remainingConversations = remainingConversationList;
        
        return splitedConversationList;
    }

    private void checkForNullOrEmpty(List<SlackObjects.Conversation> conversationList){
        if(conversationList == null ) throw new SlackMessageCollectorException('Recieved Null conversation List');
        if(conversationList.isEmpty() ) throw new SlackMessageCollectorException('Recieved Empty conversation List');
    }

    public void collect(){
 
    }

    //insert platform event
    //this is only going to work if a platform event exists in the org with 
    //API name SlackMessageSaved__e 
    public Boolean fireMessageEvent(){
       
        SlackMessageSaved__e sms = new SlackMessageSaved__e();

        //publish the event,
        //result has the succes of the event published
        Database.SaveResult result = EventBus.publish(sms);

        return result.isSuccess();

    }


}
