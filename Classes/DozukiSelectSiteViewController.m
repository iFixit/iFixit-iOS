//
//  DozukiSelectSiteViewController.m
//  iFixit
//
//  Created by David Patierno on 8/16/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

#import "DozukiSelectSiteViewController.h"
#import "iFixitAppDelegate.h"
#import "Config.h"
#import "iFixitAPI.h"

#define SITES_REQUEST_LIMIT 25

@implementation DozukiSelectSiteViewController

@synthesize sites;

- (void)loadMore {
    if (!loading) {
        loading = YES;
        [self showLoading];
        [[iFixitAPI sharedInstance] getSitesWithLimit:SITES_REQUEST_LIMIT andOffset:[sites count] forObject:self withSelector:@selector(gotSites:)];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.sites = [NSMutableArray array];
        hasMoreSites = YES;
        self.title = @"Choose a Site";
        [self loadMore];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
}
- (void)gotSites:(NSArray *)theSites {
    [self hideLoading];
    
    int count = [theSites count];
    
    if (theSites && count) {
        hasMoreSites = [theSites count] == SITES_REQUEST_LIMIT;

        // Insert these new rows at the bottom.
        NSMutableArray *paths = [NSMutableArray array];
        for (int i=0; i<[theSites count]; i++)
            [paths addObject:[NSIndexPath indexPathForRow:(i + count) inSection:0]];
        
        [sites addObjectsFromArray:theSites];
        [self.tableView reloadData];
        // I don't like this animation.
        // [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        hasMoreSites = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not load site list"
                                                        message:@"Please check your internet connection and try again."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Retry", nil];
        [alert show];
        [alert release];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex)
        [self loadMore];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    if (![sites count])
        [self loadMore];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (loading)
        [self showLoading];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [sites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [[sites objectAtIndex:indexPath.row] valueForKey:@"title"];
    cell.detailTextLabel.text = [[sites objectAtIndex:indexPath.row] valueForKey:@"description"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [TestFlight passCheckpoint:@"Dozuki Site Select"];
    
    // Save this choice for future launches
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *domain = [[sites objectAtIndex:indexPath.row] valueForKey:@"domain"];
    [defaults setValue:domain forKey:@"domain"];
    [defaults synchronize];
    
    iFixitAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate loadSite:domain];
 
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Load the next batch if we're near the bottom.
    if ((indexPath.row >= (NSInteger)[sites count] - 1) && hasMoreSites && !loading)
        [self loadMore];
}

- (void)dealloc {
    self.sites = nil;
    [super dealloc];
}

@end
