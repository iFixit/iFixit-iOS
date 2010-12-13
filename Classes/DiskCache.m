//
//  DiskCache.m
//  happyhours
//
//  Created by David Golightly on 2/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DiskCache.h"

const NSUInteger kMaxDiskCacheSize			= 8e7; // 80 MB

static DiskCache *sharedInstance;

@interface DiskCache (Privates)
- (void)trimDiskCacheFilesToMaxSize:(NSUInteger)targetBytes;
@end


@implementation DiskCache
@dynamic sizeOfCache, cacheDir;

- (id)init {
	if (self = [super init]) {
		[self trimDiskCacheFilesToMaxSize:kMaxDiskCacheSize];
	}
	return self;
}


- (NSString *)cacheDir {
	if (_cacheDir == nil) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		_cacheDir = [[NSString alloc] initWithString:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"URLCache"]];

	
        /* check for existence of cache directory */
        if (![[NSFileManager defaultManager] fileExistsAtPath:_cacheDir]) {

            /* create a new cache directory */
            if (![[NSFileManager defaultManager] createDirectoryAtPath:_cacheDir 
                                           withIntermediateDirectories:NO
                                                            attributes:nil 
                                                                 error:nil]) {
                NSLog(@"Error creating cache directory");

                [_cacheDir release];
                _cacheDir = nil;
            }
        }
    }
	return _cacheDir;
}


- (NSString *)localPathForURL:(NSURL *)url {
	NSString *filename = [[[url path] componentsSeparatedByString:@"/"] lastObject];
	
	return [[self cacheDir] stringByAppendingPathComponent:filename];
}



- (NSData *)imageDataInCacheForURLString:(NSString *)urlString {
	NSString *localPath = [self localPathForURL:[NSURL URLWithString:urlString]];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
		// "touch" the file so we know when it was last used
		[[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil] 
										 ofItemAtPath:localPath 
												error:nil];
		return [[NSFileManager defaultManager] contentsAtPath:localPath];
	}
	
	return nil;
}


- (void)cacheImageData:(NSData *)imageData   
			   request:(NSURLRequest *)request
			  response:(NSURLResponse *)response {
	if (request != nil && 
		response != nil && 
		imageData != nil) {
		NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response 
                                                                                       data:imageData];
		[[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse 
											  forRequest:request];
		
		if ([self sizeOfCache] >= kMaxDiskCacheSize) {
			[self trimDiskCacheFilesToMaxSize:kMaxDiskCacheSize * 0.75];
		}
		
		NSString *localPath = [self localPathForURL:[request URL]];
		
		[[NSFileManager defaultManager] createFileAtPath:localPath 
												contents:imageData 
											  attributes:nil];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
			//DLog(@"ERROR: Could not create file at path: %@", localPath);
		} else {
			_cacheSize += [imageData length];
		}

        [cachedResponse release];
	}
}


- (void)clearCachedDataForRequest:(NSURLRequest *)request {
	[[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
	NSData *data = [self imageDataInCacheForURLString:[[request URL] path]];
	_cacheSize -= [data length];
	[[NSFileManager defaultManager] removeItemAtPath:[self localPathForURL:[request URL]] 
											   error:nil];
}


- (NSUInteger)sizeOfCache {
	NSString *cacheDir = [self cacheDir];
	if (_cacheSize <= 0 && cacheDir != nil) {
		NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:cacheDir];
		NSString *file;
		NSDictionary *attrs;
		NSNumber *fileSize;
		NSUInteger totalSize = 0;
		
		for (file in dirContents) {
			if ([[file pathExtension] isEqualToString:@"jpg"]) {
				attrs = [[NSFileManager defaultManager] fileAttributesAtPath:[cacheDir stringByAppendingPathComponent:file]
																traverseLink:NO];
				
				fileSize = [attrs objectForKey:NSFileSize];
				totalSize += [fileSize integerValue];
			}
		}
		
		_cacheSize = totalSize;
		//DLog(@"cache size is: %d", _cacheSize);
	}
	return _cacheSize;
}


NSInteger dateModifiedSort(id file1, id file2, void *reverse) {
	NSDictionary *attrs1 = [[NSFileManager defaultManager] attributesOfItemAtPath:file1 error:nil];
	NSDictionary *attrs2 = [[NSFileManager defaultManager] attributesOfItemAtPath:file2 error:nil];
	
	if ((NSInteger *)reverse == NO) {
		return [[attrs2 objectForKey:NSFileModificationDate] compare:[attrs1 objectForKey:NSFileModificationDate]];
	}
	
	return [[attrs1 objectForKey:NSFileModificationDate] compare:[attrs2 objectForKey:NSFileModificationDate]];
}


- (void)trimDiskCacheFilesToMaxSize:(NSUInteger)targetBytes {
	targetBytes = MIN(kMaxDiskCacheSize, MAX(0, targetBytes));
	if ([self sizeOfCache] > targetBytes) {
		//DLog(@"time to clean the cache! size is: %@, %d", [self cacheDir], [self sizeOfCache]);
		NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:[self cacheDir]];
		
		NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
		for (NSString *file in dirContents) {
			if ([[file pathExtension] isEqualToString:@"jpg"]) {
				[filteredArray addObject:[[self cacheDir] stringByAppendingPathComponent:file]];
			}
		}
		
		int reverse = YES;
		NSMutableArray *sortedDirContents = [NSMutableArray arrayWithArray:[filteredArray sortedArrayUsingFunction:dateModifiedSort context:&reverse]];
		while (_cacheSize > targetBytes && [sortedDirContents count] > 0) {
			_cacheSize -= [[[[NSFileManager defaultManager] attributesOfItemAtPath:[sortedDirContents lastObject] error:nil] objectForKey:NSFileSize] integerValue];
			[[NSFileManager defaultManager] removeItemAtPath:[sortedDirContents lastObject] error:nil];
			[sortedDirContents removeLastObject];
		}
		//DLog(@"remaining cache size: %d, target size: %d", _cacheSize, targetBytes);
        [filteredArray release];
	}
}





#pragma mark
#pragma mark ---- singleton implementation ----

+ (DiskCache *)sharedCache {
    @synchronized (sharedInstance) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized (sharedInstance) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}


@end
