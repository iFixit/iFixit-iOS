//
//  CachedImageLoader.h
//  happyhours
//
//  Created by David Golightly on 2/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@protocol ImageConsumer <NSObject>
- (NSURLRequest *)request;
- (void)renderImage:(UIImage *)image;
@end


@interface CachedImageLoader : NSObject {
@private
	NSOperationQueue *_imageDownloadQueue;
}


+ (CachedImageLoader *)sharedImageLoader;


- (void)addClientToDownloadQueue:(id<ImageConsumer>)client;
- (UIImage *)cachedImageForClient:(id<ImageConsumer>)client;

- (void)suspendImageDownloads;
- (void)resumeImageDownloads;
- (void)cancelImageDownloads;


@end
