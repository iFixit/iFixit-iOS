//
//  DetailGridViewController.m
//  iFixit
//
//  Created by David Patierno on 11/15/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

#import "DetailGridViewController.h"
#import "iFixitAPI.h"
#import "WBProgressHUD.h"
#import "DictionaryHelper.h"
#import "GuideViewController.h"
#import "DMPGridViewCell.h"
#import "iFixitAppDelegate.h"

@implementation DetailGridViewController

@synthesize category = _category, guides = _guides, loading, orientationOverride, gridDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [_category release];
    [_guides release];
    [loading release];
    
    [super dealloc];
}

- (void)showLoading {
    if (loading.superview) {
        [loading showInView:self.view];
        return;
    }
    
    CGRect frame = CGRectMake(self.view.frame.size.width / 2.0 - 60, 260.0, 120.0, 120.0);
    self.loading = [[[WBProgressHUD alloc] initWithFrame:frame] autorelease];
    self.loading.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [loading showInView:self.view];
}

- (void)loadCategory {
    [self showLoading];
    [[iFixitAPI sharedInstance] getTopic:_category forObject:self withSelector:@selector(gotCategory:)];
}

- (void)gotCategory:(NSDictionary *)data {
    self.guides = [data arrayForKey:@"guides"];

    if (!_guides) {
        [self.loading hide];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not load guide list."
                                                        message:@"Please check your internet and try again."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Retry", nil];
        [alert show];
        [alert release];
        return;
    }
    else if (![_guides count]) {
        [gridDelegate detailGrid:self gotGuideCount:0];

        [self.loading hide];
        return;
    }

    [gridDelegate detailGrid:self gotGuideCount:[self.guides count]];

    [UIView transitionWithView:self.tableView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.tableView reloadData];
                        [self.loading hide];
                    }
                    completion:nil
     ];
}

- (void)setCategory:(NSString *)category{
    [_category release];
    _category = [category copy];
    
    self.guides = nil;
    [self.tableView reloadData];
    
    if (category)
        [self loadCategory];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!buttonIndex) 
        return;
    
    [self loadCategory];
}

- (void)showNoGuidesImage:(BOOL)option {
    self.noGuidesImage.hidden = !option;
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *concreteBackground = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"concreteBackground.png"]] autorelease];
    
    self.fistImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailViewFist.png"]] autorelease];
    self.fistImage.frame = CGRectMake(0, 0, 703, 660);
    [concreteBackground addSubview:self.fistImage];
    
    // Add a 10px bottom margin.
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0);
    self.tableView.backgroundView = concreteBackground;
    
    self.noGuidesImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noGuides.png"]] autorelease];
    self.noGuidesImage.frame = CGRectMake(135, 30, self.noGuidesImage.frame.size.width, self.noGuidesImage.frame.size.height);
    [self.view addSubview:self.noGuidesImage];
    
    [self showNoGuidesImage:NO];
}


- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (DMPGridViewCellStyle)styleForRow:(NSUInteger)row {
    return UIInterfaceOrientationIsPortrait(orientationOverride) ?
        DMPGridViewCellStylePortraitColumns : DMPGridViewCellStyleLandscapeColumns;        
}

- (NSInteger)numberOfCellsForGridViewController:(DMPGridViewController *)gridViewController {
    return [_guides count];
}
- (NSString *)gridViewController:(DMPGridViewController *)gridViewController imageURLForCellAtIndex:(NSUInteger)index {
    if (![_guides count])
        return nil;

    return [[[_guides objectAtIndex:index] valueForKey:@"image_url"] stringByAppendingString:@".medium"];
}
- (NSString *)gridViewController:(DMPGridViewController *)gridViewController titleForCellAtIndex:(NSUInteger)index {
    if (![_guides count])
        return NSLocalizedString(@"Loading...", nil);

    NSDictionary *guide = [_guides objectAtIndex:index];
    NSString *title = [guide valueForKey:@"subject"];
    
    title = [title stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    title = [title stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    title = [title stringByReplacingOccurrencesOfString:@"<wbr />" withString:@""];
    return title;
}
- (void)gridViewController:(DMPGridViewController *)gridViewController tappedCellAtIndex:(NSUInteger)index {
    iFixitAppDelegate *delegate = (iFixitAppDelegate*)[[UIApplication sharedApplication] delegate];

    NSInteger guideid = [[[_guides objectAtIndex:index] valueForKey:@"guideid"] intValue];
    GuideViewController *vc = [[GuideViewController alloc] initWithGuideid:guideid];
    [delegate.window.rootViewController presentModalViewController:vc animated:YES];
    [vc release];
}

@end
