//
//  iFixitAPI.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "iFixitAPI.h"

@implementation iFixitAPI

static int volatile openConnections = 0;

/**
  * Singleton accessor.
  */
+ (iFixitAPI *)sharedInstance {
	static iFixitAPI *sharedInstance;
	
	@synchronized(self) {
		if (!sharedInstance)
			sharedInstance = [[iFixitAPI alloc] init];
		
		return sharedInstance;
	}
	
	return nil;
}

- (void)getGuide:(NSInteger)guideid forObject:(id)object withSelector:(SEL)selector {
	NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/guide/%d", IFIXIT_HOST, guideid];	

	BGNetRequest *bgnr = [BGNetRequest initWithUrl:url];
	[bgnr pushHandler:[MTHandler initForObject:object withSelector:selector]];
	[bgnr pushHandler:[MTHandler initForObject:self withSelector:@selector(gotGuide:)]];

	[self performSelectorInBackground:@selector(get:) withObject:bgnr];
}

- (void)gotGuide:(BGNetRequest *)bgnr {
	NSDictionary *data = [bgnr.data JSONValue];
	
	Guide *guide = data ? [Guide guideWithDictionary:data] : nil;

	MTHandler *handler = [bgnr popHandler];
	[handler.object performSelector:handler.selector withObject:guide];
}

- (void)getAreas:(NSString *)parent forObject:(id)object withSelector:(SEL)selector {
	if (!parent)
		parent = @"";
	
	NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/areas/%@", IFIXIT_HOST, parent];	
	
	BGNetRequest *bgnr = [BGNetRequest initWithUrl:url];
	[bgnr pushHandler:[MTHandler initForObject:object withSelector:selector]];
    [bgnr pushHandler:[MTHandler initForObject:self withSelector:@selector(gotAreas:)]];
	[self performSelectorInBackground:@selector(get:) withObject:bgnr];
}

- (void)gotAreas:(BGNetRequest *)bgnr {
	NSDictionary *areas = [bgnr.data JSONValue];
	
	MTHandler *handler = [bgnr popHandler];
	[handler.object performSelector:handler.selector withObject:areas];	
}

- (void)getFeaturedGuides:(NSString *)area forObject:(id)object withSelector:(SEL)selector {
	if (!area)
		area = @"";
	
	NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/guides/%@?sort=featured&limit=6", IFIXIT_HOST, area];	
	
	BGNetRequest *bgnr = [BGNetRequest initWithUrl:url];
	[bgnr pushHandler:[MTHandler initForObject:object withSelector:selector]];
    [bgnr pushHandler:[MTHandler initForObject:self withSelector:@selector(gotFeaturedGuides:)]];
	[self performSelectorInBackground:@selector(get:) withObject:bgnr];
}

- (void)gotFeaturedGuides:(BGNetRequest *)bgnr {
	NSArray *guides = [bgnr.data JSONValue];
	
	MTHandler *handler = [bgnr popHandler];
	[handler.object performSelector:handler.selector withObject:guides];	
}

/**
  * Background handler for HTTP GET requests.
  */
- (void)get:(BGNetRequest *)bgnr {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	openConnections++;
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];  
	[request setURL:[NSURL URLWithString:bgnr.url]];  
		
    NSError *err = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request
												returningResponse:nil
															error:&err];

	[request release];

	MTHandler *handler = [bgnr popHandler];
	bgnr.data = err ? nil : [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
	[handler.object performSelectorOnMainThread:handler.selector withObject:bgnr waitUntilDone:NO];

	if (--openConnections <= 0) {
		openConnections = 0;
		app.networkActivityIndicatorVisible = NO;
	}
	
	[pool drain];
	
}

@end
