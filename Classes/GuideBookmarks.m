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

static GuideBookmarks *sharedBookmarks = nil;

@implementation GuideBookmarks

@synthesize guides, images, queue, currentItem, bookmarker;
@synthesize guidesFilePath, imagesFilePath, queueFilePath;

+ (GuideBookmarks *)sharedBookmarks {
    if (!sharedBookmarks && [iFixitAPI sharedInstance].user) sharedBookmarks = [[GuideBookmarks alloc] init];
    return sharedBookmarks;
}

+ (void)reset {
    if (sharedBookmarks)
        [sharedBookmarks release];
    sharedBookmarks = nil;
}

// Returns a flat list of all cached image paths so 
// SDImageCache can avoid evicting them during its cleanDisk operation.
- (NSArray *)cachedImages {
    NSMutableArray *allImages = [NSMutableArray array];
    
    for (NSArray *guideImages in [sharedBookmarks.images allValues])
        [allImages addObjectsFromArray:guideImages];
    
    return allImages;
}

- (Guide *)guideForGuideid:(NSNumber *)guideid {
    NSString *key = [NSString stringWithFormat:@"%d_%d",
                     [[iFixitAPI sharedInstance].user.userid intValue],
                     [guideid intValue]];
    return [guides objectForKey:key];
}

- (void)addGuideid:(NSNumber *)guideid {
    [queue setValue:@"add" forKey:[NSString stringWithFormat:@"%d_%d",
                                   [[iFixitAPI sharedInstance].user.userid intValue],
                                   [guideid intValue]]];
    [self synchronize];
}

- (void)addGuideid:(NSNumber *)guideid forBookmarker:(GuideBookmarker *)theBookmarker {
    self.bookmarker = theBookmarker;
    
    [self addGuideid:guideid];
}

// Saves (1) the guide json data to disk, along with 
// (2) a master list of images in another file so we never evict them.
- (void)saveGuide:(Guide *)guide {
    // Index bookmarks by userid and guideid to prevent duplicates.
    NSString *key = [NSString stringWithFormat:@"%d_%d",
                     [[iFixitAPI sharedInstance].user.userid intValue],
                     guide.guideid];
    
    // 1. Save the guide data.
    [guides setObject:guide.data forKey:key];
    
    // 2. Save the list of images.
    NSMutableArray *guideImages = [NSMutableArray array];
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
    }
    
    [images setObject:guideImages forKey:key];
    
    // Write to disk.
    [self saveBookmarks];
}

- (void)removeGuideid:(NSNumber *)guideid {
    NSString *key = [NSString stringWithFormat:@"%d_%d",
                     [[iFixitAPI sharedInstance].user.userid intValue],
                     [guideid intValue]];
    
    [guides removeObjectForKey:key];
    [images removeObjectForKey:key];
    [self saveBookmarks]; 
}

- (void)removeGuide:(Guide *)guide {
    [self removeGuideid:[NSNumber numberWithInt:guide.guideid]];
    [queue setValue:@"remove" forKey:[NSString stringWithFormat:@"%d_%d",
                                   [[iFixitAPI sharedInstance].user.userid intValue],
                                   guide.guideid]];
    [self synchronize];
}

- (void)saveBookmarks {
    // Write to disk
    if (guides) {
        [guides writeToFile:[self guidesFilePath] atomically:YES];
        [images writeToFile:[self imagesFilePath] atomically:YES];
        [queue  writeToFile:[self queueFilePath] atomically:YES];
    }
}

- (void)synchronize {    
    [self saveBookmarks]; 
    
    if (![queue count])
        return;

    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    // Loop through all items in the queue.
    for (NSString *key in [queue allKeys]) {
        NSArray *chunks = [key componentsSeparatedByString:@"_"];
        NSNumber *userid = [f numberFromString:[chunks objectAtIndex:0]];
        NSNumber *guideid = [f numberFromString:[chunks objectAtIndex:1]];
        
        // Only synchronize for the current user.
        if (![userid isEqual:[iFixitAPI sharedInstance].user.userid])
            continue;
        
        // One at a time.
        if (currentItem)
            continue;
        
        // Download a new guide
        if ([[queue valueForKey:key] isEqual:@"add"]) {
            self.currentItem = key;
            [[iFixitAPI sharedInstance] getGuide:[guideid intValue] forObject:self withSelector:@selector(gotGuide:)];
        }
        // Remove an existing guide
        else {
            self.currentItem = key;
            [[iFixitAPI sharedInstance] unlike:guideid forObject:self withSelector:@selector(unliked:)];
        }
        
        /*
         Stop the loop here.
         
         Guide download will continue in the background, and will call 
         [self synchronize] again once all images have completed downloading.
         */
        break;
    }
        
    [f release];
}

- (void)announceUpdate {
    [[NSNotificationCenter defaultCenter] postNotificationName:GuideBookmarksUpdatedNotification object:nil];
}

- (void)unliked:(NSDictionary *)result {
    if (!result || [result objectForKey:@"error"]) {
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
    
    // Save the result.
    [self saveGuide:guide];
    
    // Count the images...
    for (GuideStep *step in guide.steps) {
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
        for (GuideImage *image in step.images) {
            [[SDWebImageManager sharedManager] downloadWithURL:[image URLForSize:@"thumbnail"] delegate:self retryFailed:YES];
            [[SDWebImageManager sharedManager] downloadWithURL:[image URLForSize:@"large"] delegate:self retryFailed:YES];
        }
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    imagesDownloaded++;
    imagesRemaining--;
    
    // Update the progress bar.
    @try {
        bookmarker.progress.progress = (float)imagesDownloaded / (imagesRemaining + imagesDownloaded);
    }
    @catch (NSException *e) {
        self.bookmarker = nil;
    }
    
    // Done
    if (!imagesRemaining) {
        // Reset counters.
        imagesDownloaded = 0;
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

- (void)update {
    [[iFixitAPI sharedInstance] getUserLikesForObject:self withSelector:@selector(gotUpdates:)];
}
- (void)gotUpdates:(NSArray *)likes {
    [self synchronize];

    if (!likes || ([likes isKindOfClass:[NSDictionary class]] && [likes valueForKey:@"error"])) {
        // Notify listeners of a potential logout.
        [self announceUpdate];
        return;
    }
    
    NSMutableArray *guideids = [NSMutableArray array];

    // Add new guides.
    for (NSDictionary *like in likes) {
        NSNumber *guideid = [like objectForKey:@"guideid"];
        
        // This double-conversion is necessary for the "containsObject" check.
        int guideIdInt = [guideid intValue];
        [guideids addObject:[NSNumber numberWithInt:guideIdInt]];

        if (![self guideForGuideid:guideid])
            [self addGuideid:guideid];
    }
    
    // Remove deleted guides.
    NSArray *allBookmarks = [guides allValues];
    for (NSDictionary *guideData in allBookmarks) {
        // This double-conversion is necessary for the "containsObject" check.
        int guideIdInt = [[guideData objectForKey:@"guideid"] intValue];
        NSNumber *guideid = [NSNumber numberWithInt:guideIdInt];

        if (![guideids containsObject:guideid])
            [self removeGuideid:guideid];
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
        
        filename = [NSString stringWithFormat:@"%@_%d_bookmarkedGuides.plist",
                    [Config currentConfig].host,
                    [[iFixitAPI sharedInstance].user.userid intValue]];
        self.guidesFilePath = [docDirectory stringByAppendingPathComponent:filename];
        
        filename = [NSString stringWithFormat:@"%@_%d_bookmarkedImages.plist",
                    [Config currentConfig].host,
                    [[iFixitAPI sharedInstance].user.userid intValue]];
        self.imagesFilePath = [docDirectory stringByAppendingPathComponent:filename];
        
        filename = [NSString stringWithFormat:@"%@_%d_bookmarkQueue.plist",
                    [Config currentConfig].host,
                    [[iFixitAPI sharedInstance].user.userid intValue]];
        self.queueFilePath = [docDirectory stringByAppendingPathComponent:filename];
        
        // Now load: Guides
        NSDictionary *g = [NSDictionary dictionaryWithContentsOfFile:[self guidesFilePath]];
        self.guides = g ? [NSMutableDictionary dictionaryWithDictionary:g] : [NSMutableDictionary dictionary];
        
        // Images
        NSDictionary *i = [NSDictionary dictionaryWithContentsOfFile:[self imagesFilePath]];
        self.images = i ? [NSMutableDictionary dictionaryWithDictionary:i] : [NSMutableDictionary dictionary];

        // Queue
        NSDictionary *q = [NSDictionary dictionaryWithContentsOfFile:[self queueFilePath]];
        self.queue = q ? [NSMutableDictionary dictionaryWithDictionary:q] : [NSMutableDictionary dictionary];
        
        imagesRemaining = 0;
        imagesDownloaded = 0;
        self.currentItem = nil;
        self.bookmarker = nil;
        
        [self update];
    }
    return self;
}

- (void)dealloc {
    self.guides = nil;
    self.images = nil;
    self.queue = nil;
    self.currentItem = nil;
    self.bookmarker = nil;
    [super dealloc];
}

@end
