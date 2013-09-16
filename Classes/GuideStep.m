//
//  GuideStep.m
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "GuideStep.h"


@implementation GuideStep

@synthesize number, title, lines, images, video, embed;

+ (GuideStep *)guideStepWithDictionary:(NSDictionary *)dict {
	GuideStep *guideStep = [[GuideStep alloc] init];
	
	guideStep.number = [dict[@"orderby"] integerValue];
	guideStep.title = dict[@"title"];
	
    // Media
    NSDictionary *media = dict[@"media"];

    // Possible types: image, video, embed
    NSString *type = media[@"type"];

    if ([type isEqual:@"image"]) {
        guideStep.images = [NSMutableArray array];
        NSArray *images = media[@"image"];
        for (NSDictionary *image in images)
            [guideStep.images addObject:[GuideImage guideImageWithDictionary:image]];
    } else if ([type isEqual:@"video"]) {
        NSDictionary *video = media[@"data"];
        guideStep.video = [GuideVideo guideVideoWithDictionary:video];
    } else if ([type isEqual:@"embed"]) {
        NSDictionary *embed = media[@"data"];
        guideStep.embed = [GuideEmbed guideEmbedWithDictionary:embed];
    }

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
    [video release];
    [embed release];
    
    [super dealloc];
}

@end
