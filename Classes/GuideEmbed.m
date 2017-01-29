//
//  GuideEmbed.m
//  iFixit
//
//  Created by David Patierno on 11/16/12.
//  Copyright 2012 iFixit. All rights reserved.
//

#import "GuideEmbed.h"

@implementation GuideEmbed

@synthesize url = _url,
            size = _size,
            type = _type;

+ (GuideEmbed *)guideEmbedWithDictionary:(NSDictionary *)dict {
  GuideEmbed *guideEmbed = [[GuideEmbed alloc] init];
  NSString *url = [dict valueForKey:@"url"];
  guideEmbed.url = [NSString stringWithFormat:@"%@&format=json", url, nil];
  guideEmbed.type = [dict valueForKey:@"type"];
  guideEmbed.size = CGSizeMake([[dict valueForKey:@"width"] floatValue],
                               [[dict valueForKey:@"height"] floatValue]);
  return [guideEmbed autorelease];
}

- (void)dealloc {
  [_url release];
  [_type release];

  [super dealloc];
}

@end
