//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//

#import <MessageUI/MessageUI.h>
@class GuideCatchingWebView;

@interface SVWebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	GuideCatchingWebView *rWebView;
    UINavigationBar *navBar;
    UIToolbar *toolbar;
    
	// iPhone UI
	UINavigationItem *navItem;
	UIBarButtonItem *backBarButton, *forwardBarButton, *refreshStopBarButton, *actionBarButton;
	
	// iPad UI
	UIButton *backButton, *forwardButton, *refreshStopButton, *actionButton;
	UILabel *titleLabel;
	CGFloat titleLeftOffset;
	
	BOOL deviceIsTablet, stoppedLoading;
}

@property (nonatomic, retain) GuideCatchingWebView *webView;
@property (nonatomic, retain) NSString *urlString;

@property (nonatomic) BOOL showsDoneButton;
@property (nonatomic, retain) UIColor *tintColor;
@property BOOL isFirstLoad;

- (id)initWithAddress:(NSString*)string;
- (id)initWithAddress:(NSString *)string withTitle:(NSString*)title;
- (void)refreshWebView;
    
@end
