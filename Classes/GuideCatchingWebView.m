//
//  GuideCatchingWebView.m
//  iFixit
//
//  Created by David Patierno on 4/21/11.
//  Copyright 2011 iFixit. All rights reserved.
//

#import "GuideCatchingWebView.h"
#import "iFixit-Swift.h"
#import "Config.h"
#import "SVWebViewController.h"

@implementation GuideCatchingWebView

@synthesize externalDelegate, externalURL, formatter, modalDelegate, linksOpenInSameWindow;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.delegate = self;
        self.formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.delegate = self;
        self.formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    return self;
}

- (void)setDelegate:(id<UIWebViewDelegate>)newDelegate {
    if (newDelegate == self) {
        super.delegate = self;
    }
    else {
        self.externalDelegate = newDelegate;
    }
}

- (NSNumber *)parseGuideURL:(NSString *)url {
	/*
	 (
	 "http:",
	 "",
	 "www.ifixit.com",
	 Guide,
	 "Installing-iPhone-4-Speaker-Enclosure",
	 3149,
	 1
	 )
	 */
    
    NSString *guideidString = nil;
    NSError *error;
    NSString *regexString = [NSString stringWithFormat:@"https?://%@/(Guide|Teardown|Project)/(.*?)/([0-9]+)/([0-9]+)", [Config currentConfig].host];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:url options:NSMatchingProgress range:NSMakeRange(0, url.length)];
    if (matches.count == 3) {
        NSTextCheckingResult *match = matches[2];
        guideidString = [url substringWithRange:match.range];
    }
    NSNumber *iGuideid = guideidString ? [formatter numberFromString:guideidString] : @(-1);

    return iGuideid;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	// Open guides with the native viewer.
	NSNumber *iGuideid = [self parseGuideURL:[[request URL] absoluteString]];
    
    iFixitAppDelegate *delegate = (iFixitAppDelegate*)[[UIApplication sharedApplication] delegate];
    
	if (![iGuideid isEqualToNumber:@(-1)]) {
        GuideViewController *vc = [[GuideViewController alloc] initWithGuideid:iGuideid];
        if (!modalDelegate)
            [delegate.window.rootViewController presentViewController:vc animated:YES completion:nil];
        else
            [modalDelegate presentViewController:vc animated:YES completion:nil];
		return NO;
	}
    
    BOOL shouldStart = YES;
    if ([externalDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
        shouldStart = [externalDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    
    if (shouldStart) {
        if (linksOpenInSameWindow)
            return YES;
        
        // Open all other URLs with modal view.
        if (navigationType == UIWebViewNavigationTypeLinkClicked) {
            id viewControllerToPresent = [self createWebViewControllerFromRequest:request];
            
            if (!modalDelegate)
                [delegate.window.rootViewController presentViewController:viewControllerToPresent animated:YES completion:nil];
            else
                [modalDelegate presentViewController:viewControllerToPresent animated:YES completion:nil];
            
            return NO;
        }
    }
    
	return shouldStart;
}

- (id)createWebViewControllerFromRequest:(NSURLRequest *)request {
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:[[request URL] absoluteString]];

    webViewController.showsDoneButton = YES;
    // Wrap our custom webview controller in a navigation controller on iPhone
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
        
        return navigationController;
    }
    
    return webViewController;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex)
		[[UIApplication sharedApplication] openURL:externalURL];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([externalDelegate respondsToSelector:@selector(webViewDidFinishLoad:)])
        [externalDelegate webViewDidFinishLoad:webView];
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    if ([externalDelegate respondsToSelector:@selector(webViewDidStartLoad:)])
        [externalDelegate webViewDidStartLoad:webView];
}

- (void)enableScrollingIfNeeded {
    if ([self respondsToSelector:@selector(scrollView)]){
        self.scrollView.scrollEnabled = (self.scrollView.contentSize.height > self.frame.size.height);
    }
}

@end
