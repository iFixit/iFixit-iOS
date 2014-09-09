//
//  GuideStep.h
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GuideEmbed.h"
#import "GuideImage.h"
#import "GuideVideo.h"
#import "GuideStepLine.h"

@interface GuideStep : NSObject

@property (nonatomic) NSInteger number;
@property (nonatomic) NSInteger stepid;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSMutableArray *lines;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) GuideVideo *video;
@property (nonatomic, retain) GuideEmbed *embed;

+ (GuideStep *)guideStepWithDictionary:(NSDictionary *)dict;

@end
