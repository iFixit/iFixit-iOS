//
//  iFixitAPI.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

@class User;

@interface iFixitAPI : NSObject<UIAlertViewDelegate>

@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSString *appId;
@property (nonatomic, retain) NSString *userAgent;

+ (iFixitAPI *)sharedInstance;

// Anonymous
- (void)getSitesWithLimit:(NSUInteger)limit andOffset:(NSUInteger)offset forObject:(id)object withSelector:(SEL)selector;
- (void)getCollectionsWithLimit:(NSUInteger)limit andOffset:(NSUInteger)offset forObject:(id)object withSelector:(SEL)selector;
- (void)getGuide:(NSNumber *)iGuideid forObject:(id)object withSelector:(SEL)selector;
- (void)getCategoriesForObject:(id)object withSelector:(SEL)selector;
- (void)getGuides:(NSString *)type forObject:(id)object withSelector:(SEL)selector;
- (void)getGuidesByIds:(NSArray *)guideids forObject:(id)object withSelector:(SEL)selector;
- (void)getSearchResults:(NSString *)search withFilter:(NSString *)filter forObject:(id)object withSelector:(SEL)selector;
- (void)getCategory:(NSString *)category forObject:(id)object withSelector:(SEL)selector;
- (void)getSiteInfoForObject:(id)object withSelector:(SEL)selector;

// Session management
- (void)loginWithSessionId:(NSString *)sessionId forObject:(id)object withSelector:(SEL)selector;
- (void)loginWithLogin:(NSString *)login andPassword:(NSString *)password forObject:(id)object withSelector:(SEL)selector;
- (void)registerWithLogin:(NSString *)login andPassword:(NSString *)password andName:(NSString *)name andUsername:(NSString *)username forObject:(id)object withSelector:(SEL)selector;
- (void)logout;

// Authenticated
- (void)getUserFavoritesForObject:(id)object withSelector:(SEL)selector;
- (void)like:(NSNumber *)iGuideid forObject:(id)object withSelector:(SEL)selector;
- (void)unlike:(NSNumber *)iGuideid forObject:(id)object withSelector:(SEL)selector;
- (void)loadSession;

// Error handling
+ (void)displayConnectionErrorAlert;
+ (void)displayLoggedOutErrorAlert:(UIViewController*)vc;

// Authentication Handeling
+ (void)checkCredentialsForViewController:(id)viewController;

@end
