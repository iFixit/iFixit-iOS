//
//  iPhoneDeviceViewController.m
//  iFixit
//
//  Created by David Patierno on 9/15/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

#import "iFixit-Swift.h"
#import "iPhoneDeviceViewController.h"
#import "GuideCell.h"
#import "UIImageView+WebCache.h"
#import "GuideViewController.h"
#import "Config.h"
#import "ListViewController.h"
#import "GuideLib.h"

@implementation iPhoneDeviceViewController

@synthesize topic=_topic;
@synthesize guides=_guides;

- (id)initWithTopic:(NSString *)topic {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.topic = topic;
        self.guides = [NSArray array];
        
        if (!topic)
            self.title = NSLocalizedString(@"Guides", nil);
        
        [self getGuides];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    if (self.currentCategory)
        self.navigationItem.title = self.currentCategory;
}

- (void)showRefreshButton {
    // Show a refresh button in the navBar.
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(getGuides)];
    self.navigationItem.rightBarButtonItem = refreshButton;
}

- (void)showLoading {
    loading = YES;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 20.0f)];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
    spinner.activityIndicatorViewStyle = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ?
    UIActivityIndicatorViewStyleGray : UIActivityIndicatorViewStyleWhite;
    [container addSubview:spinner];
    [spinner startAnimating];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:container];
    self.navigationItem.rightBarButtonItem = button;
}
- (void)hideLoading {
    loading = NO;
    self.navigationItem.rightBarButtonItem = nil;
    [self.listViewController showFavoritesButton:self];
}

- (void)getGuides {
    if (!loading) {
        loading = YES;
        [self showLoading];
        
        if (self.topic) {
//            [[iFixitAPI sharedInstance] getCategory:self.topic forObject:self withSelector:@selector(gotCategory:)];
            [[iFixitAPI sharedInstance] getCategory:self.topic handler:^(NSDictionary<NSString *,id> * _Nullable result) {
                [self gotCategory:result];
            }];
        } else {
//            [[iFixitAPI sharedInstance] getGuides:nil forObject:self withSelector:@selector(gotGuides:)];
            [[iFixitAPI sharedInstance] getGuides:nil handler:^(NSArray<NSDictionary<NSString *,id> *> * _Nullable results) {
                [self gotGuides:results];
            }];
        }
    }
}

- (void)gotGuides:(NSArray *)guides {
    
    if (!guides) {
        [iFixitAPI displayConnectionErrorAlert];
        [self showRefreshButton];
    }
    
    self.guides = guides;
    [self.tableView reloadData];
    [self hideLoading];
}
- (void)gotCategory:(NSDictionary *)data {
    if (!data) {
        [iFixitAPI displayConnectionErrorAlert];
        [self showRefreshButton];
        return;
    }
    
    
    self.guides = [data objectForKey:@"guides"];    // Check if NSNull
    [self.tableView reloadData];
    [self hideLoading];
    
    if (!self.guides)
        [self showRefreshButton];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Grab reference to listViewController
    self.listViewController = (ListViewController*)self.navigationController;
    
    // Make room for the toolbar
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];

    if (loading)
        [self showLoading];
    
    // Show the Dozuki sites select button if needed.
    if ([Config currentConfig].dozuki && !self.topic) {
        UIImage *icon = [UIImage imageNamed:@"backtosites.png"];
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:icon style:UIBarButtonItemStyleBordered
                                                                  target:[[UIApplication sharedApplication] delegate]
                                                                  action:@selector(showDozukiSplash)];
        self.navigationItem.leftBarButtonItem = button;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    // Make room for the toolbar
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 44, 0);
    }
    else {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 32, 0);
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.guides count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GuideCell";
    
    GuideCell *cell = (GuideCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GuideCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSString *title = [self.guides[indexPath.row][@"title"] isEqual:@""] ? NSLocalizedString(@"Untitled", nil) : self.guides[indexPath.row][@"title"];
    

    title = [title stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    title = [title stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    title = [title stringByReplacingOccurrencesOfString:@"<wbr />" withString:@""];
    
    cell.textLabel.text = title;
    
    NSDictionary *imageData = self.guides[indexPath.row][@"image"];
    NSString *thumbnailURL = [imageData isEqual:[NSNull null]] ? nil : imageData[@"thumbnail"];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:thumbnailURL] placeholderImage:[UIImage imageNamed:@"WaitImage.png"]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [GuideLib loadAndPresentGuideForGuideid:self.guides[indexPath.row][@"guideid"]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
