//
//  iFixitAPI.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTHandler.h"
#import "BGNetRequest.h"
#import "Guide.h"
#import "JSON.h"

@interface iFixitAPI : NSObject {
}

+ (iFixitAPI *)sharedInstance;
- (void)getGuide:(NSInteger)guideid forObject:(id)object withSelector:(SEL)selector;
- (void)getAreas:(NSString *)parent forObject:(id)object withSelector:(SEL)selector;
- (void)getFeaturedGuides:(NSString *)area forObject:(id)object withSelector:(SEL)selector;
- (void)get:(BGNetRequest *)bgnr;
@end
