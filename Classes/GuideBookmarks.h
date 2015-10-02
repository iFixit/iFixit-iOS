//
//  GuideBookmarks.h
//  iFixit
//
//  Created by David Patierno on 4/7/11.
//  Copyright 2011 iFixit. All rights reserved.
//

#import "SDWebImageManager.h"

#define GuideBookmarksUpdatedNotification @"GuideBookmarksUpdatedNotification"

@class Guide;
@class GuideBookmarker;

@interface GuideBookmarks : NSObject <SDWebImageManagerDelegate> {
    NSInteger imagesDownloaded;
    NSInteger imagesRemaining;
    NSInteger videosDownloaded;
    NSInteger videosRemaining;
    NSInteger documentsDownloaded;
    NSInteger documentsRemaining;
}

@property (nonatomic, retain) NSMutableDictionary *guides;
@property (nonatomic, retain) NSMutableDictionary *images;
@property (nonatomic, retain) NSMutableDictionary *queue;
@property (nonatomic, retain) NSMutableDictionary *videos;
@property (nonatomic, retain) NSMutableDictionary *documents;
@property (nonatomic, retain) NSString *guidesFilePath;
@property (nonatomic, retain) NSString *imagesFilePath;
@property (nonatomic, retain) NSString *queueFilePath;
@property (nonatomic, retain) NSString *videosFilePath;
@property (nonatomic, retain) NSString *documentsFilePath;
@property (nonatomic, retain) NSString *currentItem;
@property (nonatomic, retain) GuideBookmarker *bookmarker;
@property (nonatomic, retain) NSArray *favorites;

+ (GuideBookmarks *)sharedBookmarks;
+ (void)reset;
- (NSArray *)cachedImages;
- (Guide *)guideForGuideid:(NSNumber *)iGuideid;
- (void)addGuideid:(NSNumber *)iGuideid;
- (void)addGuideid:(NSNumber *)iGuideid forBookmarker:(GuideBookmarker *)theBookmarker;
- (void)saveGuide:(Guide *)guide;
- (void)removeGuide:(Guide *)guide;
- (void)saveBookmarks;
- (void)synchronize;
- (void)update;

@end
