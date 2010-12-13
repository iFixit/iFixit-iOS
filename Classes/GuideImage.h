//
//  GuideImage.h
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GuideImage : NSObject {
	NSNumber *imageid;
	NSString *url;
	UIImage *mini;
	UIImage *thumbnail;
	UIImage *standard;
	UIImage *medium;
	UIImage *large;
	UIImage *huge;
}

@property (nonatomic, retain) NSNumber *imageid;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) UIImage *mini;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) UIImage *standard;
@property (nonatomic, retain) UIImage *medium;
@property (nonatomic, retain) UIImage *large;
@property (nonatomic, retain) UIImage *huge;

+ (GuideImage *)guideImageWithDictionary:(NSDictionary *)dict;
- (NSURL *)URLForSize:(NSString *)size;

@end
