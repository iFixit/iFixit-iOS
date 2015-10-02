//
//  GuideVideo.m
//  iFixit
//
//  Created by David Patierno on 11/16/12.
//  Copyright 2012 iFixit. All rights reserved.
//

#import "GuideVideo.h"

@implementation GuideVideo

@synthesize url = _url,
            size = _size,
            videoid = _videoid;

+ (GuideVideo *)guideVideoWithDictionary:(NSDictionary *)dict {
    NSArray *encodings = dict[@"encodings"];
  
    for (NSDictionary *encoding in encodings) {
        // Just grab the first mp4 available.
        if ([encoding[@"format"] isEqual:@"mp4"]) {
            GuideVideo *guideVideo = [[GuideVideo alloc] init];
            guideVideo.videoid = [dict[@"videoid"] integerValue];
            guideVideo.filename = dict[@"filename"];
            guideVideo.url = encoding[@"url"];
            guideVideo.size = CGSizeMake([encoding[@"width"] floatValue],
                                         [encoding[@"height"] floatValue]);
            return guideVideo;
        }
    }
    
    return nil;
}

@end
