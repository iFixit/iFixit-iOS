//
//  GuideStep.m
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "GuideStep.h"


@implementation GuideStep

@synthesize number, title, lines, images;

+ (GuideStep *)guideStepWithDictionary:(NSDictionary *)dict {
	GuideStep *guideStep = [[GuideStep alloc] init];
	
	guideStep.number = [[dict valueForKey:@"number"] integerValue];
	guideStep.title = [dict valueForKey:@"title"];
	
	// Images
	guideStep.images = [NSMutableArray array];
	NSArray *images = [dict valueForKey:@"images"];
	for (NSDictionary *image in images)
		[guideStep.images addObject:[GuideImage guideImageWithDictionary:image]];
	
	// Lines
	guideStep.lines = [NSMutableArray array];
	NSArray *lines = [dict valueForKey:@"lines"];
	for (NSDictionary *line in lines)
		[guideStep.lines addObject:[GuideStepLine guideStepLineWithDictionary:line]];
	
	return [guideStep autorelease];
}

- (void)dealloc {
    [title release];
    [lines release];
    [images release];
    
    [super dealloc];
}

@end
