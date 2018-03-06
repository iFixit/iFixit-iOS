//
//  SSOViewController.m
//  iFixit
//
//  Created by David Patierno on 2/12/12.
//  Copyright (c) 2012 iFixit. All rights reserved.
//

#import "SSOViewController.h"
#import "Config.h"
#import "iFixitAPI.h"

@implementation SSOViewController

@synthesize delegate;

+ (id)viewControllerForURL:(NSString *)url delegate:(id<LoginViewControllerDelegate>)delegate {
    // First clear all cookies.
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
//     BFLog(@"sso %@", url);

    // Set a custom cookie for simple success SSO redirect: sso-origin=SHOW_SUCCESS
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:
                            [NSDictionary dictionaryWithObjectsAndKeys:@"sso-origin", NSHTTPCookieName,
                                                                       @"SHOW_SUCCESS", NSHTTPCookieValue,
                                                                       [Config host], NSHTTPCookieDomain,
                                                                       @"/", NSHTTPCookiePath,
                                                                       nil]];
    [storage setCookie:cookie];

    SSOViewController* vc = [[SSOViewController alloc] initWithAddress:url];
    vc.delegate = delegate;
    return [vc autorelease];
}

- (void)viewWillAppear:(BOOL)animated {
    // Ensure we have a solid navigation bar
    self.navigationController.navigationBar.translucent = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];

    NSString *host = [webView.request.URL host];
     NSLog(@"sso finished loading %@", host);

     if ([host isEqual:[Config currentConfig].host] || [host isEqual:[Config currentConfig].custom_domain]) {
        // Extract the sessionid.
        NSString *sessionid = nil;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [storage cookies]) {
            if ([cookie.name isEqual:@"session"]) {
                sessionid = cookie.value;
                break;
            }
        }

//     BFLog(@"sso session %@", sessionid);
       // Validate and obtain user data.
        [[iFixitAPI sharedInstance] loginWithSessionId:sessionid forObject:self withSelector:@selector(loginResults:)];
     } else {
          
          NSLog(@"hosts are not equal host %@ customdomain %@", [Config currentConfig].host, [Config currentConfig].custom_domain);

          
     }
}

- (void)loginResults:(NSDictionary *)results {
    if (!results) {
        [iFixitAPI displayConnectionErrorAlert];
        return;
    }
//     BFLog(@"results %@", results);
    
    if ([results objectForKey:@"error"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:[results objectForKey:@"msg"]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Okay", nil), nil];
        [alert show];
        [alert release];
    } else {
        [self dismissViewControllerAnimated:NO completion:^(void) {
            // The delegate is responsible for removing the login view.
            [delegate refresh];
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissModalViewControllerAnimated:YES];
}

@end
