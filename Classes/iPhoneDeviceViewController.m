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

@implementation iPhoneDeviceViewController

@synthesize device=_device;
@synthesize guides=_guides;

- (id)initWithDevice:(NSString *)device {
    if ((self = [super initWithNibName:@"iPhoneDeviceView" bundle:nil])) {
        self.device = device;
        self.guides = [NSArray array];
        
        [self getGuides];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)getGuides {
    if (!loading) {
        loading = YES;
        [self showLoading];
        [[iFixitAPI sharedInstance] getDevice:self.device forObject:self withSelector:@selector(gotDevice:)];
    }
}

- (void)gotDevice:(NSDictionary *)data {
    self.guides = [data arrayForKey:@"guides"];
    [self.tableView reloadData];
    [self hideLoading];
    
    if (!self.guides) {
        [self showRefreshButton];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error loading device"
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
        [self getGuides];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Make room for the toolbar
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];

    if (loading)
        [self showLoading];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GuideCell";
    
    GuideCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GuideCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [[self.guides objectAtIndex:indexPath.row] valueForKey:@"subject"];
    
    NSString *thumbnailURL = [[self.guides objectAtIndex:indexPath.row] valueForKey:@"thumbnail"];
    [cell.imageView setImageWithURL:[NSURL URLWithString:thumbnailURL] placeholderImage:[UIImage imageNamed:@"NoImage_300x225.jpg"]];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger guideid = [[[self.guides objectAtIndex:indexPath.row] valueForKey:@"guideid"] intValue];
    [(iFixitAppDelegate *)[[UIApplication sharedApplication] delegate] showGuideid:guideid];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc {
    [_device release];
    [super dealloc];
}

@end
