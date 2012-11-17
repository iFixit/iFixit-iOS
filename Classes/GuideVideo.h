//
//  GuideVideo.h
//  iFixit
//
//  Created by David Patierno on 11/16/12.
//  Copyright 2012 iFixit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuideVideo : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) CGSize size;

+ (GuideVideo *)guideVideoWithDictionary:(NSDictionary *)dict;

@end
