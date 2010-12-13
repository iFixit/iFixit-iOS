//
//  Guide.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GuideImage.h"
#import "GuideStep.h"
#import "GuideStepLine.h"

@interface Guide : NSObject {
	NSInteger guideid;
	NSString *title;
	NSString *device;
	NSString *author;
	NSString *timeRequired;
	NSString *difficulty;
	NSString *introduction;
	NSString *summary;
	NSString *introduction_rendered;
	GuideImage *image;
	
	NSMutableArray *documents;
	NSMutableArray *parts;
	NSMutableArray *tools;
	NSMutableArray *flags;
	
	NSMutableArray *prereqs;
	NSMutableArray *steps;
}

@property (nonatomic) NSInteger guideid;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *device;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *timeRequired;
@property (nonatomic, retain) NSString *difficulty;
@property (nonatomic, retain) NSString *introduction;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *introduction_rendered;
@property (nonatomic, retain) GuideImage *image;

@property (nonatomic, retain) NSMutableArray *documents;
@property (nonatomic, retain) NSMutableArray *parts;
@property (nonatomic, retain) NSMutableArray *tools;
@property (nonatomic, retain) NSMutableArray *flags;

@property (nonatomic, retain) NSMutableArray *prereqs;
@property (nonatomic, retain) NSMutableArray *steps;

+ (Guide *)guideWithDictionary:(NSDictionary *)dict;

@end
