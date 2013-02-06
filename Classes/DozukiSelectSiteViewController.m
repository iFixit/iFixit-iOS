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
#import "UIColor+Hex.h"

#define SITES_REQUEST_LIMIT 500

static NSMutableArray *sites = nil;
static NSMutableArray *prioritySites = nil;

// Dismiss the keyboard when searchBar resigns first responder.
@implementation UIViewController (DismissKeyboard)
- (BOOL)disablesAutomaticKeyboardDismissal { return NO; }
@end

@implementation DozukiSelectSiteViewController

@synthesize searchBar, searchResults;
@synthesize simple;

- (NSString*)storedListPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    return [docDirectory stringByAppendingPathComponent:@"dozukiSiteList.plist"];
}

- (void)loadMore {
    if (!loading) {
        [sites removeAllObjects];
        [prioritySites removeAllObjects];
        loading = YES;
        [self showLoading];
        [[iFixitAPI sharedInstance] getSitesWithLimit:SITES_REQUEST_LIMIT
                                            andOffset:[sites count]
                                            forObject:self
                                         withSelector:@selector(gotSites:)];
    }
}

- (id)initWithSimple:(BOOL)simple_ {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        // Custom initialization
        if (!sites) {
            sites = [[NSMutableArray array] retain];
            prioritySites = [[NSMutableArray array] retain];
        }
        hasMoreSites = YES;
        simple = simple_;
        self.title = @"Choose a Site";
        [self loadMore];
    }
    return self;
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
        for (int i=0; i<[theSites count]; i++) {
            
            [paths addObject:[NSIndexPath indexPathForRow:(i + count) inSection:0]];
            
            // Check for priority sites and separate them off
            NSDictionary *site = [theSites objectAtIndex:i];
            if ([site objectForKey:@"priority"] && ![site objectForKey:@"hideFromiOS"]) {
                [prioritySites addObject:site];
            }
        }
        
        // Populate the non-priority sites list.
        for (NSDictionary *site in theSites) {
            if (![site objectForKey:@"priority"] && ![site objectForKey:@"hideFromiOS"]) {
                [sites addObject:site];
            }
        }

        [self.tableView reloadData];

        // Cache to disk.
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              prioritySites, @"prioritySites",
                              sites, @"sites",
                              nil];
        [dict writeToFile:[self storedListPath] atomically:YES];
    }
    else {
        hasMoreSites = NO;
        if ([sites count])
            return;

        // If we failed to get fresh data, use the cached site list if available.
        NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:[self storedListPath]];
        if (![sites count] && dict) {
            [sites release];
            [prioritySites release];
            sites = [[dict objectForKey:@"sites"] mutableCopy];
            prioritySites = [[dict objectForKey:@"prioritySites"] mutableCopy];
            [self.tableView reloadData];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not load site list"
                                                            message:@"Please check your internet connection and try again."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Retry", nil];
            [alert show];
            [alert release];
        }
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

- (void)viewDidLoad {
    [super viewDidLoad];

    // Add the search bar
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 36.0)];
    searchBar.placeholder = @"Search";
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // Update loading display status.
    if (loading)
        [self showLoading];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    [searchBar setShowsCancelButton:YES animated:YES];  
    
    // Animate the table up.
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [UIView beginAnimations:@"showSearch" context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect bounds = self.navigationController.view.bounds;
        bounds.origin.y = 44;
        self.navigationController.view.bounds = bounds;
        [UIView commitAnimations];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
    if ([theSearchBar.text isEqual:@""]) {
        searching = NO;
        noResults = NO;
        [self.tableView reloadData];
    }
    
    [searchBar setShowsCancelButton:NO animated:YES];    
    
    // Animate the table back down.
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [UIView beginAnimations:@"showSearch" context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect bounds = self.navigationController.view.bounds;
        bounds.origin.y = 0;
        self.navigationController.view.bounds = bounds;
        [UIView commitAnimations];  
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqual:@""]) {
        searching = NO;
        noResults = NO;
        [self.tableView reloadData];    
        self.searchResults = [NSArray array];
        return;
    }
    
    if (!searching) {
        searching = YES;
        [self.tableView reloadData];    
    }

    // Do the search in-memory.
    self.searchResults = [NSMutableArray array];
    NSMutableArray *combinedSites = [NSMutableArray arrayWithArray:prioritySites];
    [combinedSites addObjectsFromArray:sites];
    
    for (NSDictionary *site in combinedSites) {
        NSRange range = [[site objectForKey:@"title"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            [searchResults addObject:site];
        }
        else {
            range = [[site objectForKey:@"description"] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                [searchResults addObject:site];
            }
        }
    }

    noResults = [searchResults count] == 0;
    
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar {
    searchBar.text = @"";
    noResults = NO;
    [self.view endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [self.view endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [searchBar setShowsCancelButton:NO animated:NO];
    CGRect bounds = self.navigationController.view.bounds;
    bounds.origin.y = 0;
    self.navigationController.view.bounds = bounds;
    
    [self.view endEditing:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (searching) {
        if ([searchResults count])
            return [searchResults count];
        else if (noResults)
            return 1;
        else 
            return 0;
    }
    
    if (simple && [prioritySites count])
        return [prioritySites count] + 1;
    
    return [sites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (searching) {
        if ([searchResults count]) {
            cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"title"];
            cell.detailTextLabel.text = [[searchResults objectAtIndex:indexPath.row] valueForKey:@"description"];
        }
        else {
            cell.textLabel.text = @"No Results Found";
            cell.detailTextLabel.text = nil;
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        NSArray *sitesArray = simple ? prioritySites : sites;
        
        // Configure the cell...
        if (simple && indexPath.row == [sitesArray count]) {
            cell.textLabel.text = @"More Sites...";
            cell.detailTextLabel.text = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell.textLabel.text = [[sitesArray objectAtIndex:indexPath.row] valueForKey:@"title"];
            cell.detailTextLabel.text = [[sitesArray objectAtIndex:indexPath.row] valueForKey:@"description"];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (searching && ![searchResults count])
        return;
    
    NSArray *sitesArray = nil;
    if (searching)
        sitesArray = searchResults;
    else if (simple)
        sitesArray = prioritySites;
    else
        sitesArray = sites;

    [TestFlight passCheckpoint:@"Dozuki Site Select"];

    if (!searching && simple && indexPath.row == [sitesArray count]) {
        DozukiSelectSiteViewController *vc = [[DozukiSelectSiteViewController alloc] initWithSimple:NO];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
    else {
        NSDictionary *site = [sitesArray objectAtIndex:indexPath.row];
        
        iFixitAppDelegate *appDelegate = (iFixitAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate loadSite:site];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Load the next batch if we're near the bottom.
    if ((indexPath.row >= (NSInteger)[sites count] - 1) && hasMoreSites && !loading)
        [self loadMore];
}

- (void)dealloc {
    [searchBar release];
    [searchResults release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setSearchBar:nil];
    [super viewDidUnload];
}
@end
