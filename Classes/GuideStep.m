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
	
	guideStep.number = [[dict valueForKey:@"number"] integerValue];
	guideStep.title = [dict valueForKey:@"title"];
	
    // Media
    NSDictionary *media = [dict valueForKey:@"media"];

    // Possible types: image, video, embed
    // If *media is empty, then there will be no
    // type so we want to default to an image type
    NSString *type = media ? [media objectForKey:@"type"] : @"image";

    if ([type isEqual:@"image"]) {
        guideStep.images = [NSMutableArray array];
        NSArray *images = [media valueForKey:@"image"];
        for (NSDictionary *image in images)
            [guideStep.images addObject:[GuideImage guideImageWithDictionary:image]];
    } else if ([type isEqual:@"video"]) {
        NSDictionary *video = [media objectForKey:@"video"];
        guideStep.video = [GuideVideo guideVideoWithDictionary:video];
    } else if ([type isEqual:@"embed"]) {
        NSDictionary *embed = [media objectForKey:@"embed"];
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
