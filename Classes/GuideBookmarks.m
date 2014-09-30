//
//  GuideBookmarks.m
//  iFixit
//
//  Created by David Patierno on 4/7/11.
//  Copyright 2011 iFixit. All rights reserved.
//

#import "GuideBookmarks.h"
#import "GuideBookmarker.h"
#import "Guide.h"
#import "GuideStep.h"
#import "GuideImage.h"
#import "SDImageCache.h"
#import "iFixitAPI.h"
#import "User.h"
#import "SDWebImageManager.h"
#import "Config.h"
#import "Guide.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "Utility.h"
#include <sys/xattr.h>

static GuideBookmarks *sharedBookmarks = nil;

@implementation GuideBookmarks

@synthesize guides, images, videos, queue, currentItem, bookmarker;
@synthesize guidesFilePath, imagesFilePath, queueFilePath, videosFilePath;

+ (GuideBookmarks *)sharedBookmarks {
    if (!sharedBookmarks && [iFixitAPI sharedInstance].user)
        sharedBookmarks = [[GuideBookmarks alloc] init];
    return sharedBookmarks;
}

+ (void)reset {
    if (sharedBookmarks)
        [sharedBookmarks release];
    sharedBookmarks = nil;
}

- (void)AddSkipBackupAttributeToFile:(NSURL *)url {
    u_int8_t b = 1;
    setxattr([[url path] fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
}

// Returns a flat list of all cached image paths so 
// SDImageCache can avoid evicting them during its cleanDisk operation.
- (NSArray *)cachedImages {
    NSMutableArray *allImages = [NSMutableArray array];
    
    for (NSArray *guideImages in [sharedBookmarks.images allValues])
        [allImages addObjectsFromArray:guideImages];
    
    return allImages;
}

- (Guide *)guideForGuideid:(NSNumber *)iGuideid {
    NSString *key = [NSString stringWithFormat:@"%@_%@",
                     [iFixitAPI sharedInstance].user.iUserid,
                     iGuideid];
    
    return guides[key] ? [Guide guideWithDictionary:guides[key]] : nil;
}

- (void)addGuideid:(NSNumber *)iGuideid {
    // Analytics
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Guide"
                                                                                        action:@"Add"
                                                                                         label:@"Add to favorites"
                                                                                         value:iGuideid] build]];

    [queue setValue:@"add" forKey:[NSString stringWithFormat:@"%@_%@",
                                   [iFixitAPI sharedInstance].user.iUserid,
                                   iGuideid]];
    [self synchronize];
}

- (void)addGuideid:(NSNumber *)iGuideid forBookmarker:(GuideBookmarker *)theBookmarker {
    self.bookmarker = theBookmarker;
    
    [self addGuideid:iGuideid];
}

// Saves (1) the guide json data as a string to disk, along with
// (2) a master list of images/videos in separate files so we never evict them
- (void)saveGuide:(Guide *)guide {
    // Index bookmarks by userid and guideid to prevent duplicates.
    NSString *key = [NSString stringWithFormat:@"%@_%@",
                     [iFixitAPI sharedInstance].user.iUserid,
                     guide.iGuideid];
    
    // 1. Save the guide data.
    [guides setObject:guide.data forKey:key];
    
    // 2. Save the list of images/videos.
    NSMutableArray *guideImages = [NSMutableArray array];
    NSMutableArray *guideVideos = [NSMutableArray array];
    
    if (guide.image) {
        NSString *standardURL = [[guide.image URLForSize:@"standard"] absoluteString];
        [guideImages addObject:[SDImageCache cacheFilenameForKey:standardURL]];
    }
    
    for (GuideStep *step in guide.steps) {
        for (GuideImage *image in step.images) {
            NSString *thumbnailURL = [[image URLForSize:@"thumbnail"] absoluteString];
            NSString *largeURL = [[image URLForSize:@"large"] absoluteString];
            [guideImages addObject:[SDImageCache cacheFilenameForKey:thumbnailURL]];
            [guideImages addObject:[SDImageCache cacheFilenameForKey:largeURL]]; 
        }
      
        if (step.video) {
            [guideVideos addObject:[NSString stringWithFormat:@"%@_%i_%i_%@", [iFixitAPI sharedInstance].user.iUserid, step.stepid, step.video.videoid, step.video.filename]];
        }
    }
    
    [images setObject:guideImages forKey:key];
  
    if (guideVideos.count) {
        [videos setObject:guideVideos forKey:key];
    }
    
    // Write to disk.
    [self saveBookmarks];
}

- (void)removeGuideid:(NSNumber *)iGuideid {
    // Analytics
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Guide"
                                                                                        action:@"Remove"
                                                                                         label:@"Remove from favorites"
                                                                                         value:iGuideid] build]];

    NSString *key = [NSString stringWithFormat:@"%@_%@",
                     [iFixitAPI sharedInstance].user.iUserid,
                     iGuideid];

    [guides removeObjectForKey:key];
    [images removeObjectForKey:key];

    // Remove videos stored on disk
    [self removeOfflineVideos:videos[key]];
    [videos removeObjectForKey:key];
    
    [self saveBookmarks];
}

- (void)removeOfflineVideos:(NSArray *)videos {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *videosDirectory = [docDirectory stringByAppendingPathComponent:@"/Videos"];
    NSString *filePath = nil;
    NSError *error = nil;
    
    for (NSString *video in videos) {
        filePath = [videosDirectory stringByAppendingPathComponent:video];
        [fileManager removeItemAtPath:filePath error:&error];
    }
}

- (void)removeGuide:(Guide *)guide {
    [self removeGuideid:guide.iGuideid];
    [queue setValue:@"remove" forKey:[NSString stringWithFormat:@"%@_%@",
                                   [iFixitAPI sharedInstance].user.iUserid,
                                   guide.iGuideid]];
    [self synchronize];
}

- (NSDictionary *)serializeGuides:(NSDictionary *)guides {
    NSMutableDictionary *serializedGuides = [[NSMutableDictionary alloc] initWithCapacity:guides.count];

    for (NSString *key in guides) {
        serializedGuides[key] = [Utility serializeDictionary:guides[key]];
    }

    return serializedGuides;
}

- (NSDictionary *)deserializeGuides:(NSDictionary *)guides {
    NSMutableDictionary *deserializedGuides = [[NSMutableDictionary alloc] initWithCapacity:guides.count];

    for (NSString *key in guides) {
        deserializedGuides[key] = [guides[key] isKindOfClass:[NSString class]] ?
                        [Utility deserializeJsonString:guides[key]] : guides[key];
    }
    
    return deserializedGuides;
}

- (void)saveBookmarks {
    // Write to disk
    if (guides) {
        
        // We must first serialize the JSONData before writing to disk,
        // otherwise it is possible for a write to fail if a dictionary contains
        // NSNull values or non First Class Objects
        [[self serializeGuides:guides] writeToFile:[self guidesFilePath] atomically:YES];
        [images writeToFile:[self imagesFilePath] atomically:YES];
        [queue  writeToFile:[self queueFilePath] atomically:YES];
        [videos writeToFile:[self videosFilePath] atomically:YES];

        // Mark favorites databases as offline storage
        [self AddSkipBackupAttributeToFile:[NSURL URLWithString:[self guidesFilePath]]];
        [self AddSkipBackupAttributeToFile:[NSURL URLWithString:[self imagesFilePath]]];
        [self AddSkipBackupAttributeToFile:[NSURL URLWithString:[self queueFilePath]]];
        [self AddSkipBackupAttributeToFile:[NSURL URLWithString:[self videosFilePath]]];
        
        // Mark all images as offline storage
        for (NSString *fileName in images) {
            [self AddSkipBackupAttributeToFile:[NSURL URLWithString:fileName]];
        }
        
        // Mark all videos as offline storage
        for (NSString *fileName in videos) {
            [self AddSkipBackupAttributeToFile:[NSURL URLWithString:fileName]];
        }
    }
}

- (void)synchronize {    
    [self saveBookmarks]; 
    
    if (![queue count]) {
        return;
    }
    

    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];

    // Loop through all items in the queue.
    for (NSString *key in [queue allKeys]) {
        NSArray *chunks = [key componentsSeparatedByString:@"_"];
        NSNumber *iUserid = [f numberFromString:[chunks objectAtIndex:0]];
        NSNumber *iGuideid = [f numberFromString:[chunks objectAtIndex:1]];
        
        // Only synchronize for the current user.
        if (![iUserid isEqual:[iFixitAPI sharedInstance].user.iUserid])
            continue;

        // One at a time.
        if (currentItem)
            continue;
        
        // Download a new guide
        if ([[queue valueForKey:key] isEqual:@"add"]) {
            self.currentItem = key;
            [[iFixitAPI sharedInstance] getGuide:iGuideid forObject:self withSelector:@selector(gotGuide:)];
        }
        // Remove an existing guide
        else {
            self.currentItem = key;
            [[iFixitAPI sharedInstance] unlike:iGuideid forObject:self withSelector:@selector(unliked:)];
        }
       
        /*
         Stop the loop here.
         
         Guide download will continue in the background, and will call 
         [self synchronize] again once all images/videos have completed downloading.
         */
        break;
    }
        
    [f release];
}

- (void)announceUpdate {
    [[NSNotificationCenter defaultCenter] postNotificationName:GuideBookmarksUpdatedNotification object:nil];
}

- (void)unliked:(NSDictionary *)result {
    if (![result[@"statusCode"] isEqualToNumber:@(204)]) {
        [iFixitAPI displayConnectionErrorAlert];
        self.currentItem = nil;
        [self announceUpdate];
        return;
    }
    
    [queue removeObjectForKey:currentItem];
    self.currentItem = nil;
    [self synchronize];
    
    // Notify listeners.
    [self announceUpdate];
}

- (void)gotGuide:(Guide *)guide {
    if (!guide) {
        self.currentItem = nil;
        return;
    }
    
    // Remove guides that don't exist anymore.
    if ([[guide.data valueForKey:@"message"] isEqual:@"Guide not found"]) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        
        NSArray *chunks = [currentItem componentsSeparatedByString:@"_"];
        NSNumber *iGuideid = [f numberFromString:[chunks objectAtIndex:1]];
        [f release];
        
        guide.iGuideid = iGuideid;
        [self removeGuide:guide];
        return;
    }
    
    // Save the result.
    [self saveGuide:guide];
    
    // Count the media items...
    for (GuideStep *step in guide.steps) {
        if (step.video) {
            videosRemaining++;
        }

        for (GuideImage *image in step.images) {
            imagesRemaining += 2;
        }
    }
    
    // ...and now download them.
    if (guide.image) {
        imagesRemaining++;
        [[SDWebImageManager sharedManager] downloadWithURL:[guide.image URLForSize:@"standard"] delegate:self retryFailed:YES];
    }

    for (GuideStep *step in guide.steps) {
        if (step.video) {
            [self downloadGuideVideoForGuideStep:step];
        }
        
        for (GuideImage *image in step.images) {
            [[SDWebImageManager sharedManager] downloadWithURL:[image URLForSize:@"thumbnail"] delegate:self retryFailed:YES];
            [[SDWebImageManager sharedManager] downloadWithURL:[image URLForSize:@"large"] delegate:self retryFailed:YES];
        }
        
    }
}

- (void)downloadGuideVideoForGuideStep:(GuideStep*)step {
    // Create the request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:step.video.url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    
    // Let's ensure it's async =)
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *videoData, NSError *error) {
        
        // Let's ensure we got something valid back
        if (videoData.length && !error) {
            // Grab the path to the sandboxed directory given to us
            NSString *docDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *videosPath = [docDirectory stringByAppendingPathComponent:@"/Videos"];
            
            // Let's make sure that the Videos directory exists
            if (![[NSFileManager defaultManager] fileExistsAtPath:videosPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:videosPath withIntermediateDirectories:NO attributes:nil error:&error];
            }
            
            // Create the file path
            NSString *filePath = [videosPath stringByAppendingPathComponent:
                                  [NSString stringWithFormat:@"%@_%i_%i_%@", [iFixitAPI sharedInstance].user.iUserid, step.stepid, step.video.videoid, step.video.filename
                                   ]];
            
            // Write to disk
            [videoData writeToFile:filePath atomically:YES];
            
            videosDownloaded++;
            videosRemaining--;
            
            [self updateProgessBar];
            [self checkIfFinishedDownloading];
        }
    }];
}
- (void)checkIfFinishedDownloading {
    if(!videosRemaining && !imagesRemaining) {
        // Reset counters.
        imagesDownloaded = 0;
        videosDownloaded = 0;
        [bookmarker bookmarked];
        self.bookmarker = nil;
        
        // Update queue, continue synchronizing.
        [queue removeObjectForKey:currentItem];
        self.currentItem = nil;
        [self synchronize];
        
        // Notify listeners.
        [self announceUpdate];
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    imagesDownloaded++;
    imagesRemaining--;
    
    // Update the progress bar.
    [self updateProgessBar];

    // Done
    [self checkIfFinishedDownloading];
}

- (void)updateProgessBar {
    @try {
        bookmarker.progress.progress = (float)(imagesDownloaded + videosDownloaded) / (imagesRemaining + imagesDownloaded + videosRemaining + videosDownloaded);
    }
    @catch (NSException *e) {
        self.bookmarker = nil;
    }
}

- (void)update {
    [[iFixitAPI sharedInstance] getUserFavoritesForObject:self withSelector:@selector(gotUpdates:)];
}

- (void)gotUpdates:(NSArray *)likes {

    if (!likes) {
        [iFixitAPI displayConnectionErrorAlert];
        return;
    }

    if (([likes isKindOfClass:[NSDictionary class]] && [likes valueForKey:@"error"])) {
        // Notify listeners of a potential logout.
        [self announceUpdate];
        return;
    }
    
    NSMutableArray *guideids = [NSMutableArray array];
    self.favorites = likes;
    
    // Add new guides.
    for (NSDictionary *like in likes) {
        NSNumber *iGuideid = like[@"guide"][@"guideid"];
        
        [guideids addObject:iGuideid];
        Guide *savedGuide = [self guideForGuideid:iGuideid];

        if (!savedGuide) {
            [self addGuideid:iGuideid];
        // Force both modified dates into integers when comparing, this is to deal with data type inconsistency across
        // different endpoints. Remove when new version of API is released
        } else if (![[Guide getAbsoluteModifiedDateFromGuideDictionary:like[@"guide"]] isEqualToNumber:[savedGuide getAbsoluteModifiedDate]]) {
            [self removeGuideid:iGuideid];
            [self addGuideid:iGuideid];
        }
    }
    
    // Remove deleted guides.
    NSArray *allBookmarks = [guides allValues];
    
    for (NSDictionary *guide in allBookmarks) {
        NSNumber *iGuideid = guide[@"guideid"];

        if (![guideids containsObject:iGuideid]) {
            [self removeGuideid:iGuideid];
        }
    }
    
    // Notify listeners.
    [self announceUpdate];
}

- (id)init {
    if ((self = [super init])) {
        // First get the file paths.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDirectory = [paths objectAtIndex:0];
        NSString *filename = nil;
        
        filename = [NSString stringWithFormat:@"%@_%@_bookmarkedGuides.plist",
                    [Config currentConfig].host,
                    [iFixitAPI sharedInstance].user.iUserid];
        self.guidesFilePath = [docDirectory stringByAppendingPathComponent:filename];
        
        filename = [NSString stringWithFormat:@"%@_%@_bookmarkedImages.plist",
                    [Config currentConfig].host,
                    [iFixitAPI sharedInstance].user.iUserid];
        self.imagesFilePath = [docDirectory stringByAppendingPathComponent:filename];
        
        filename = [NSString stringWithFormat:@"%@_%@_bookmarkQueue.plist",
                    [Config currentConfig].host,
                    [iFixitAPI sharedInstance].user.iUserid];
        self.queueFilePath = [docDirectory stringByAppendingPathComponent:filename];
        
        filename = [NSString stringWithFormat:@"%@_%@_bookmarkedVideos.plist",
                    [Config currentConfig].host,
                    [iFixitAPI sharedInstance].user.iUserid];
        self.videosFilePath = [docDirectory stringByAppendingPathComponent:filename];
        
        // Now load: Guides
        NSDictionary *g = [NSDictionary dictionaryWithContentsOfFile:[self guidesFilePath]];
        
        // We must deserialize our guides first before using them
        self.guides = [NSMutableDictionary dictionaryWithDictionary:[self deserializeGuides:g]];
        
        // Images
        NSDictionary *i = [NSDictionary dictionaryWithContentsOfFile:[self imagesFilePath]];
        self.images = i ? [NSMutableDictionary dictionaryWithDictionary:i] : [NSMutableDictionary dictionary];
        
        // Media
        NSDictionary *m = [NSDictionary dictionaryWithContentsOfFile:[self videosFilePath]];
        self.videos = m ? [NSMutableDictionary dictionaryWithDictionary:m] : [NSMutableDictionary dictionary];

        // Queue
        NSDictionary *q = [NSDictionary dictionaryWithContentsOfFile:[self queueFilePath]];
        self.queue = q ? [NSMutableDictionary dictionaryWithDictionary:q] : [NSMutableDictionary dictionary];
        
        imagesRemaining = 0;
        imagesDownloaded = 0;
        videosRemaining = 0;
        videosDownloaded = 0;

        self.currentItem = nil;
        self.bookmarker = nil;
        
    }
    return self;
}

- (void)dealloc {
    [guides release];
    [images release];
    [queue release];
    [guidesFilePath release];
    [imagesFilePath release];
    [videosFilePath release];
    [queueFilePath release];
    [currentItem release];
    [bookmarker release];
    
    [super dealloc];
}

@end
