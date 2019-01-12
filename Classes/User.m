//
//  User.m
//  iFixit
//
//  Created by David Patierno on 5/25/11.
//  Copyright 2011 iFixit. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize data, iUserid, username, iImageid, session;

+ (User *)userWithDictionary:(NSDictionary *)dict {
	User *user          = [[User alloc] init];
    user.data           = dict;
	user.iUserid 		= dict[@"userid"];
	user.username 		= dict[@"username"];
	user.iImageid 		= ![dict[@"image"] isEqual:[NSNull null]] ? dict[@"image"][@"id"] : nil;
	user.session 		= dict[@"authToken"];
    
	return [user autorelease];
}

- (void)dealloc {
    [data release];
    [iUserid release];
    [username release];
    [iImageid release];
    [session release];
    
    [super dealloc];
}

@end
