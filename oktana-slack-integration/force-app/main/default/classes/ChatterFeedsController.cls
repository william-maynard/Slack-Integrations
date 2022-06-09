public with sharing class ChatterFeedsController {
    
    //Pages, get elements and set bookmark actions!!
    public static ConnectApi.FeedElementPage getFeedsPage(ChatterFilter.FeedItem filter) {
        ConnectApi.FeedElementPage feedsPage = null;
        if(filter.parentId == null) {
            feedsPage = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(filter.communityId, filter.feedType, filter.pageParam, filter.pageSize, filter.sortParam);				
        } else {
            feedsPage = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(filter.communityId, filter.feedType, filter.parentId, filter.pageParam, filter.pageSize, filter.sortParam);
        }
        return feedsPage;
    }

    public static ConnectApi.FeedElement getFeed(ChatterFilter.FeedItem filter) {
        return ConnectApi.ChatterFeeds.getFeedElement(filter.communityId, filter.feedId);
    }

    public static ConnectApi.BookMarksCapability setBookmarkedFeed(String communityId, String feedId, Boolean mark) {
        return ConnectApi.ChatterFeeds.updateFeedElementBookmarks(communityId, feedId, mark);
    }

    public static ConnectApi.MuteCapability setMutedFeed(String communityId, String feedId, Boolean muted) {
        return ConnectApi.ChatterFeeds.setIsMutedByMe(communityId, feedId, muted);
    }

    public static ConnectApi.CommentPage getCommentPage(ChatterFilter.Comment filter) {
        return ConnectApi.ChatterFeeds.getCommentsForFeedElement(filter.communityId, filter.feedItemId, filter.pageParam, filter.pageSize);
    }

    public static ConnectApi.Comment getChatterComment(ChatterFilter.Comment filter) {
        return ConnectApi.ChatterFeeds.getComment(filter.communityId, filter.commentId);
    }

    //Like actions!!
    public static ConnectApi.ChatterLikePage getLikesForFeed(ChatterFilter.ElementLike filter) {
        return ConnectApi.ChatterFeeds.getLikesForFeedElement(filter.communityId, filter.elementId, filter.pageParamLike, filter.pageSizeLike);
    }

    public static ConnectApi.ChatterLikePage getLikesForComment(ChatterFilter.ElementLike filter) {
        return ConnectApi.ChatterFeeds.getLikesForComment(filter.communityId, filter.elementId, filter.pageParamLike, filter.pageSizeLike);
    } 

    public static ConnectApi.ChatterLike likeFeedElement(ChatterFilter.ElementLike filter){	
        return ConnectApi.ChatterFeeds.likeFeedElement(filter.communityId, filter.elementId);
     }

     public static ConnectApi.ChatterLike likeComment(ChatterFilter.ElementLike filter){
         return ConnectApi.ChatterFeeds.likeComment(filter.communityId, filter.elementId);
    }

    //Delete actions!!
    public static void deleteComment(String communityId, String commentId) {
        ConnectApi.ChatterFeeds.deleteComment(communityId, commentId);
    }

    public static void deleteFeed(String communityId, String feedId) {
        ConnectApi.ChatterFeeds.deleteFeedElement(communityId, feedId);
    }

    public static void deleteLike(String communityId, String likeId) {
        ConnectApi.ChatterFeeds.deleteLike(communityId, likeId);
    }

    //Update action  								 
    public static ConnectApi.Comment updateComment(ChatterObjects.CommentElement comment) {
        return ConnectApi.ChatterFeeds.updateComment(comment.communityId , comment.feedElementId, comment.commentInput);
    }

    public static ConnectApi.FeedElement postEditFeed(ChatterObjects.FeedElement feedElement, String feedId) {
        return ConnectApi.ChatterFeeds.updateFeedElement(feedElement.communityId, feedId, feedElement.getFeedItemInput());
    }

    //Post actions
    public static ConnectApi.FeedElement postFeed(ChatterObjects.FeedElement feedElement) {
        return ConnectApi.ChatterFeeds.postFeedElement(feedElement.communityId, feedElement.getFeedItemInput());
    }

    public static ConnectApi.Comment postComment(ChatterObjects.CommentElement comment) {
        return ConnectApi.ChatterFeeds.postCommentToFeedElement(comment.communityId, comment.feedElementId, comment.commentInput, null);
    }

    public static ConnectApi.FeedElement postFeedDirectMessage(String communityId, String messageText, List<String> recipients, List<String> files, Boolean crossOrgOwner) {
        Boolean changeOwnerCrossOrg = false;
        // Define the FeedItemInput object to pass to postFeedElement
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        if (crossOrgOwner) {
            changeOwnerCrossOrg = true;
        } 
        textSegmentInput.text = messageText;

        // The MessageBodyInput object holds the text in the post
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;

        // The FeedElementCapabilitiesInput object holds the capabilities of the feed item.
        // For this feed item, we define a direct message capability to hold the member(s) and the subject.

        ConnectApi.DirectMessageCapabilityInput dmInput = new ConnectApi.DirectMessageCapabilityInput();
        if (changeOwnerCrossOrg)//we add a flag to know which feedItem has to change its owner
            dmInput.subject = 'Starting crossorg conversation';
        dmInput.membersToAdd = recipients;

        ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
        feedElementCapabilitiesInput.directMessage = dmInput;

        if(files != null && !files.isEmpty()){
            feedElementCapabilitiesInput.files = new ConnectApi.FilesCapabilityInput();
            feedElementCapabilitiesInput.files.items = new List<ConnectApi.FileIdInput>();
            for (String contentDocuemntID : files) {
                ConnectApi.FileIdInput content = new ConnectApi.FileIdInput();
                content.id = ChatterDesktopController.getDocumentId(contentDocuemntID);
                feedElementCapabilitiesInput.files.items.add(content);
            }
        }

        feedItemInput.capabilities = feedElementCapabilitiesInput;


        // Post the feed item.
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(communityId, feedItemInput);
        return feedElement;
    }

    //get comments from feed direct messages and the first message (first post)
    public static List<Object> getCommentsDirectMessageQuery(String feedId, Integer offset) {
        List<Object> result = new List<Object>();
        List<String> filesIds = new List<String>();
        Set<Id> actorIds = new Set<Id>();

        FeedItem chatFeed = [SELECT  Id, Body, CommentCount, CreatedDate, LikeCount, LinkUrl, ParentId, Title, Type, CreatedById, IsRichText,
                            (SELECT RecordId, Title, Type, Value FROM FeedAttachments), 
                            (SELECT Id, CommentBody,CommentType, CreatedDate, CreatedById, FeedItemId, ParentId, IsRichText, RelatedRecordId FROM FeedComments ORDER BY CreatedDate DESC NULLS FIRST Limit 100 OFFSET :offset)
                            FROM FeedItem where Id =: feedId LIMIT 1];

        if (chatFeed.FeedComments.size() == 0 || chatFeed.FeedComments.size() != 100) {
            actorIds.add(chatFeed.CreatedById);
            for (FeedAttachment feedAttachment: chatFeed.FeedAttachments) {
                filesIds.add(feedAttachment.RecordId);
            }
        } 
        
        for (FeedComment comment: chatFeed.FeedComments)  {
            actorIds.add(comment.CreatedById);
            filesIds.add(comment.RelatedRecordId);
        }

        Map<ID, ContentVersion> contentVersions = new Map<ID, ContentVersion>([SELECT Id, ContentSize, CreatedDate, FileType, FileExtension, Title FROM ContentVersion where Id IN :filesIds]);

        List<FeedComment> reverseOrder = chatFeed.FeedComments;
        List<FeedComment> newOrder = new List<FeedComment>();

        for (Integer i = reverseOrder.size()-1; i>= 0; i-- ) {
           newOrder.add(reverseOrder[i]);
        }

        /* If there are not more comments, first add the feed content to the result object, and then the related comments */
        if (chatFeed.FeedComments.size() == 0 || chatFeed.FeedComments.size() != 100) {
            Map<String, Object> feedData = new Map<String, Object>();
      		List<Object> filesList = new List<Object>();
            String bodyFeed = 'posted a file.';
      		String typeFeed = 'Text';
            if (chatFeed.Body != null) {
                bodyFeed = chatFeed.Body;
            }
			if(chatFeed.Type != null){
				typeFeed = chatFeed.Type;
      		}
            feedData.put('Id', chatFeed.Id);
            feedData.put('Body', bodyFeed);
            feedData.put('SentDate', chatFeed.CreatedDate);
            feedData.put('SenderId', chatFeed.CreatedById);
            feedData.put('ConversationId', chatFeed.Id);
            feedData.put('IsRichText', chatFeed.IsRichText);
            feedData.put('Type', typeFeed);

            for (FeedAttachment feedAttachment: chatFeed.FeedAttachments){
				Map<String, Object> feedFiles = new Map<String, Object>();
				if(feedAttachment.RecordId != null){
					feedFiles.put('Id',contentVersions.get(feedAttachment.RecordId).Id);
					feedFiles.put('ContentSize',contentVersions.get(feedAttachment.RecordId).ContentSize);
					feedFiles.put('FileType',contentVersions.get(feedAttachment.RecordId).FileType);
					feedFiles.put('Title',contentVersions.get(feedAttachment.RecordId).Title);
					feedFiles.put('FileExtension',contentVersions.get(feedAttachment.RecordId).FileExtension);
					filesList.add(feedFiles);
				} else if (typeFeed.contains('Content')) {
                    feedFiles.put('Id', null);
                    filesList.add(feedFiles);
                }
            }
            feedData.put('Files', filesList);
            result.add(feedData);
        }

        for (FeedComment comment: newOrder)  {
            Map<String, Object> commentData = new Map<String, Object>();
            Map<String, Object> commentFiles = new Map<String, Object>();
            List<Object> filesCommentList = new List<Object>();
            if (comment.RelatedRecordId != null){
                commentFiles.put('Id',contentVersions.get(comment.RelatedRecordId).Id);
                commentFiles.put('ContentSize',contentVersions.get(comment.RelatedRecordId).ContentSize);
                commentFiles.put('FileType',contentVersions.get(comment.RelatedRecordId).FileType);
                commentFiles.put('Title',contentVersions.get(comment.RelatedRecordId).Title);
				commentFiles.put('FileExtension',contentVersions.get(comment.RelatedRecordId).FileExtension);
				filesCommentList.add(commentFiles);
			} else if (comment.CommentType.contains('Content')) {
                commentFiles.put('Id', null);
                filesCommentList.add(commentFiles);
            }
			
			String body = 'posted a file.';
			String typeComment = 'Text';
            if (comment.CommentBody != null) {
                body = comment.CommentBody;
            }
			if(comment.CommentType != null){
				typeComment = comment.CommentType;
			}
            
			commentData.put('Body', body);
            commentData.put('SentDate', comment.CreatedDate);
            commentData.put('Id', comment.Id);
            commentData.put('SenderId', comment.CreatedById);
            commentData.put('ConversationId', chatFeed.Id);
            commentData.put('IsRichText', comment.IsRichText);
            commentData.put('Files', filesCommentList);
            commentData.put('Type', typeComment);
            result.add(commentData);
        }
        return result;
    }
}