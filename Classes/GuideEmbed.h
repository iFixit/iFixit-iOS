//
//  GuideEmbed.h
//  iFixit
//
//  Created by David Patierno on 11/16/12.
//  Copyright 2012 iFixit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuideEmbed : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) CGSize size;

+ (GuideEmbed *)guideEmbedWithDictionary:(NSDictionary *)dict;

@end
