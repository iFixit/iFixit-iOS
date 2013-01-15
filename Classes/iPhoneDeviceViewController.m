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
#import "DetailViewController.h"
#import "GuideViewController.h"
#import "Config.h"

@implementation iPhoneDeviceViewController

@synthesize topic=_topic;
@synthesize guides=_guides;

- (id)initWithTopic:(NSString *)topic {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.topic = topic;
        self.guides = [NSArray array];
        
        if (!topic)
            self.title = @"Guides";
        
        [self getGuides];
    }
    return self;
}

#pragma mark - View lifecycle

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
    if ([Config currentConfig].site == ConfigCrucial) {
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [infoButton addTarget:self action:@selector(infoButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
        self.navigationItem.rightBarButtonItem = infoItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)infoButtonTouched {    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Powered by Dozuki"
                                                    message:@"This app is powered by the Dozuki platform. Create, update, and distribute all of your service documentation to the field instantly. Find out more at Dozuki.com"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Visit Dozuki", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex; {
    
    // Take the user to Dozuki.com - This is only for Crucial. This will only be called from a Crucial
    // So no need to check to see for their site until we add more custom sites that want an info button.
    if (buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString:@"http://www.dozuki.com"];
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

- (void)getGuides {
    if (!loading) {
        loading = YES;
        [self showLoading];
        
        if (self.topic)
            [[iFixitAPI sharedInstance] getTopic:self.topic forObject:self withSelector:@selector(gotDevice:)];
        else
            [[iFixitAPI sharedInstance] getGuides:nil forObject:self withSelector:@selector(gotGuides:)];
    }
}

- (void)gotGuides:(NSArray *)guides {
    self.guides = guides;
    [self.tableView reloadData];
    [self hideLoading];
    
    if (!self.guides)
        [self showRefreshButton];
}
- (void)gotDevice:(NSDictionary *)data {
    self.guides = [data arrayForKey:@"guides"];
    [self.tableView reloadData];
    [self hideLoading];
    
    if (!self.guides)
        [self showRefreshButton];
    else if (![self.guides count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No guides found"
                                                        message:@"This device has no guides."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Okay", nil];
        [alert show];
        [alert release];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

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
    
    // Run some error checking.
    if (!subject || [subject isEqual:[NSNull null]])
        subject = [[self.guides objectAtIndex:indexPath.row] valueForKey:@"thing"];

    if (!subject || [subject isEqual:[NSNull null]] || [subject isEqual:@""]) {
        subject = @"Untitled";
    }
    else {
        subject = [subject stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        subject = [subject stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        subject = [subject stringByReplacingOccurrencesOfString:@"<wbr />" withString:@""];
    }
    
    cell.textLabel.text = subject;
    
    NSString *thumbnailURL = [[self.guides objectAtIndex:indexPath.row] valueForKey:@"thumbnail"];
    [cell.imageView setImageWithURL:[NSURL URLWithString:thumbnailURL] placeholderImage:[UIImage imageNamed:@"NoImage_300x225.jpg"]];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger guideid = [[[self.guides objectAtIndex:indexPath.row] valueForKey:@"guideid"] intValue];

    iFixitAppDelegate *appDelegate = (iFixitAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.detailViewController.popoverController dismissPopoverAnimated:YES];

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
