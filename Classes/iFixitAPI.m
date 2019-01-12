//
//  iFixitAPI.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "iFixitAPI.h"
#import "iFixitAppDelegate.h"
#import "Guide.h"
#import "JSON.h"
#import "Config.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "User.h"
#import "GuideBookmarks.h"
#import "BookmarksViewController.h"
#import "LoginViewController.h"
#import "ListViewController.h"
#import "Utility.h"

@implementation iFixitAPI

static int volatile openConnections = 0;

- (NSString *)sessionFilePath {
      NSString *filename = [NSString stringWithFormat:@"%@_session.plist",
                            [Config currentConfig].host];
      
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
      NSString *docDirectory = [paths objectAtIndex:0];
      return [docDirectory stringByAppendingPathComponent:filename];
}

- (void)loadAppId {
      // look for the iFixit app id by default
      NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"iFixit-App-Id" ofType: @"plist"];
      NSString *appId = [NSDictionary dictionaryWithContentsOfFile:plistPath][@"dozuki"];
      
      self.appId = appId ? appId : @"";
}

- (void)saveSession {
      if (self.user) {
            // Write to disk
            [@{@"userJson": [Utility serializeDictionary:self.user.data]} writeToFile:[self sessionFilePath] atomically:YES];
      } else {
            // Clear the session
            [[NSFileManager defaultManager] removeItemAtPath:[self sessionFilePath] error:nil];
      }
}

- (void)loadSession {
      // Read from disk
      NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:[self sessionFilePath]];
      
      // Only deserialize json data if we need to
      if ([data objectForKey:@"userJson"]) {
            data = [Utility deserializeJsonString:data[@"userJson"]];
      }
      
      self.user = data ? [User userWithDictionary:data] : nil;
}

/**
 * Singleton accessor.
 */
+ (iFixitAPI *)sharedInstance {
      static iFixitAPI *sharedInstance;
      
      @synchronized(self) {
            if (!sharedInstance) {
                  sharedInstance = [[iFixitAPI alloc] init];
                  [sharedInstance loadSession];
                  [sharedInstance loadAppId];
                  [sharedInstance createAndSetUserAgent];
            }
            
            return sharedInstance;
      }
      
      return nil;
}

- (void)getSitesWithLimit:(NSUInteger)limit andOffset:(NSUInteger)offset forObject:(id)object withSelector:(SEL)selector usePublic:(BOOL)pub {
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/sites?limit=%d&offset=%d&disableCacheGets", pub?[Config currentConfig].dozukiHost:[Config currentConfig].host, limit, offset];
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      if ([Config currentConfig].site == ConfigIFixitDev) {
            request.validatesSecureCertificate = NO;
      }
      
      [request setCompletionBlock:^{
            NSArray *results = [[request responseString] JSONValue];
            [object performSelector:selector withObject:results];
      }];
      [request setFailedBlock:^{
            [object performSelector:selector withObject:nil];
      }];
      [request startAsynchronous];
}

- (void)getSiteInfoForObject:(id)object withSelector:(SEL)selector {
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/info", [Config currentConfig].host];
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      if ([Config currentConfig].site == ConfigIFixitDev) {
            request.validatesSecureCertificate = NO;
      }
      
      [request addRequestHeader:@"X-App-Id" value:self.appId];
      [self addAuthorizationHeaderToRequest:request];
      
      [request setCompletionBlock:^{
            NSDictionary *results = [[request responseString] JSONValue];
            [object performSelector:selector withObject:results];
      }];
      [request setFailedBlock:^{
            [object performSelector:selector withObject:nil];
      }];
      [request startAsynchronous];
}

- (void)getCollectionsWithLimit:(NSUInteger)limit andOffset:(NSUInteger)offset forObject:(id)object withSelector:(SEL)selector {
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/collections?limit=%d&offset=%d", [Config currentConfig].host, limit, offset];
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      if ([Config currentConfig].site == ConfigIFixitDev) {
            request.validatesSecureCertificate = NO;
      }
      
      
      [request addRequestHeader:@"X-App-Id" value:self.appId];
      [self addAuthorizationHeaderToRequest:request];
      
      [request setCompletionBlock:^{
            NSArray *results = [[request responseString] JSONValue];
            [object performSelector:selector withObject:results];
      }];
      [request setFailedBlock:^{
            [object performSelector:selector withObject:nil];
      }];
      [request startAsynchronous];
}

- (void)addAuthorizationHeaderToRequest:(ASIHTTPRequest *)request {
      
      [self addAuthorizationHeaderToRequest:request sessionID:nil];
      
}

- (void)addAuthorizationHeaderToRequest:(ASIHTTPRequest *)request sessionID:(NSString*)sessionId {
      if (self.user) {
//            BFLog(@"self.user was set using header Authorization %@", [NSString stringWithFormat:@"api %@", self.user.session]);
            [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"api %@", self.user.session]];
      } else if (sessionId!=nil) {
//            BFLog(@"sessionID header Authorization %@", [NSString stringWithFormat:@"api %@", sessionId]);
            [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"api %@", sessionId]];
      } else {
//            BFLog(@"cound not set header there is no self.user");
      }
}

- (void)getGuide:(NSNumber *)iGuideid forObject:(id)object withSelector:(SEL)selector {
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/guides/%@", [Config currentConfig].host, iGuideid];
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      if ([Config currentConfig].site == ConfigIFixitDev) {
            request.validatesSecureCertificate = NO;
      }
      
      [request addRequestHeader:@"X-App-Id" value:self.appId];
      [self addAuthorizationHeaderToRequest:request];
      
      [request setCompletionBlock:^{
            NSDictionary *result = [[request responseString] JSONValue];
            Guide *guide = result ? [Guide guideWithDictionary:result] : nil;
            [object performSelector:selector withObject:guide];
      }];
      [request setFailedBlock:^{
            [object performSelector:selector withObject:nil];
      }];
      [request startAsynchronous];
}

- (void)getCategoriesForObject:(id)object withSelector:(SEL)selector {
      // On iPhone and iPod touch, only show leaf nodes with viewable guides.
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/categories?withDisplayTitles", [Config currentConfig].host];
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      if ([Config currentConfig].site == ConfigIFixitDev) {
            request.validatesSecureCertificate = NO;
      }
      
      [request addRequestHeader:@"X-App-Id" value:self.appId];
      [self addAuthorizationHeaderToRequest:request];
      
      [request setCompletionBlock:^{
            NSDictionary *results = [[request responseString] JSONValue];
            [object performSelector:selector withObject:results];
      }];
      [request setFailedBlock:^{
            [object performSelector:selector withObject:nil];
      }];
      [request startAsynchronous];
}

- (void)getCategory:(NSString *)category forObject:(id)object withSelector:(SEL)selector {
      category = [category stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      category = [category stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
      category = [category stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
      
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/wikis/CATEGORY/%@?langid=%@", [Config currentConfig].host, category, [Utility getDeviceLanguage]];
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      [request addRequestHeader:@"X-App-Id" value:self.appId];
      [self addAuthorizationHeaderToRequest:request];
      
      if ([Config currentConfig].site == ConfigIFixitDev) {
            request.validatesSecureCertificate = NO;
      }
      
      [request setCompletionBlock:^{
            NSDictionary *results = [[request responseString] JSONValue];
            [object performSelector:selector withObject:results];
      }];
      [request setFailedBlock:^{
            [object performSelector:selector withObject:nil];
      }];
      [request startAsynchronous];
}

- (void)getGuides:(NSString *)type forObject:(id)object withSelector:(SEL)selector {
      int limit = 100;
      
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/guides?limit=%d", [Config currentConfig].host, limit];
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      if ([Config currentConfig].site == ConfigIFixitDev) {
            request.validatesSecureCertificate = NO;
      }
      
      [request addRequestHeader:@"X-App-Id" value:self.appId];
      [self addAuthorizationHeaderToRequest:request];
      
      [request setCompletionBlock:^{
            NSArray *results = [[request responseString] JSONValue];
            [object performSelector:selector withObject:results];
      }];
      [request setFailedBlock:^{
            [object performSelector:selector withObject:nil];
      }];
      [request startAsynchronous];
}

- (void)getGuidesByIds:(NSArray *)guideids forObject:(id)object withSelector:(SEL)selector {
      NSString *guideidsString = [guideids componentsJoinedByString:@","];
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/guides?guideids=%@", [Config currentConfig].host, guideidsString];
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      [request addRequestHeader:@"X-App-Id" value:self.appId];
      [self addAuthorizationHeaderToRequest:request];
      
      if ([Config currentConfig].site == ConfigIFixitDev) {
            request.validatesSecureCertificate = NO;
      }
      
      [request setCompletionBlock:^{
            NSArray *results = [[request responseString] JSONValue];
            [object performSelector:selector withObject:results];
      }];
      [request setFailedBlock:^{
            [object performSelector:selector withObject:nil];
      }];
      [request startAsynchronous];
}

- (void)getSearchResults:(NSString *)search withFilter:(NSString *)filter forObject:(id)object withSelector:(SEL)selector {
      search = [search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      search = [search stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
      search = [search stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
      
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/search/%@?limit=50&filter=%@", [Config currentConfig].host, search, filter];
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      [request addRequestHeader:@"X-App-Id" value:self.appId];
      [self addAuthorizationHeaderToRequest:request];
      
      [request setCompletionBlock:^{
            NSDictionary *results = [[request responseString] JSONValue];
            [object performSelector:selector withObject:results];
      }];
      [request setFailedBlock:^{
            [object performSelector:selector withObject:nil];
      }];
      [request startAsynchronous];
}

- (void)checkLogin:(NSDictionary *)results {
      if ([results respondsToSelector:@selector(valueForKey:)]) {
            if ([results valueForKey:@"authToken"]) {
                  self.user = [User userWithDictionary:results];
                  [self saveSession];
            }
      }
}

- (void)checkSession:(NSDictionary *)results {
      // Check for invalid sessionid
      if ([results isKindOfClass:[NSDictionary class]] && results[@"error"] && ([results[@"msg"] isEqual:@"Authentication needed"] || [results[@"msg"] isEqual:@"Invalid login"])) {
            self.user = nil;
            [self saveSession];
      }
}

- (void)loginWithSessionId:(NSString *)sessionId forObject:(id)object withSelector:(SEL)selector {
      
      // .dozuki.com hosts force SSL, so we match that here. Otherwise, for SSO sites with custom domains,
      // SSL doesn't exist so we just use HTTP.
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/user", [Config currentConfig].host];
      
//      BFLog(@"curent config host %@", [Config currentConfig].host);
//      BFLog(@"sessionId %@", sessionId);
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      [request setRequestMethod:@"GET"];
      
      [request addRequestHeader:@"X-App-Id" value:self.appId];
//      BFLog(@"self.appId %@", self.appId);
      
      [self addAuthorizationHeaderToRequest:request sessionID:sessionId];
      request.useCookiePersistence = NO;
      
      [request setCompletionBlock:^{
            NSMutableDictionary *results = [[request responseString] JSONValue];
//            BFLog(@"completion %@", results);
            
            [self checkLogin:results];
            [object performSelector:selector withObject:results];
      }];
      [request setFailedBlock:^{
            NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"error", [[request error] localizedDescription], @"msg", nil];
//            BFLog(@"failed %@", results);
            [object performSelector:selector withObject:results];
      }];
      
      [request startAsynchronous];
}


- (void)loginWithLogin:(NSString *)login andPassword:(NSString *)password forObject:(id)object withSelector:(SEL)selector {
      
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/user/token", [Config currentConfig].host];
      NSString *json = [@{@"email" : login, @"password" : password} JSONRepresentation];
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      if ([Config currentConfig].site == ConfigIFixitDev || [Config currentConfig].site == ConfigMakeDev)
            [request setValidatesSecureCertificate:NO];
      
      [request setRequestMethod:@"POST"];
      [request addRequestHeader:@"X-App-Id" value:self.appId];
      [request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
      request.useCookiePersistence = NO;
      
      [request setCompletionBlock:^{
            NSMutableDictionary *results = [[request responseString] JSONValue];
            [self checkLogin:results];
            [results setObject:@"login" forKey:@"type"];
            [object performSelector:selector withObject:results];
      }];
      
      [request setFailedBlock:^{
            NSDictionary *results = [[request responseString] JSONValue];
            [object performSelector:selector withObject:results];
      }];
      
      [request startAsynchronous];
}

- (void)registerWithLogin:(NSString *)login andPassword:(NSString *)password andName:(NSString *)name andUsername:(NSString *)username forObject:(id)object withSelector:(SEL)selector {
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/users", [Config currentConfig].host];
      NSString *json = [@{@"email" : login, @"username" : name, @"password" : password, @"unique_username" : username} JSONRepresentation];
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      if ([Config currentConfig].site == ConfigIFixitDev || [Config currentConfig].site == ConfigMakeDev)
            [request setValidatesSecureCertificate:NO];
      
      [request setRequestMethod:@"POST"];
      [request addRequestHeader:@"X-App-Id" value:self.appId];
      [request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
      request.useSessionPersistence = NO;
      request.useCookiePersistence = NO;
      
      [request setCompletionBlock:^{
            NSMutableDictionary *results = [[request responseString] JSONValue];
            [self checkLogin:results];
            [results setObject:@"register" forKey:@"type"];
            
            [object performSelector:selector withObject:results];
      }];
      [request setFailedBlock:^{
            NSString *responseString = [request responseString];
            if (responseString != nil) {
                  NSLog(@"ResponseString:%@",responseString);
                  NSMutableDictionary *results = [[request responseString] JSONValue];
                  responseString = [results valueForKey:@"message"];
            } else {
                  responseString = @"Server error.";
            }
            NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"error", [[request error] localizedDescription], @"msg", responseString, @"message", nil];
            [object performSelector:selector withObject:results];
      }];
      
      [request startAsynchronous];
}

- (void)logout {
      // Clear all cookies.
      NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
      for (NSHTTPCookie *cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
      }
      
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/user/token", [Config currentConfig].host];
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      if ([Config currentConfig].site == ConfigIFixitDev) {
            request.validatesSecureCertificate = NO;
      }
      
      [request addRequestHeader:@"X-App-Id" value:self.appId];
      [self addAuthorizationHeaderToRequest:request];
      [request setRequestMethod:@"DELETE"];
      [request startAsynchronous];
      
      self.user = nil;
      
      [self saveSession];
      // Reset GuideBookmarks static object.
      [GuideBookmarks reset];
}

- (void)getUserFavoritesForObject:(id)object withSelector:(SEL)selector {
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/user/favorites/guides", [Config currentConfig].host];
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      if ([Config currentConfig].site == ConfigIFixitDev) {
            request.validatesSecureCertificate = NO;
      }
      
      [request addRequestHeader:@"X-App-Id" value:self.appId];
      [self addAuthorizationHeaderToRequest:request];
      [request setRequestMethod:@"GET"];
      request.useCookiePersistence = NO;
      
      [request setCompletionBlock:^{
            NSDictionary *results = [[request responseString] JSONValue];
            [self checkSession:results];
            [object performSelector:selector withObject:results];
      }];
      [request setFailedBlock:^{
            NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"error", [[request error] localizedDescription], @"msg", nil];
            [object performSelector:selector withObject:results];
      }];
      
      [request startAsynchronous];
}

- (void)like:(NSNumber *)iGuideid forObject:(id)object withSelector:(SEL)selector {
      
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/user/favorites/guides/%@", [Config currentConfig].host, iGuideid];
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      if ([Config currentConfig].site == ConfigIFixitDev) {
            request.validatesSecureCertificate = NO;
      }
      
      [request setRequestMethod:@"PUT"];
      [request addRequestHeader:@"X-App-Id" value:self.appId];
      [self addAuthorizationHeaderToRequest:request];
      request.useCookiePersistence = NO;
      
      [request setCompletionBlock:^{
            NSDictionary *results = @{@"statusCode" : @([request responseStatusCode])};
            [self checkSession:results];
            [object performSelector:selector withObject:results];
      }];
      [request setFailedBlock:^{
            NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"error", [[request error] localizedDescription], @"msg", nil];
            [object performSelector:selector withObject:results];
      }];
      
      [request startAsynchronous];
}

- (void)unlike:(NSNumber *)iGuideid forObject:(id)object withSelector:(SEL)selector {
      
      NSString *url =	[NSString stringWithFormat:@"https://%@/api/2.0/user/favorites/guides/%@", [Config currentConfig].host, iGuideid];
      
      __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
      request.userAgentString = self.userAgent;
      
      if ([Config currentConfig].site == ConfigIFixitDev) {
            request.validatesSecureCertificate = NO;
      }
      
      [request setRequestMethod:@"DELETE"];
      [request addRequestHeader:@"X-App-Id" value:self.appId];
      [self addAuthorizationHeaderToRequest:request];
      
      [request setCompletionBlock:^{
            NSDictionary *results = @{@"statusCode" : @([request responseStatusCode])};
            [self checkSession:results];
            [object performSelector:selector withObject:results];
      }];
      [request setFailedBlock:^{
            NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"error", [[request error] localizedDescription], @"msg", nil];
            [object performSelector:selector withObject:results];
      }];
      
      [request startAsynchronous];
}

// Display an alert that allows the user to retry the connection
+ (void)displayConnectionErrorAlert {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                      message:NSLocalizedString(@"Unable to connect. Check your Internet connection and try again.", nil)
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                            otherButtonTitles:nil, nil];
      [alert show];
      [alert release];
}

// Display an alert that allows the user to retry the connection
+ (void)displayLoggedOutErrorAlert:(UIViewController*)vc {
      
      UIAlertController * alert=   [UIAlertController
                                    alertControllerWithTitle:@"Authorization"
                                    message:@"Your session has ended. Please authenticate to begin a new session."
                                    preferredStyle:UIAlertControllerStyleAlert];
      
      UIAlertAction* ok = [UIAlertAction
                           actionWithTitle:@"Login"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 // Code for OK button
                                 [[iFixitAPI sharedInstance] logout];
                                 if ([Config currentConfig].dozuki && [Config currentConfig].private) {
                                       [(iFixitAppDelegate*)[[UIApplication sharedApplication] delegate] showDozukiSplash];
                                       // On a custom private app
                                 } else if ([Config currentConfig].private) {
                                       [(iFixitAppDelegate*)[[UIApplication sharedApplication] delegate] showSiteSplash];
                                       // Everyone else who is public
                                 }
                                 
                           }];
      
      [alert addAction:ok];
      
      [vc presentViewController:alert animated:YES completion:nil];
      
}

+ (void)checkCredentialsForViewController:(id)viewController {
      id viewControllerToPresent;
      
      if ([iFixitAPI sharedInstance].user) {
            viewControllerToPresent = [[BookmarksViewController alloc] initWithNibName:@"BookmarksView" bundle:nil];
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                 CGRect bmframe = ((BookmarksViewController*)viewControllerToPresent).view.frame;
                 ListViewController* lvc = ((ListViewController*)viewController);
                 ((BookmarksViewController*)viewControllerToPresent).xframe = lvc.xframe;
            }
      } else {
            viewControllerToPresent = [[LoginViewController alloc] init];
            [viewControllerToPresent setDelegate:viewController];
      }
      
      // Create the animation ourselves to mimic a modal presentation
      // On iPad we must push the view onto a stack, instead of presenting
      // it modally or else undesired side effects occur
      if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            [viewController popViewControllerAnimated:NO];
            [UIView animateWithDuration:0.7
                             animations:^{
                                   [viewController pushViewController:viewControllerToPresent animated:NO];
                                   [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:[viewController view] cache:YES];
                             }];
      } else {
            // Wrap this in a navigation controller to avoid side effects from new status bar in iOS7
            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:viewControllerToPresent];
            [viewController presentModalViewController:nvc animated:YES];
            [nvc release];
      }
      
      [viewControllerToPresent release];
}

// Build our own custom user agent and set it
- (void)createAndSetUserAgent {
      NSBundle *bundle = [NSBundle bundleForClass:[self class]];
      NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
      NSString *marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
      NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
      
      UIDevice *device = [UIDevice currentDevice];
      NSString *deviceName = [device model];
      NSString *OSName = [device systemName];
      NSString *OSVersion = [device systemVersion];
      NSString *locale = [[NSLocale currentLocale] localeIdentifier];
      
      // iFixitiOS/1.4 (43) | iPad; Mac OS X 10.5.7; en_GB
      self.userAgent = [NSString stringWithFormat:@"%@iOS/%@ (%@) | %@; %@ %@; %@", appName, developmentVersionNumber, marketingVersionNumber, deviceName, OSName, OSVersion, locale];
}

@end
