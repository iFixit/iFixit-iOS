//
//  CategoriesViewController.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import "iFixitAppDelegate.h"
#import "Config.h"
#import "CategoriesViewController.h"
#import "DetailViewController.h"
#import "iPhoneDeviceViewController.h"
#import "DetailGridViewController.h"

@implementation CategoriesViewController

@synthesize delegate, searchBar, searching, searchResults, detailViewController, noResults, inPopover;

- (id)init {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.categories = nil;
        searching = NO;
        self.searchResults = [NSArray array];
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {    
    if (!self.categories)
        [self getAreas];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title) {
        UIImage *titleImage;
        UIImageView *imageTitle;
        switch ([Config currentConfig].site) {
            case ConfigIFixit:
                titleImage = [UIImage imageNamed:@"titleImage.png"];
                imageTitle = [[UIImageView alloc] initWithImage:titleImage];
                imageTitle.contentMode = UIViewContentModeScaleAspectFit;
                self.navigationItem.titleView = imageTitle;
                [titleImage release];
                break;
            case ConfigZeal:
                titleImage = [UIImage imageNamed:@"titleImageZeal.png"];
                imageTitle = [[UIImageView alloc] initWithImage:titleImage];
                self.navigationItem.titleView = imageTitle;
                [titleImage release];
                break;
            /*EAOTitle*/
            default:
                self.title = @"Categories";
                break;
        }
    }
    
    // Make room for the toolbar
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    
    // Show the Dozuki sites select button if needed.
    if ([Config currentConfig].dozuki && [self.title isEqual:@"Categories"]) {
        UIImage *icon = [UIImage imageNamed:@"backtosites.png"];
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:icon style:UIBarButtonItemStyleBordered
                                                                  target:[[UIApplication sharedApplication] delegate]
                                                                  action:@selector(showDozukiSplash)];
        self.navigationItem.leftBarButtonItem = button;
        [button release];
    }

    self.navigationItem.titleView.contentMode = UIViewContentModeScaleAspectFit;
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
    [[iFixitAPI sharedInstance] getCategories:nil forObject:self withSelector:@selector(gotAreas:)];
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
            iPhoneDeviceViewController *dvc = [[iPhoneDeviceViewController alloc] initWithTopic:nil];
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

// This is a deprecated method as of iOS 6.0, keeping this in to support older iOS versions
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGRect frame;
    if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        switch ([Config currentConfig].site) {
            case ConfigMake:
                break;
            case ConfigZeal:
                frame = self.navigationItem.titleView.frame;
                frame.size.width = 100;
                frame.size.height = 25;
                self.navigationItem.titleView.frame = frame;
                break;
            /*EAOLandscapeResize*/
            default:
                frame = self.navigationItem.titleView.frame;
                frame.size.width = 75;
                frame.size.height = 24;
                self.navigationItem.titleView.frame = frame;
        }
    } else {
        switch ([Config currentConfig].site) {
            case ConfigMake:
                break;
            case ConfigZeal:
                frame = self.navigationItem.titleView.frame;
                frame.size.width = 137;
                frame.size.height = 35;
                self.navigationItem.titleView.frame = frame;
                break;
            /*EAOPortraitResize*/
            default:
                frame = self.navigationItem.titleView.frame;
                frame.size.width = 98;
                frame.size.height = 34;
                self.navigationItem.titleView.frame = frame;

        }
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    //self.tableView.scrollEnabled = NO;
    [searchBar setShowsCancelButton:YES animated:YES];  
    
    // Animate the table up.
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [UIView beginAnimations:@"showSearch" context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect bounds = self.navigationController.view.bounds;
        bounds.origin.y = self.navigationController.navigationBar.frame.size.height;
        self.navigationController.view.bounds = bounds;
        [UIView commitAnimations];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
    //self.tableView.scrollEnabled = YES;
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
    
    [[iFixitAPI sharedInstance] getSearchResults:searchText forObject:self withSelector:@selector(gotSearchResults:)];
}

- (void)gotSearchResults:(NSDictionary *)results {
    if ([[results objectForKey:@"search"] isEqual:searchBar.text]) {
        // Remove non-device results from iPhone+iPod search
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            NSArray *list = [results objectForKey:@"results"];
            NSMutableArray *devicesOnly = [NSMutableArray array];
            
            for (NSDictionary *item in list) {
                if ([[item objectForKey:@"class"] isEqual:@"DEVICE"] ||
                    [[item objectForKey:@"namespace"] isEqual:@"TOPIC"]) {
                    [devicesOnly addObject:item];
                }
            }
            
            self.searchResults = [NSArray arrayWithArray:devicesOnly];
        }
        else {
            self.searchResults = [results objectForKey:@"results"];
        }
        
        noResults = [searchResults count] == 0;
        
        [self.tableView reloadData];
    }
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

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (inPopover)
        return;
  
    // Make room for the toolbar
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 44, 0);
    }
    else {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 32, 0);
    }

    // Reset the searching view offset to prevent rotating weirdness.
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        CGRect bounds = self.navigationController.view.bounds;
        bounds.origin.y = 0.0;
        self.navigationController.view.bounds = bounds;
    }
}

#pragma mark -
#pragma mark Table view data source

- (void)setData:(NSDictionary *)dict {
    self.categoryResults = dict;
    self.categories = [self parseCategories:self.categoryResults];
    self.categoryTypes = [[self.categories allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSDictionary*)parseCategories:(NSDictionary *)categoriesCollection {
    NSMutableArray *categories = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *devices = [[[NSMutableArray alloc] init] autorelease];
    NSMutableDictionary *allCategories = [[[NSMutableDictionary alloc] init] autorelease];
    
    // Split categories from devices for iFixit and create key-value objects in the process
    for (id category in categoriesCollection) {
        if ([category isEqualToString:TOPICS]) {
            for (id device in categoriesCollection[TOPICS]) {
                [devices addObject:@{@"name" : device,
                                     @"type" : @(Device)
                }];
            }
        } else {
            [categories addObject:@{@"name" : category,
                                    @"type" : @(Category)
            }];
        }
    }

    // Sort both lists by alphabetical order
    categories = [self sortCategories:categories];
    devices = [self sortCategories:devices];
    
    // If on iFixit, keep them separate
    if ([Config currentConfig].site == ConfigIFixit) {
        if (categories.count)
            allCategories[CATEGORIES] = categories;
        if (devices.count)
            allCategories[DEVICES] = devices;
    } else {
        // If we have both categories and devices, merge them
        if (categories.count && devices.count) {
            [categories addObjectsFromArray:devices];
            allCategories[CATEGORIES] = categories;
        // We only have devices
        } else if (devices.count)
            allCategories[CATEGORIES] = devices;
        // We only have categories
        else
            allCategories[CATEGORIES] = categories;
    }
    
    return allCategories;
}

// Custom sort for our category objects
- (NSMutableArray*)sortCategories:(NSMutableArray*)categories {
    // Sort by alphabetical order
    return [NSMutableArray arrayWithArray:[categories sortedArrayUsingComparator:^NSComparisonResult(id category1, id category2) {
        return [category1[@"name"] compare:category2[@"name"] options:NSCaseInsensitiveSearch];
    }]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    if (searching)
        return 1;
    
    return self.categoryTypes.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (searching)
        return @"Search Results";
	
    return [self.categoryTypes[section] capitalizedString];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (searching) {
        if ([searchResults count])
            return [searchResults count];
        else if (noResults)
            return 1;
        else 
            return 0;
    }
    
    return [self.categories[self.categoryTypes[section]] count];
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
        cell.textLabel.text = searchResults.count ? searchResults[indexPath.row][@"display_title"] : @"No Results Found";
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        NSDictionary *category = self.categories[self.categoryTypes[indexPath.section]][indexPath.row];
        cell.textLabel.text = category[@"name"];
        cell.accessoryType = category[@"type"] == @(Category)
            ? UITableViewCellAccessoryDisclosureIndicator
            : UITableViewCellAccessoryNone;
    }

    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.view endEditing:YES];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (searching && ![searchResults count])
        return;
    
    NSDictionary *category = [[[NSDictionary alloc] init] autorelease];
    
    // We limit our searches to devices for now
    if (searching && [searchResults count]) {
        // Create key value object for search result
        category = @{@"name" : searchResults[indexPath.row][@"title"],
                     @"type" : @(Device)
                   };
    } else
        category = self.categories[self.categoryTypes[indexPath.section]][indexPath.row];

    if (category[@"type"] == @(Category)) {
        CategoriesViewController *vc = [[CategoriesViewController alloc] init];
        vc.title = category[@"name"];
        vc.detailViewController = detailViewController;
        vc.inPopover = inPopover;
        
        [vc setData:[self.categoryResults valueForKey:category[@"name"]]];
        [self.navigationController pushViewController:vc animated:YES];
        [vc.tableView reloadData];
        [vc release];
    } else if (category[@"type"] == @(Device)) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            iPhoneDeviceViewController *vc = [[iPhoneDeviceViewController alloc] initWithTopic:category[@"name"]];
            vc.title = category[@"name"];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        // We show more information on iPad, so we need to build the URL's for the given device
        } else {
            [detailViewController reset];
            [detailViewController.popoverController dismissPopoverAnimated:YES];
            [detailViewController setDevice:category[@"name"]];

            NSURLRequest *request = [NSURLRequest requestWithURL:[self buildWikiURL:category[@"name"]]];
            [detailViewController.wikiWebView loadRequest:request];

            request = [NSURLRequest requestWithURL:[self buildAnswersURL:category[@"name"]]];
            [detailViewController.answersWebView loadRequest:request];
        }
    }
}

// For iPad mostly, build the Wiki URL for a device
- (NSURL*)buildWikiURL:(NSString*)device {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/Device/%@", [Config host],
       [device stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
}

// For iPad mostly, build the Answers URL for a device
- (NSURL*)buildAnswersURL:(NSString*)device {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/Answers/Device/%@", [Config host],
       [device stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.searchBar = nil;
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
    [searchBar release];
    [searchResults release];
    [detailViewController release];
    [self.categories release];
    [self.categoryTypes release];
    [self.categoryResults release];
    
    [super dealloc];
}

@end