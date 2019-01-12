//
//  GuideStepLine.m
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "GuideStepLine.h"


@implementation GuideStepLine

@synthesize lineid, level, bullet, text;

+ (GuideStepLine *)guideStepLineWithDictionary:(NSDictionary *)dict {
	GuideStepLine *guideStepLine = [[GuideStepLine alloc] init];
	guideStepLine.bullet = dict[@"bullet"];
	guideStepLine.level  = [dict[@"level"] integerValue];
	guideStepLine.text   = dict[@"text_rendered"];
	return [guideStepLine autorelease];
}

- (void)dealloc {
    [bullet release];
    [text release];
    
    [super dealloc];
}
@end
