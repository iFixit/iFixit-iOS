//
//  User.m
//  iFixit
//
//  Created by David Patierno on 5/25/11.
//  Copyright 2011 iFixit. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize data, userid, username, imageid, session;

+ (User *)userWithDictionary:(NSDictionary *)dict {
	User *user          = [[User alloc] init];
    user.data           = dict;
	user.userid 		= [dict valueForKey:@"userid"];
	user.username 		= [dict valueForKey:@"username"];
	user.imageid 		= [dict valueForKey:@"imageid"];
	user.session 		= [dict valueForKey:@"session"];
	return [user autorelease];
}

- (void)dealloc {
    [data release];
    [userid release];
    [username release];
    [imageid release];
    [session release];
    
    [super dealloc];
}

@end
