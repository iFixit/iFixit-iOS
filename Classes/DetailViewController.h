//
//  DetailViewController.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideViewController.h"

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UIWebViewDelegate> {
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    
    UIWebView *webView;
	UIBarButtonItem *backButton;
	UIBarButtonItem *fwdButton;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *fwdButton;
@property (nonatomic, retain) UIPopoverController *popoverController;

- (NSInteger)parseGuideURL:(NSString *)url;
- (IBAction)showSplash:(UIBarButtonItem *)button;

@end
