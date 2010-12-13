//
//  GuideStep.h
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GuideImage.h"
#import "GuideStepLine.h"

@interface GuideStep : NSObject {
	NSInteger number;
	NSString *title;
	NSMutableArray *lines;
	NSMutableArray *images;
}

@property (nonatomic) NSInteger number;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSMutableArray *lines;
@property (nonatomic, retain) NSMutableArray *images;

+ (GuideStep *)guideStepWithDictionary:(NSDictionary *)dict;

@end
