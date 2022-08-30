/**
* @author Oktana.com
* @date 2022
* @description ConnectAPI Selector class.
*/
public without sharing class ConnectAPIIntegrationService {
    
    @TestVisible private ChatterPoster myPoster;

    public interface ChatterPoster {
        void postToChatter(List<ConnectApi.BatchInput> batchInputs);
        void postToChatter(ID feedItemId, ConnectApi.CommentInput commentInput);
    }

    @TestVisible private class RealChatterPoster implements ChatterPoster {
        public void postToChatter(List<ConnectApi.BatchInput> batchInputs) { ConnectApi.ChatterFeeds.postFeedElementBatch(Constants.NETWORK_ID, batchInputs); }
        public void postToChatter(ID feedItemId, ConnectApi.CommentInput commentInput) { ConnectApi.ChatterFeeds.postCommentToFeedElement(Constants.NETWORK_ID, feedItemId, commentInput, null); }
    }

    /** @description Post the FeedItems in Bulk
     * @param batchInputs List of batch inputs to be posted
     * */
    public void postToChatter(List<ConnectApi.BatchInput> batchInputs) {
        myPoster.postToChatter(batchInputs);
    }

    /** @description Post the CommentImputs in Bulk
     * @param feedItemComments Map of CommentImputs related to FeedItem IDs
     * */
    public void postToChatter(Map<Id, List<ConnectApi.CommentInput>> feedItemComments) {
        for(ID feedItemId : feedItemComments.keySet()) {
            for(ConnectApi.CommentInput commentInput : feedItemComments.get(feedItemId)) {
                myPoster.postToChatter(feedItemId, commentInput);
            }            
        }
    }

    public ConnectAPIIntegrationService() {
        myPoster = new RealChatterPoster();
    }

}
