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
#import "Config.h"
#import "UIImageView+WebCache.h"

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
    [[iFixitAPI sharedInstance] getCategory:_category forObject:self withSelector:@selector(gotCategory:)];
}

- (void)configureSiteLogoFromURL:(NSString *)url {
    // Set up the site logo frame
    [self configureSiteLogo];
    
    [self.siteLogo setImageWithURL:[NSURL URLWithString:url]];
    [self.backgroundView addSubview:self.siteLogo];
}

- (void)configureSiteLogo {
    UIImageView *siteLogoImageView = [[UIImageView alloc] init];
    siteLogoImageView.frame = CGRectMake(0, 0, 400, 300);
    siteLogoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [siteLogoImageView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    
    self.siteLogo = siteLogoImageView;
    [siteLogoImageView release];
}

- (void)gotCategory:(NSDictionary *)data {
    self.guides = [data arrayForKey:@"guides"];

    if (!_guides) {
        [self.loading hide];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not load guide list.", nil)
                                                        message:NSLocalizedString(@"Please check your internet connection and try again.", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"Retry", nil), nil];
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
    
    self.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"concreteBackground.png"]] autorelease];
    
    if (![Config currentConfig].dozuki) {
        [self configureSiteLogo];
    }
    
    switch ([Config currentConfig].site) {
        case ConfigIFixit:
            self.fistImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailViewFist.png"]] autorelease];
            self.fistImage.frame = CGRectMake(0, 0, 703, 660);
            [self.backgroundView addSubview:self.fistImage];
            break;
        /*EAOiPadSiteLogo*/
    }
    
    self.guideArrow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailViewArrowDark.png"]] autorelease];
    self.guideArrow.frame = CGRectMake(45, 6, self.guideArrow.frame.size.width, self.guideArrow.frame.size.height);
    
    [self.backgroundView addSubview:self.guideArrow];
    
    [self configureInstructionsLabel];
    
    // Add a 10px bottom margin.
    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0);
    self.tableView.backgroundView = self.backgroundView;
    
    self.noGuidesImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noGuides.png"]] autorelease];
    self.noGuidesImage.frame = CGRectMake(135, 30, self.noGuidesImage.frame.size.width, self.noGuidesImage.frame.size.height);
    [self.view addSubview:self.noGuidesImage];
    
    [self showNoGuidesImage:NO];
    
    [self willRotateToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] duration:0];
}

- (void)configureDozukiTitleLabel {
    UILabel *l = [[UILabel alloc] init];
    l.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    l.textAlignment = UITextAlignmentCenter;
    l.backgroundColor = [UIColor clearColor];
    l.font = [UIFont fontWithName:@"Helvetica-Bold" size:60.0];
    l.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    l.shadowColor = [UIColor darkGrayColor];
    l.shadowOffset = CGSizeMake(0.0, 1.0);
    l.numberOfLines = 1;
    l.text = [Config currentConfig].siteData[@"title"];
    l.frame = CGRectMake(0, 0, [l.text sizeWithFont:l.font].width, [l.text sizeWithFont:l.font].height);
    l.adjustsFontSizeToFitWidth = YES;
    [l setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [l sizeToFit];
    
    self.dozukiTitleLabel = l;
    self.dozukiTitleLabel.alpha = 0;
    [self.backgroundView addSubview:self.dozukiTitleLabel];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        self.dozukiTitleLabel.alpha = 1;
    }];
}
- (void)configureInstructionsLabel {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(135, 190, 280, 30)];
    l.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    l.textAlignment = UITextAlignmentCenter;
    l.lineBreakMode = UILineBreakModeWordWrap;
    l.backgroundColor = [UIColor clearColor];
    l.font = [UIFont fontWithName:@"OpenSans-Bold" size:17.0];
    l.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    l.shadowColor = [UIColor darkGrayColor];
    l.shadowOffset = CGSizeMake(0.0, 1.0);
    l.numberOfLines = 0;
    l.text = [Config currentConfig].dozuki ?
                NSLocalizedString(@"Looking for Guides? Browse them here.", nil) :
                NSLocalizedString(@"Looking for Guides? Browse thousands of them here.", nil);
    [l sizeToFit];
    
    self.browseInstructions = l;
    [self.backgroundView addSubview:self.browseInstructions];
}


- (void)repositionTitleObject:(id)object forOrientation:(UIInterfaceOrientation)orientation {
    CGPoint center;
    
    if ([object isKindOfClass:[UILabel class]]) {
        center = UIDeviceOrientationIsLandscape(orientation) ? CGPointMake(361.5f, 325) : CGPointMake(374, 480);
        [object sizeToFit];
    } else {
        center = UIDeviceOrientationIsLandscape(orientation) ? CGPointMake(355.5f, 325) : CGPointMake(384, 480);
    }
    
    [object setCenter:center];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (self.siteLogo)
        [self repositionTitleObject:self.siteLogo forOrientation:toInterfaceOrientation];
    if (self.dozukiTitleLabel)
        [self repositionTitleObject:self.dozukiTitleLabel forOrientation:toInterfaceOrientation];
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
    
    id image = _guides[index][@"image"];
    
    return image == [NSNull null] ? NULL : image[@"medium"];
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
