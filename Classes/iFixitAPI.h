//
//  iFixitAPI.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

@class User;

@interface iFixitAPI : NSObject {
    User *user;
}

@property (nonatomic, retain) User *user;

+ (iFixitAPI *)sharedInstance;

// Anonymous
- (void)getSitesWithLimit:(NSUInteger)limit andOffset:(NSUInteger)offset forObject:(id)object withSelector:(SEL)selector;
- (void)getGuide:(NSInteger)guideid forObject:(id)object withSelector:(SEL)selector;
- (void)getAreas:(NSString *)parent forObject:(id)object withSelector:(SEL)selector;
- (void)getGuides:(NSString *)type forObject:(id)object withSelector:(SEL)selector;
- (void)getSearchResults:(NSString *)search forObject:(id)object withSelector:(SEL)selector;
- (void)getDevice:(NSString *)device forObject:(id)object withSelector:(SEL)selector;

// Session management
- (void)loginWithLogin:(NSString *)login andPassword:(NSString *)password forObject:(id)object withSelector:(SEL)selector;
- (void)registerWithLogin:(NSString *)login andPassword:(NSString *)password andName:(NSString *)name forObject:(id)object withSelector:(SEL)selector;
- (void)logout;

// Authenticated
- (void)getUserLikesForObject:(id)object withSelector:(SEL)selector;
- (void)like:(NSNumber *)guideid forObject:(id)object withSelector:(SEL)selector;
- (void)unlike:(NSNumber *)guideid forObject:(id)object withSelector:(SEL)selector;
- (void)loadSession;

@end
