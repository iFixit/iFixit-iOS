//
//  DetailViewController.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import "GuideViewController.h"
#import "DetailGridViewControllerDelegate.h"

@class GuideCatchingWebView;
@class WBProgressHUD;
@class DetailIntroViewController;
@class DetailGridViewController;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UIWebViewDelegate, UIAlertViewDelegate, DetailGridViewControllerDelegate>

@property (nonatomic, retain) UIBarButtonItem *browseButton;
@property (nonatomic, retain) UIPopoverController *popoverController;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet GuideCatchingWebView *webView;
@property (nonatomic, retain) NSURL *lastURL;

@property (nonatomic, retain) DetailGridViewController *gridViewController;
@property (nonatomic, retain) NSMutableArray *deviceToolbarItems;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) DetailIntroViewController *introViewController;

- (void)setDevice:(NSString *)device;
- (void)reset;

@end
