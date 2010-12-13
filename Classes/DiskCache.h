//
//  DiskCache.h
//  happyhours
//
//  Created by David Golightly on 2/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


@interface DiskCache : NSObject {
@private
	NSString *_cacheDir;
	NSUInteger _cacheSize;
}

@property (nonatomic, readonly) NSUInteger sizeOfCache;
@property (nonatomic, readonly) NSString *cacheDir;

+ (DiskCache *)sharedCache;

- (NSData *)imageDataInCacheForURLString:(NSString *)urlString;
- (void)cacheImageData:(NSData *)imageData   
			   request:(NSURLRequest *)request
			  response:(NSURLResponse *)response;
- (void)clearCachedDataForRequest:(NSURLRequest *)request;


@end
