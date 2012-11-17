//
//  Guide.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "Guide.h"


@implementation Guide

@synthesize data, guideid, topic, subject, title, author, timeRequired, difficulty, introduction, introduction_rendered, summary, image;
@synthesize documents, parts, tools, flags;
@synthesize prereqs, steps;

+ (NSDictionary *)repairNullsForDict:(NSDictionary *)dict {
    NSDictionary *guideData = [dict objectForKey:@"guide"];
    
    // Remove all nulls so the data can be written to disk.
    for (NSString *key in [guideData allKeys]) {
        if ([[guideData objectForKey:key] isEqual:[NSNull null]])
            [guideData setValue:@"" forKey:key];
    }

    return dict;
}

+ (Guide *)guideWithDictionary:(NSDictionary *)dict {
	Guide *guide		= [[Guide alloc] init];
    dict                = [Guide repairNullsForDict:dict];
    guide.data          = dict;
	guide.guideid		= [[dict valueForKey:@"guideid"] integerValue];
	
	NSDictionary *guideData = [dict valueForKey:@"guide"];
	
	// Meta information
	guide.title          = [guideData valueForKey:@"title"];
	guide.topic          = [dict valueForKey:@"topic"];
	guide.subject        = [guideData valueForKey:@"subject"];
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

- (void)dealloc {
    [data release];
    [title release];
    [topic release];
    [subject release];
    [author release];
    [timeRequired release];
    [difficulty release];
    [introduction release];
    [summary release];
    [introduction_rendered release];
    [image release];
    
    [documents release];
    [parts release];
    [tools release];
    [flags release];
    
    [prereqs release];
    [steps release];
    
    [super dealloc];
}

@end
