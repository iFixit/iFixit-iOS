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

    SSOViewController* vc = [[SSOViewController alloc] initWithAddress:url];
    vc.delegate = delegate;
    return [vc autorelease];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];

    if ([[webView.request.URL host] isEqual:[Config currentConfig].host]) {
        // Extract the sessionid.
        NSString *sessionid = nil;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [storage cookies]) {
            if ([cookie.name isEqual:@"session"]) {
                sessionid = cookie.value;
                break;
            }
        }
        // Validate and obtain user data.
        [[iFixitAPI sharedInstance] loginWithSessionId:sessionid forObject:self withSelector:@selector(loginResults:)];
    }
}

- (void)loginResults:(NSDictionary *)results {    
    if ([results objectForKey:@"error"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:[results objectForKey:@"msg"]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Okay", nil];
        [alert show];
        [alert release];
    }
    else {
        [self dismissModalViewControllerAnimated:YES];
        // The delegate is responsible for removing the login view.
        [delegate refresh];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissModalViewControllerAnimated:YES];
}

@end
