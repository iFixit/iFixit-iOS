//
//  MTHandler.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "MTHandler.h"


@implementation MTHandler

@synthesize object, selector;

+ (MTHandler *)initForObject:(id)object withSelector:(SEL)selector {
	MTHandler *handler = [[MTHandler alloc] init];
	handler.object = object;
	handler.selector = selector;
	return [handler autorelease];
}


@end
