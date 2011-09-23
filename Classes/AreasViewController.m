//
//  AreasViewController.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import "iFixitAppDelegate.h"
#import "Config.h"
#import "AreasViewController.h"
#import "DetailViewController.h"
#import "iPhoneDeviceViewController.h"

@implementation AreasViewController

@synthesize delegate, searchBar, searching, searchResults, detailViewController, data, tree, keys, leafs;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.tree = nil;
        searching = NO;
        self.searchResults = [NSArray array];
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {    
    if (!tree)
        [self getAreas];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title) {
        self.title = @"Areas";
        
        if ([Config currentConfig].site != ConfigIFixit && [Config currentConfig].site != ConfigIFixitDev) {
            
        }
        else {
            UIImage *titleImage = [UIImage imageNamed:@"titleImage.png"];
            UIImageView *imageTitle = [[UIImageView alloc] initWithImage:titleImage];
            self.navigationItem.titleView = imageTitle;
            [imageTitle release];
        }
    }
    
    // Color the searchbar.
    searchBar.tintColor = [Config currentConfig].toolbarColor;
    
    // Make room for the toolbar
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    
    // Show the Dozuki sites select button if needed.
    if ([Config currentConfig].dozuki && self.navigationController.topViewController == self) {
        UIImage *icon = [UIImage imageNamed:@"backtosites.png"];
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:icon style:UIBarButtonItemStyleBordered
                                                                  target:[[UIApplication sharedApplication] delegate]
                                                                  action:@selector(showDozukiSplash)];
        self.navigationItem.leftBarButtonItem = button;
        [button release];
    }
}

- (void)showLoading {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 20.0f)];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [container addSubview:spinner];
    [spinner startAnimating];
    [spinner release];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:container];
    self.navigationItem.rightBarButtonItem = button;
    [container release];
    [button release];
}
- (void)showRefreshButton {
    // Show a refresh button in the navBar.
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(getAreas)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    [refreshButton release];   
}
- (void)getAreas {
    [self showLoading];
    [[iFixitAPI sharedInstance] getAreas:nil forObject:self withSelector:@selector(gotAreas:)];
}

- (void)gotAreas:(NSDictionary *)areas {
    self.navigationItem.rightBarButtonItem = nil;
    
    if ([areas isKindOfClass:[NSDictionary class]]) {
        [self setData:areas];
        [self.tableView reloadData];
    }
    else {
        // If there is no area hierarchy, show a guide list instead
        if ([areas isKindOfClass:[NSArray class]] && ![areas count]) {
            iPhoneDeviceViewController *dvc = [[iPhoneDeviceViewController alloc] initWithDevice:nil];
            [self.navigationController pushViewController:dvc animated:YES];
            [dvc release];
        }

        [self showRefreshButton];
    }
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.navigationItem.titleView = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([Config currentConfig].site == ConfigMake || [Config currentConfig].site == ConfigMakeDev) {
        
    }
    else {
        CGRect frame = self.navigationItem.titleView.frame;
        
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            frame.size.width = 75;
            frame.size.height = 24;
        }
        else {
            frame.size.width = 98;
            frame.size.height = 34;
        }
        
        self.navigationItem.titleView.frame = frame;
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    //self.tableView.scrollEnabled = NO;
    [searchBar setShowsCancelButton:YES animated:YES];  
    
    // Animate the table up.
    if (![iFixitAppDelegate isIPad]) {
        [UIView beginAnimations:@"showSearch" context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect bounds = self.navigationController.view.bounds;
        bounds.origin.y = 44;
        self.navigationController.view.bounds = bounds;
        [UIView commitAnimations];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
    //self.tableView.scrollEnabled = YES;
    if ([theSearchBar.text isEqual:@""]) {
        searching = NO;
        [self.tableView reloadData];
    }
    
    [searchBar setShowsCancelButton:NO animated:YES];    
    
    // Animate the table back down.
    if (![iFixitAppDelegate isIPad]) {
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
        [self.tableView reloadData];    
        self.searchResults = [NSArray array];
        return;
    }
    
    if (!searching) {
        searching = YES;
        [self.tableView reloadData];    
    }
    
    [[iFixitAPI sharedInstance] getSearchResults:searchText forObject:self withSelector:@selector(gotSearchResults:)];
}

- (void)gotSearchResults:(NSDictionary *)results {
    if ([[results objectForKey:@"search"] isEqual:searchBar.text]) {
        
        // Remove non-device results from iPhone+iPod search
        if (![iFixitAppDelegate isIPad]) {
            NSArray *list = [results objectForKey:@"results"];
            NSMutableArray *devicesOnly = [NSMutableArray array];
            
            for (NSDictionary *item in list) {
                if ([[item objectForKey:@"class"] isEqual:@"DEVICE"])
                    [devicesOnly addObject:item];
            }
            
            self.searchResults = [NSArray arrayWithArray:devicesOnly];
        }
        else {
            self.searchResults = [results objectForKey:@"results"];
        }
        
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar {
    searchBar.text = @"";
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

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
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

#pragma mark -
#pragma mark Table view data source

- (void)setData:(NSDictionary *)dict {
    [data release];
    data = nil;
    data = [dict retain];
    
	// Separate the leafs.
	self.tree = [NSMutableDictionary dictionaryWithDictionary:dict];
	self.leafs = [[tree objectForKey:@"DEVICES"] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	[tree removeObjectForKey:@"DEVICES"];
	self.keys = [[tree allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    if (searching)
        return 1;
    
    return [keys count] && [leafs count] ? 2 : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (searching)
        return @"Search Results";
    
	// Don't show titles if there's only one
	if ([self numberOfSectionsInTableView:nil] == 1 || ![keys count])
		return nil;
	
	return section == 0 ? @"Areas" : @"Devices";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (searching)
        return [searchResults count];
    
    // Return the number of rows in the section.
	if (section == 0 && [keys count])
		return [keys count];
	return [leafs count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.minimumFontSize = 11.0f;
    }
    
    if (searching) {
        cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"display_title"];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        // Configure the cell.
        if (indexPath.section == 0 && [keys count]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", [keys objectAtIndex:indexPath.row]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", [leafs objectAtIndex:indexPath.row]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *url = nil;
    
	if (indexPath.section == 0 && [keys count] && !searching) {
		AreasViewController *vc = [[AreasViewController alloc] init];
		vc.detailViewController = detailViewController;

		NSString *area = [keys objectAtIndex:indexPath.row];
		[vc setData:[tree valueForKey:area]];
		[vc.tableView reloadData];
		
        vc.title = area;
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
        
        // Build the Area URL.
		url = [NSString stringWithFormat:@"http://%@/Area/%@", 
               [Config host],
               [area stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	} else {
        NSString *title = nil;
        NSString *display_title = nil;
        
        if (searching) {
            url = [NSString stringWithFormat:@"http://%@%@", 
                   [Config host],
                   [[searchResults objectAtIndex:indexPath.row] objectForKey:@"url"]];
            title = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"title"];
            display_title = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"display_title"];
        }
        else {
            // Build the Device URL.
            NSString *device = [leafs objectAtIndex:indexPath.row];
            url = [NSString stringWithFormat:@"http://%@/Device/%@", 
                   [Config host],
                   [device stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
            title = device;
            display_title = device;
        }
        
        // iPhone: Push a webView onto the stack.
        if (![iFixitAppDelegate isIPad]) {
            iPhoneDeviceViewController *vc = [[iPhoneDeviceViewController alloc] initWithDevice:title];
            vc.title = display_title;
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
	}
    
    // iPad: Show the device in detailViewController
    if ([iFixitAppDelegate isIPad]) {
        [(iFixitAppDelegate *)[[UIApplication sharedApplication] delegate] showBrowser];    
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];        
        [detailViewController.webView loadRequest:request];
        [detailViewController.popoverController dismissPopoverAnimated:YES];
    }

    [self.view endEditing:YES];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [detailViewController release];
    [super dealloc];
}


@end

