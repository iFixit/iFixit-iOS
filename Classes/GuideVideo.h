//
//  GuideVideo.h
//  iFixit
//
//  Created by David Patierno on 11/16/12.
//  Copyright 2012 iFixit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuideVideo : NSObject

@property (nonatomic) NSInteger videoid;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, assign) CGSize size;

+ (GuideVideo *)guideVideoWithDictionary:(NSDictionary *)dict;

@end
