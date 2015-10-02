//
//  GuideImage.m
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "GuideImage.h"


@implementation GuideImage

@synthesize iImageid, url, mini, thumbnail, standard, medium, large, huge;

+ (GuideImage *)guideImageWithDictionary:(NSDictionary *)dict {
	GuideImage *guideImage = [[GuideImage alloc] init];
	guideImage.iImageid = dict[@"id"];
	guideImage.url = dict[@"original"];
	return guideImage;
}

- (NSURL *)URLForSize:(NSString *)size {
   return [NSURL URLWithString:[NSString stringWithFormat:@"%@.%@", url, size]];
}

@end
