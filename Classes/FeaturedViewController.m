//
//  FeaturedViewController.m
//  iFixit
//
//  Created by David Patierno on 11/7/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

#import "FeaturedViewController.h"
#import "PastFeaturesViewController.h"
#import "DMPGridViewController.h"
#import "GuideViewController.h"
#import "iFixitAPI.h"
#import "Config.h"
#import "UIImageView+WebCache.h"
#import "WBProgressHUD.h"
#import "GANTracker.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeaturedViewController
@synthesize poc, pvc, gvc;
@synthesize collection = _collection;
@synthesize guides = _guides;
@synthesize loading;

- (void)showLoading {
    if (loading.superview) {
        [loading showInView:self.gvc.view];
        return;
    }
    
    CGRect frame = CGRectMake(self.view.frame.size.width / 2.0 - 60, 400.0, 120.0, 120.0);
    self.loading = [[[WBProgressHUD alloc] initWithFrame:frame] autorelease];
    self.loading.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [loading showInView:self.gvc.view];
}

- (void)loadCollections {
    [self showLoading];
    self.gvc.navigationItem.rightBarButtonItem = nil;
    [[iFixitAPI sharedInstance] getCollectionsWithLimit:200 andOffset:0 forObject:self withSelector:@selector(gotCollections:)];
}

- (id)init {
    if ((self = [super init])) {
        self.pvc = [[[PastFeaturesViewController alloc] init] autorelease];
        self.pvc.delegate = self;

        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:pvc];
        self.poc = [[[UIPopoverController alloc] initWithContentViewController:nvc] autorelease];
        poc.popoverContentSize = CGSizeMake(320.0, 500.0);
        [nvc release];
        
        self.gvc = [[[DMPGridViewController alloc] initWithDelegate:nil] autorelease];
        self.viewControllers = [NSArray arrayWithObject:gvc];
        self.gvc.delegate = self;
        
        [self loadCollections];
    }
    return self;
}

- (void)gotCollections:(NSArray *)collections {
    if (![collections count]) {
        [self.loading hide];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:NSLocalizedString(@"Could not load featured collections.", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"Retry", nil), nil];
        alert.tag = 1;
        [alert show];
        [alert release];
        return;
    }
    
    // Grab the most recent collection to populate our display.
    self.collection = collections[0];
    
    // Pass the whole list onto the popover view.
    pvc.collections = [NSMutableArray arrayWithArray:collections];
    
    // Analytics
    [[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/collection/%d", [[self.collection valueForKey:@"collectionid"] intValue]] withError:NULL];
}

// Run this method both when we set the collection and on viewDidLoad, in case we're coming back from a low memory condition.
- (void)updateTitleAndHeader {
    if (!_collection)
        return;
    
    self.gvc.title = [_collection valueForKey:@"title"];
    
    // Create the header container view with a drop shadow.
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 256.0)];
    headerView.layer.masksToBounds = NO;
    headerView.layer.shadowOffset = CGSizeZero;
    headerView.layer.shadowRadius = 6.0;
    headerView.layer.shadowOpacity = 1;
    headerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:headerView.bounds].CGPath;
    
    // Add the image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:headerView.frame];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.backgroundColor = [UIColor lightGrayColor];
    [imageView setImageWithURL:[NSURL URLWithString:[[_collection objectForKey:@"image"] objectForKey:@"large"]]];
    [headerView addSubview:imageView];
    [imageView release];

    // Add a gradient overlay.
    UIImageView *gradientView = [[UIImageView alloc] initWithFrame:headerView.frame];
    gradientView.alpha = 0.80;
    gradientView.image = [UIImage imageNamed:@"collectionsHeaderGradient.png"];
    gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    gradientView.contentMode = UIViewContentModeScaleToFill;
    gradientView.clipsToBounds = YES;
    [headerView addSubview:gradientView];
    [gradientView release];
    
    // Add the giant text.
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumFontSize = 50.0;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if ([Config currentConfig].site == ConfigIFixit || [Config currentConfig].site == ConfigMake) {
        titleLabel.font = [UIFont fontWithName:@"Helvetica" size:120.0];
        titleLabel.frame = CGRectMake(120.0, 150.0, self.view.frame.size.width - 110.0, 106.0);
        titleLabel.text = [[_collection valueForKey:@"title"] stringByAppendingString:@" "];
    }
    else {     
        titleLabel.font = [UIFont fontWithName:@"Helvetica" size:120.0];
        titleLabel.frame = CGRectMake(120.0, 150.0, self.view.frame.size.width - 130.0, 106.0);
        titleLabel.text = [_collection valueForKey:@"title"];
    }

    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentRight;
    [headerView addSubview:titleLabel];
    [titleLabel release];
    
    // Apply!
    self.gvc.tableView.tableHeaderView = headerView;
    [headerView release];
}

- (void)setCollection:(NSDictionary *)collection {
    // Save the collection.
    [_collection release];
    _collection = [collection retain];
    
    // Reset the guides list.
    self.guides = collection[@"guides"];
    
    // Dismiss the popover
    [poc dismissPopoverAnimated:YES];
    
    // Update the title and header image.
    [self updateTitleAndHeader];
    
    // Scroll to the top.
    [self.gvc.tableView scrollRectToVisible:CGRectMake(0.0, 0.0, 1.0, 1.0) animated:NO];
    
    // Populate the table
    [self.gvc.tableView reloadData];
    [self.loading hide];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!buttonIndex) {
        UIBarButtonItem *refreshItem = nil;

        if (alertView.tag == 1) {
            refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                        target:self
                                                                        action:@selector(loadCollections)];
        }
        else if (alertView.tag == 2) {
            refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                        target:self
                                                                        action:@selector(loadGuides)];            
        }
        
        self.gvc.navigationItem.rightBarButtonItem = refreshItem;
        [refreshItem release];
        return;
    }
    
    if (alertView.tag == 1) {
        [self loadCollections];
    }
    else if (alertView.tag == 2) {
        [self loadGuides];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Add a 10px bottom margin.
    self.gvc.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 10.0, 0.0);
    
    //self.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.navigationBar.tintColor = [Config currentConfig].toolbarColor;

    if ([[Config currentConfig].backgroundColor isEqual:[UIColor whiteColor]])
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"concreteBackgroundWhite.png"]];
    else
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"concreteBackground.png"]];
    
    self.gvc.view.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Past Features", nil)
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(showPastFeatures:)];
    self.gvc.navigationItem.leftBarButtonItem = button;
    [button release];
    
    [self updateTitleAndHeader];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
    self.gvc.delegate = nil;
    self.pvc.delegate = nil;
    
    [poc release];
    [gvc release];
    [pvc release];
    [_collection release];
    [_guides release];
    [loading release];
    
    [super dealloc];
}

- (void)showPastFeatures:(id)sender {
    if (poc.popoverVisible)
        [poc dismissPopoverAnimated:YES];
    else
        [poc presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (NSInteger)numberOfCellsForGridViewController:(DMPGridViewController *)gridViewController {
    return _guides.count;
}
- (NSString *)gridViewController:(DMPGridViewController *)gridViewController imageURLForCellAtIndex:(NSUInteger)index {
    if (![_guides count])
        return nil;
    return _guides[index][@"image"][@"medium"];
}
- (NSString *)gridViewController:(DMPGridViewController *)gridViewController titleForCellAtIndex:(NSUInteger)index {
    if (![_guides count])
        return NSLocalizedString(@"Loading...", nil);
    
    NSString *title = @"";
    NSDictionary *guide = [_guides objectAtIndex:index];
    if ([guide objectForKey:@"title"] != [NSNull null])
        title = [guide objectForKey:@"title"];
    else
        title = [NSString stringWithFormat:@"%@ %@", [guide valueForKey:@"category"], [[guide valueForKey:@"type"] capitalizedString]];
    
    title = [title stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    title = [title stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    title = [title stringByReplacingOccurrencesOfString:@"<wbr />" withString:@""];
    return title;
}
- (void)gridViewController:(DMPGridViewController *)gridViewController tappedCellAtIndex:(NSUInteger)index {
    NSInteger guideid = [_guides[index][@"guideid"] intValue] ;
    GuideViewController *vc = [[GuideViewController alloc] initWithGuideid:guideid];
    [self presentModalViewController:vc animated:YES];
    [vc release];
}

@end
