//
//  Guide.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "Guide.h"


@implementation Guide

@synthesize guideid, device, title, author, timeRequired, difficulty, introduction, introduction_rendered, summary, image;
@synthesize documents, parts, tools, flags;
@synthesize prereqs, steps;

+ (Guide *)guideWithDictionary:(NSDictionary *)dict {
	Guide *guide		= [[Guide alloc] init];
	guide.guideid		= [[dict valueForKey:@"guideid"] integerValue];
	
	NSDictionary *guideData = [dict valueForKey:@"guide"];
	
	// Meta information
	guide.title          = [guideData valueForKey:@"title"];
	guide.device         = [guideData valueForKey:@"device"];
	guide.author         = [guideData valueForKey:@"author"];
	guide.timeRequired   = [guideData valueForKey:@"time"];
	guide.difficulty     = [guideData valueForKey:@"difficulty"];
	guide.introduction   = [guideData valueForKey:@"introduction"];
	guide.summary        = [guideData valueForKey:@"summary"];
	guide.introduction_rendered = [guideData valueForKey:@"introduction_rendered"];

	// Main image
	NSDictionary *image	= [guideData valueForKey:@"image"];
	guide.image			= [GuideImage guideImageWithDictionary:image];

	// Steps
	guide.steps = [NSMutableArray array];
	NSArray *steps		= [guideData valueForKey:@"steps"];
	for (NSDictionary *step in steps)
		[guide.steps addObject:[GuideStep guideStepWithDictionary:step]];
	
	// Prereqs
	
	// Parts
	
	// Tools
	
	// Flags
	
	return [guide autorelease];
}

@end
