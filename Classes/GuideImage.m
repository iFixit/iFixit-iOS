//
//  GuideImage.m
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "GuideImage.h"


@implementation GuideImage

@synthesize imageid, url, mini, thumbnail, standard, medium, large, huge;

+ (GuideImage *)guideImageWithDictionary:(NSDictionary *)dict {
	GuideImage *guideImage = [[GuideImage alloc] init];
	guideImage.imageid = dict[@"id"];
	guideImage.url = dict[@"original"];
	return [guideImage autorelease];
}

- (NSURL *)URLForSize:(NSString *)size {
   return [NSURL URLWithString:[NSString stringWithFormat:@"%@.%@", url, size]];
}

- (void)dealloc {
    [imageid release];
    [url release];
    [mini release];
    [thumbnail release];
    [standard release];
    [medium release];
    [large release];
    [huge release];
    
    [super dealloc];
}

@end
