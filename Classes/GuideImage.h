//
//  GuideImage.h
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

@interface GuideImage : NSObject

@property (nonatomic, retain) NSNumber *iImageid;
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
