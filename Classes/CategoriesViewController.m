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
#import "iPhoneDeviceViewController.h"
#import "DetailGridViewController.h"
#import "BookmarksViewController.h"
#import "ListViewController.h"
#import "CategoryTabBarViewController.h"
#import "GuideCell.h"
#import "UIImageView+WebCache.h"
#import "GuideViewController.h"

@implementation CategoriesViewController

@synthesize delegate, searchBar, searching, searchResults, noResults;

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
    
    // Create a reference to the navigation controller
    self.listViewController = (ListViewController*)self.navigationController;
    
    if (!self.title) {
        UIImage *titleImage;
        UIImageView *imageTitle;
        switch ([Config currentConfig].site) {
            case ConfigIFixit:
                titleImage = [UIImage imageNamed:@"titleImage.png"];
                imageTitle = [[UIImageView alloc] initWithImage:titleImage];
                imageTitle.contentMode = UIViewContentModeScaleAspectFit;
                self.navigationItem.titleView = imageTitle;
                break;
            case ConfigZeal:
                titleImage = [UIImage imageNamed:@"titleImageZeal.png"];
                imageTitle = [[UIImageView alloc] initWithImage:titleImage];
                self.navigationItem.titleView = imageTitle;
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
    
    // Display the favorites button on the top right
    [self.listViewController showFavoritesButton:self];
    
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
        [self.listViewController showFavoritesButton:self];
    } else {
        // If there is no area hierarchy, show a guide list instead
        if ([areas isKindOfClass:[NSArray class]] && ![areas count]) {
            iPhoneDeviceViewController *dvc = [[iPhoneDeviceViewController alloc] initWithTopic:nil];
            [self.navigationController pushViewController:dvc animated:YES];
            [dvc release];
        }
        
        [self showRefreshButton];
    }
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
    self.categoryTypes = [NSMutableArray arrayWithArray:[[self.categories allKeys] sortedArrayUsingSelector:@selector(compare:)]];
}

- (NSMutableDictionary*)parseCategories:(NSDictionary *)categoriesCollection {
    NSMutableArray *categories = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *devices = [[[NSMutableArray alloc] init] autorelease];
    NSMutableDictionary *allCategories = [[[NSMutableDictionary alloc] init] autorelease];
    
    // Split categories from devices for iFixit and create key-value objects in the process
    for (id category in categoriesCollection) {
        if ([category isEqualToString:TOPICS]) {
            for (id device in categoriesCollection[TOPICS]) {
                [devices addObject:@{@"name" : device,
                                     @"type" : @(DEVICE)
                }];
            }
        } else {
            [categories addObject:@{@"name" : category,
                                    @"type" : @(CATEGORY)
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
    
    NSDictionary *category = self.categories[self.categoryTypes[indexPath.section]][indexPath.row];
    static NSString *cellIdentifier;
    id cell;
    
    // If searching, create the cell and bail early
    if (searching) {
        cellIdentifier = @"CellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
            [[cell textLabel] setText:(searchResults.count ? searchResults[indexPath.row][@"display_title"] : @"No Results Found")];
        }
        
        return cell;
    }
    
    if (category[@"type"] == @(DEVICE) || category[@"type"] == @(CATEGORY)) {
        
        cellIdentifier = @"CellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        }
        
        [cell setAccessoryType: (category[@"type"] == @(CATEGORY))
                              ? UITableViewCellAccessoryDisclosureIndicator
                              : UITableViewCellAccessoryNone];
        [[cell textLabel] setText:category[@"name"]];

    } else {
        cellIdentifier = @"GuideCell";
        cell = (GuideCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[[GuideCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        }
        
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [[cell imageView] setImageWithURL:[NSURL URLWithString:category[@"thumbnail"]] placeholderImage:[UIImage imageNamed:@"NoImage.jpg"]];
    }
    
    [[cell textLabel] setText:category[@"name"]];
    [[cell textLabel] setMinimumFontSize:11.0f];
    [[cell textLabel] setAdjustsFontSizeToFitWidth:YES];
    
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
                     @"type" : @(DEVICE)
                   };
    } else
        category = self.categories[self.categoryTypes[indexPath.section]][indexPath.row];

    if (category[@"type"] == @(CATEGORY)) {
        CategoriesViewController *vc = [[CategoriesViewController alloc] init];
        vc.title = category[@"name"];
        
        [vc setData:[self.categoryResults valueForKey:category[@"name"]]];
        [self.navigationController pushViewController:vc animated:YES];
        [vc.tableView reloadData];
        [vc release];
        
    // Device
    } else if (category[@"type"] == @(DEVICE)) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            iPhoneDeviceViewController *vc = [[iPhoneDeviceViewController alloc] initWithTopic:category[@"name"]];
            vc.title = category[@"name"];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
    // Guide
    } else {
        NSInteger guideid = [category[@"guideid"] integerValue];
        
        GuideViewController *vc = [[GuideViewController alloc] initWithGuideid:guideid];
        [self presentModalViewController:vc animated:YES];
        [vc release];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    [[iFixitAPI sharedInstance] getTopic:category[@"name"] forObject:self.listViewController.categoryTabBarViewController withSelector:@selector(gotCategoryResult:)];
    
    // Change the back button title to @"Home", only if we have 2 views on the stack
    if (self.navigationController.viewControllers.count == 2) {
        self.listViewController.navigationBar.backItem.title = NSLocalizedString(@"Home", nil);
    }
    
}

// Massage the data to match our already gathered data
- (void)modifyTypesForGuides:(NSArray*)guides {
    for (id guide in guides) {
        guide[@"type"] = @(GUIDE);
        // If we update to 2.0, check for subject, then default back to title if subject DNE
        guide[@"name"] = guide[@"subject"];
    }
}

// Add guides to the tableview if they exist
- (void)addGuidesToTableView:(NSArray*)guides {
    [self modifyTypesForGuides:guides];
    
    // Begin the update
    [self.tableView beginUpdates];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.categoryTypes.count] withRowAnimation:UITableViewRowAnimationFade];
    
    // Add the new guides to our category list
    [self.categories addEntriesFromDictionary:@{@"guides": guides}];
    
    // Add a new category type "guides"
    [self.categoryTypes addObject:@"guides"];
    
    // Donezo
    [self.tableView endUpdates];
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
    [self.listViewController release];
    [self.categories release];
    [self.categoryTypes release];
    [self.categoryResults release];
    
    [super dealloc];
}

@end
