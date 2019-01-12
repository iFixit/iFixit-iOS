//
//  DozukiSplashViewController.m
//  iFixit
//
//  Created by David Patierno on 8/16/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

#import "DozukiSplashViewController.h"
#import "DozukiInfoViewController.h"
#import "DozukiSelectSiteViewController.h"
#import "iFixitAppDelegate.h"

@implementation DozukiSplashViewController

@synthesize introView, nextViewController;

- (id)init {
     self = [super initWithNibName:@"DozukiSplashView" bundle:nil];
     if (self) {
          // Custom initialization
          showingList = NO;
          
          // Create a navigation controller and load the info view.
          DozukiInfoViewController *divc = [[DozukiInfoViewController alloc] initWithNibName:@"DozukiInfoView" bundle:nil];
          UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:divc];
          nvc.delegate = self;
          [divc showList];
          
          nvc.modalPresentationStyle = UIModalPresentationFormSheet;
          nvc.modalTransitionStyle = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ?
          UIModalTransitionStyleFlipHorizontal : UIModalTransitionStyleCrossDissolve;
          self.nextViewController = nvc;
          [nvc release];
          [divc release];
          
     }
     return self;
}

#pragma mark - View lifecycle

- (void)configureLabels {
     self.dozukiSlogan.text = NSLocalizedString(@"All Your Procedures In One Place.", nil);
     self.dozukiDescription.text = NSLocalizedString(@"A modern documentation platform for everything from work instructions to product support.", nil);
     self.getStarted.text = NSLocalizedString(@"Get Started", nil);
     self.getStarted.backgroundColor = [UIColor colorWithRed:0.87 green:0.25 blue:0.14 alpha:1.0];
     self.getStarted.layer.masksToBounds = YES;
     self.getStarted.layer.cornerRadius = 8.0;
     self.dozukiSlogan.hidden = NO;
     self.dozukiDescription.hidden = YES;
     UIFont *fontgs = nil;
     UIFont *fontsl = nil;
     if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
          fontsl = [UIFont fontWithName:@"MuseoSans-500" size:17.0f];
          fontgs = [UIFont fontWithName:@"MuseoSans-500" size:17.0f];
     } else {
          fontsl = [UIFont fontWithName:@"MuseoSans-500" size:45.0f];
          fontgs = [UIFont fontWithName:@"MuseoSans-500" size:31.0f];

     }
     self.getStarted.font = fontgs;
     self.dozukiSlogan.font = fontsl;
}

- (void)viewDidLoad {
     [super viewDidLoad];
     
     [self configureLabels];
     
     if (showingList)
          self.introView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
     for (UIView *view in self.introView.subviews)
          view.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated {
     [UIView animateWithDuration:0.5 animations:^{
          for (UIView *view in self.introView.subviews)
               view.alpha = 1.0;
     }];
}

- (void)viewDidUnload
{
     [self setIntroView:nil];
     [self setDozukiSlogan:nil];
     [self setDozukiDescription:nil];
     [self setGetStarted:nil];
     [super viewDidUnload];
     // Release any retained subviews of the main view.
     // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
          return YES;
     return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)getStarted:(id)sender {
     CGRect originalFrame = self.introView.frame;
     
     [UIView animateWithDuration:0.3 animations:^{
          CGRect frame = originalFrame;
          frame.origin.x = -frame.size.width;
          self.introView.frame = frame;
     } completion:^(BOOL finished) {
          self.introView.hidden = YES;
          self.introView.frame = originalFrame;
          showingList = YES;
     }];
     
     if ([nextViewController.viewControllers count] == 1) {
          nextViewController.viewControllers = [NSArray arrayWithObject:[nextViewController.viewControllers objectAtIndex:0]];
          [(DozukiInfoViewController *)nextViewController.topViewController showList];
     }
     
     [self presentModalViewController:self.nextViewController animated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
     
     if ([viewController class] == [DozukiSelectSiteViewController class])
          return;
     
     [self dismissModalViewControllerAnimated:YES];
     
     CGRect originalFrame = self.introView.frame;
     CGRect frame = originalFrame;
     frame.origin.x = -originalFrame.size.width;
     self.introView.frame = frame;
     self.introView.hidden = NO;
     
     NSTimeInterval delay = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 0.3 : 0.0;
     [UIView animateWithDuration:0.3 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
          self.introView.frame = originalFrame;
     } completion:^(BOOL finished) {
          showingList = NO;
     }];
     
}

- (void)dealloc {
     [introView release];
     [nextViewController release];
     [_dozukiSlogan release];
     [_dozukiDescription release];
     [_getStarted release];
     [super dealloc];
}
@end
