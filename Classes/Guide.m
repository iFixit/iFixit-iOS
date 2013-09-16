//
//  Guide.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "Guide.h"


@implementation Guide

@synthesize data, guideid, category, subject, title, author, timeRequired, difficulty, introduction, introduction_rendered, summary, image;
@synthesize documents, parts, tools, flags;
@synthesize prereqs, steps;

+ (NSDictionary *)repairNullsForDict:(NSDictionary *)dict {
    
    // Remove all nulls so the data can be written to disk.
    for (NSString *key in [dict allKeys]) {
        if ([[dict objectForKey:key] isEqual:[NSNull null]])
            [dict setValue:@"" forKey:key];
    }

    return dict;
}

+ (Guide *)guideWithDictionary:(NSDictionary *)dict {
	Guide *guide		= [[Guide alloc] init];
    dict                = [Guide repairNullsForDict:dict];
    guide.data          = dict;
	guide.guideid		= [dict[@"guideid"] integerValue];
	
	//NSDictionary *guideData = [dict valueForKey:@"guide"];
	
	// Meta information
	guide.title          = dict[@"title"];
	guide.category       = dict[@"category"];
	guide.subject        = dict[@"subject"];
	guide.author         = dict[@"author"][@"username"];
	guide.timeRequired   = dict[@"time_required"];
	guide.difficulty     = dict[@"difficulty"];
	guide.introduction   = dict[@"introduction_raw"];
	guide.summary        = dict[@"summary"];
	guide.introduction_rendered = dict[@"introduction_rendered"];

	// Main image
	NSDictionary *image	= dict[@"image"];
	guide.image			= [GuideImage guideImageWithDictionary:image];

	// Steps
	guide.steps = [NSMutableArray array];
	NSArray *steps		= dict[@"steps"];
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
    [category release];
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
