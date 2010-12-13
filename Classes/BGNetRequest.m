//
//  BGNetRequest.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "BGNetRequest.h"


@implementation BGNetRequest

@synthesize url, data, handlers;

+ (BGNetRequest *)initWithUrl:(NSString *)url {
	BGNetRequest *bgnr = [[BGNetRequest alloc] init];
	bgnr.url = url;
	bgnr.handlers = [NSMutableArray array];
	return [bgnr autorelease];
}

- (void)pushHandler:(MTHandler *)handler {
	[handlers addObject:handler];
}

- (MTHandler *)popHandler {
	MTHandler *handler = [[handlers lastObject] retain];
	[handlers removeObject:handler];
	return [handler autorelease];
}

@end
