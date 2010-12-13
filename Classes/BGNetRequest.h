//
//  BGNetRequest.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTHandler.h"

@interface BGNetRequest : NSObject {

	NSString *url;
	NSMutableArray *handlers;
	NSString *data;
	
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *data;
@property (nonatomic, retain) NSMutableArray *handlers;

+ (BGNetRequest *)initWithUrl:(NSString *)url;
- (void)pushHandler:(MTHandler *)handler;
- (MTHandler *)popHandler;
@end
