//
//  Guide.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "Guide.h"


@implementation Guide

@synthesize data, iGuideid, category, subject, title, author, timeRequired, difficulty, introduction, introduction_rendered, summary, image;
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
	Guide *guide                = [[Guide alloc] init];
    dict                        = [Guide repairNullsForDict:dict];
    guide.data                  = dict;
	guide.iGuideid              = dict[@"guideid"];

	// Meta information
	guide.title                 = dict[@"title"];
	guide.category              = dict[@"category"];
	guide.subject               = dict[@"subject"];
	guide.author                = dict[@"author"][@"username"];
	guide.timeRequired          = dict[@"time_required"];
	guide.difficulty            = dict[@"difficulty"];
	guide.introduction          = dict[@"introduction_raw"];
	guide.summary               = dict[@"summary"];
	guide.introduction_rendered = dict[@"introduction_rendered"];
    guide.iModifiedDate         = [NSNumber numberWithInteger:[dict[@"modified_date"] integerValue]];
    guide.iPrereqModifiedDate   = [NSNumber numberWithInteger:[dict[@"prereq_modified_date"] integerValue]];

	// Main image
	id image	= dict[@"image"];
	guide.image	= [image isKindOfClass:[NSDictionary class]] ?
                  [GuideImage guideImageWithDictionary:image] : nil;

	// Steps
	guide.steps = [NSMutableArray array];
	NSArray *steps		= dict[@"steps"];
	for (NSDictionary *step in steps)
		[guide.steps addObject:[GuideStep guideStepWithDictionary:step]];
	
	// Prereqs
	
	// Parts
    guide.parts = dict[@"parts"];
	
	// Tools
    guide.tools = dict[@"tools"];
    
    // Documents
    guide.documents = dict[@"documents"];
    
	// Flags
	
	return guide;
}

-(NSNumber*)getAbsoluteModifiedDate {
    return [@[self.iModifiedDate, self.iPrereqModifiedDate] valueForKeyPath:@"@max.intValue"];
}

+(NSNumber*)getAbsoluteModifiedDateFromGuideDictionary:(NSDictionary*)guideData {
    return [@[[NSNumber numberWithInteger:[guideData[@"modified_date"] integerValue]],
              [NSNumber numberWithInteger:[guideData[@"prereq_modified_date"] integerValue]]
            ] valueForKeyPath:@"@max.intValue"];
}

@end
