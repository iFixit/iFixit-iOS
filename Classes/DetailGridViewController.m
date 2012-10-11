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

@synthesize device = _device, guides = _guides, loading, orientationOverride, noGuides, gridDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [_device release];
    [_guides release];
    [loading release];
    [noGuides release];
    
    [super dealloc];
}

- (void)showLoading {
    noGuides.hidden = YES;
    if (loading.superview) {
        [loading showInView:self.view];
        return;
    }
    
    CGRect frame = CGRectMake(self.view.frame.size.width / 2.0 - 60, 260.0, 120.0, 120.0);
    self.loading = [[[WBProgressHUD alloc] initWithFrame:frame] autorelease];
    self.loading.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [loading showInView:self.view];
}

- (void)loadDevice {
    [self showLoading];
    [[iFixitAPI sharedInstance] getDevice:_device forObject:self withSelector:@selector(gotDevice:)];
}

- (void)gotDevice:(NSDictionary *)data {
    self.guides = [data arrayForKey:@"guides"];
    noGuides.hidden = YES;

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
        noGuides.hidden = NO;
        return;
    }

    [gridDelegate detailGrid:self gotGuideCount:[self.guides count]];

    [self.tableView reloadData];
    [self.loading hide];
}

- (void)setDevice:(NSString *)device {
    [_device release];
    _device = [device copy];
    
    self.guides = nil;
    [self.tableView reloadData];
    
    if (device)
        [self loadDevice];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!buttonIndex) 
        return;
    
    [self loadDevice];
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add a 10px bottom margin.
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0);
        
    self.view.backgroundColor = [UIColor clearColor];
    
    // Add the "No guides available" text label.
    self.noGuides = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noGuides.png"]] autorelease];
    noGuides.frame = CGRectMake((self.view.frame.size.width - 452.0) / 2.0, 120.0, 452.0, 40.0);
    noGuides.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    noGuides.hidden = YES;
    [self.view addSubview:noGuides];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    self.noGuides = nil;
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
        return @"Loading...";

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
