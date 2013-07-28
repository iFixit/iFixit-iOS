//
//  OpenIDViewController.m
//  iFixit
//
//  Created by David Patierno on 2/4/12.
//  Copyright (c) 2012 iFixit. All rights reserved.
//

#import "OpenIDViewController.h"
#import "Config.h"
#import "iFixitAPI.h"

@implementation OpenIDViewController

@synthesize delegate;

+ (id)viewControllerForHost:(NSString *)host delegate:(id<LoginViewControllerDelegate>)delegate {
    // First clear all cookies.
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }

    NSString *url = [NSString stringWithFormat:@"%@/login/openid?host=%@", [Config currentConfig].baseURL, host];
    OpenIDViewController* vc = [[OpenIDViewController alloc] initWithAddress:url];
    vc.delegate = delegate;
    return [vc autorelease];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];

    NSString *body = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
    if ([body rangeOfString:@"loggedIn();"].location != NSNotFound) {
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
    if (!results) {
        [iFixitAPI displayConnectionErrorAlert];
        return;
    }
    
    
    if ([results objectForKey:@"error"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:[results objectForKey:@"msg"]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Okay", nil), nil];
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
