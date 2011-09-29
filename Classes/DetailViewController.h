//
//  DetailViewController.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import "GuideViewController.h"
@class GuideCatchingWebView;
@class WBProgressHUD;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UIWebViewDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet GuideCatchingWebView *webView;
@property (nonatomic, retain) WBProgressHUD *loading;
@property (nonatomic, retain) NSURL *lastURL;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *fwdButton;
@property (nonatomic, retain) UIPopoverController *popoverController;

- (IBAction)showSplash:(UIBarButtonItem *)button;

@end
