//
//  iPhoneDeviceViewController.m
//  iFixit
//
//  Created by David Patierno on 9/15/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

#import "iPhoneDeviceViewController.h"
#import "iFixitAPI.h"
#import "DictionaryHelper.h"
#import "GuideCell.h"
#import "UIImageView+WebCache.h"
#import "iFixitAppDelegate.h"
#import "GuideViewController.h"
#import "Config.h"
#import "ListViewController.h"

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
    [refreshButton release];   
}

- (void)showLoading {
    loading = YES;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 20.0f)];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
    spinner.activityIndicatorViewStyle = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ?
    UIActivityIndicatorViewStyleGray : UIActivityIndicatorViewStyleWhite;
    [container addSubview:spinner];
    [spinner startAnimating];
    [spinner release];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:container];
    self.navigationItem.rightBarButtonItem = button;
    [container release];
    [button release];
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
        
        if (self.topic)
            [[iFixitAPI sharedInstance] getCategory:self.topic forObject:self withSelector:@selector(gotCategory:)];
        else
            [[iFixitAPI sharedInstance] getGuides:nil forObject:self withSelector:@selector(gotGuides:)];
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
    
    
    self.guides = [data arrayForKey:@"guides"];
    [self.tableView reloadData];
    [self hideLoading];
    
    if (!self.guides)
        [self showRefreshButton];
    else if (![self.guides count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No guides found", nil)
                                                        message:NSLocalizedString(@"This device has no guides.", nil)
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Okay", nil), nil];
        [alert show];
        [alert release];
    }
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
        [button release];
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
        cell = [[[GuideCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSString *subject = [[self.guides objectAtIndex:indexPath.row] valueForKey:@"subject"];
    

    if (!subject || [subject isEqual:[NSNull null]] || [subject isEqual:@""]) {
        subject = NSLocalizedString(@"Untitled", nil);
    }
    else {
        subject = [subject stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        subject = [subject stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        subject = [subject stringByReplacingOccurrencesOfString:@"<wbr />" withString:@""];
    }
    
    cell.textLabel.text = subject;
    
    id image = self.guides[indexPath.row][@"image"];
    NSString *thumbnailURL = [[self.guides objectAtIndex:indexPath.row] valueForKey:@"thumbnail"];
    thumbnailURL = image == [NSNull null] ? NULL : image[@"thumbnail"];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:thumbnailURL] placeholderImage:[UIImage imageNamed:@"WaitImage.png"]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger guideid = [[[self.guides objectAtIndex:indexPath.row] valueForKey:@"guideid"] intValue];

    iFixitAppDelegate *appDelegate = (iFixitAppDelegate*)[UIApplication sharedApplication].delegate;

    GuideViewController *vc = [[GuideViewController alloc] initWithGuideid:guideid];
    [appDelegate.window.rootViewController presentModalViewController:vc animated:YES];
    [vc release];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc {
    [_topic release];
    [_guides release];
    [super dealloc];
}

@end
