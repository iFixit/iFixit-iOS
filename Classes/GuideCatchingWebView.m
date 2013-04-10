//
//  GuideCatchingWebView.m
//  iFixit
//
//  Created by David Patierno on 4/21/11.
//  Copyright 2011 iFixit. All rights reserved.
//

#import "GuideCatchingWebView.h"
#import "iFixitAppDelegate.h"
#import "Config.h"
#import "RegexKitLite.h"
#import "SVWebViewController.h"
#import "GuideViewController.h"

@implementation GuideCatchingWebView

@synthesize externalDelegate, externalURL, formatter, modalDelegate, linksOpenInSameWindow;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.delegate = self;
        self.formatter = [[[NSNumberFormatter alloc] init] autorelease];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.delegate = self;
        self.formatter = [[[NSNumberFormatter alloc] init] autorelease];
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

- (NSInteger)parseGuideURL:(NSString *)url {
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
    
    NSString *regexString = [NSString stringWithFormat:@"https?://%@/(Guide|Teardown|Project)/(.*?)/([0-9]+)/([0-9]+)", [Config currentConfig].host];
    NSString *guideidString = [url stringByMatching:regexString capture:3];
    NSNumber *guideid = guideidString ? [formatter numberFromString:guideidString] : [NSNumber numberWithInt:-1];

    return [guideid intValue];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	// Open guides with the native viewer.
	NSInteger guideid = [self parseGuideURL:[[request URL] absoluteString]];
    
    iFixitAppDelegate *delegate = (iFixitAppDelegate*)[[UIApplication sharedApplication] delegate];
    
	if (guideid != -1) {
        GuideViewController *vc = [[GuideViewController alloc] initWithGuideid:guideid];
        if (!modalDelegate)
            [delegate.window.rootViewController presentModalViewController:vc animated:YES];
        else
            [modalDelegate presentModalViewController:vc animated:YES];            
        [vc release];
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
            SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:[[request URL] absoluteString]];
            if (!modalDelegate)
                [delegate.window.rootViewController presentModalViewController:webViewController animated:YES];   
            else
                [modalDelegate presentModalViewController:webViewController animated:YES];    
            [webViewController release];
            return NO;
        }
    }
    
	return shouldStart;
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
    self.scrollView.scrollEnabled = (self.scrollView.contentSize.height > self.frame.size.height);
}

- (void)dealloc {
    [formatter release];
    [externalURL release];
    
    [super dealloc];
}
@end
