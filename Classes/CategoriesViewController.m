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
#import "CategoriesSingleton.h"
#import "Reachability.h"

@implementation CategoriesViewController

@synthesize delegate, searchBar, searching, searchResults, noResults, categorySearchResult;

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
                titleImage = [UIImage imageNamed:@"iPhone-ifixit-logo.png"];
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
        }
    }
    
    // Placeholder text for searchbar
    self.searchBar.placeholder = NSLocalizedString(@"Search", nil);
    
    // Make room for the toolbar
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationItem.titleView.contentMode = UIViewContentModeScaleAspectFit;
    
    // Display the favorites button on the top right
    [self.listViewController showFavoritesButton:self];
    
    // Solves an edge case dealing with categories not always loading
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && self.listViewController.viewControllers.count == 1) {
        [self viewWillAppear:NO];
    }
} 

- (void)displayBackToSitesButton {
    // Show the Dozuki sites select button if needed.
    if ([Config currentConfig].dozuki && self.navigationController.viewControllers.count == 1) {
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
    if (self.listViewController.viewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = refreshButton;
        [self.listViewController showFavoritesButton:self];
    } else {
        self.navigationItem.rightBarButtonItem = refreshButton;
    }
    
    [refreshButton release];
}

- (void)configureTableViewTitleLogoFromURL:(NSString*)URL {
    
    UIImageView *imageTitle = [[UIImageView alloc] init];
    imageTitle.contentMode = UIViewContentModeScaleAspectFit;
    [imageTitle setImageWithURL:[NSURL URLWithString:URL]];
    
    self.navigationItem.titleView = imageTitle;
    
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
}
- (void)setTableViewTitle {
    UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:24.0];
    titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationItem.titleView = titleLabel;
    titleLabel.text = [Config currentConfig].title.length
                    ? [Config currentConfig].title
                    : NSLocalizedString(@"Categories", nil);
    titleLabel.alpha = 0;
    [titleLabel sizeToFit];
    
    [UIView animateWithDuration:0.3 animations:^{
        titleLabel.alpha = 1;
    }];
}
- (void)getAreas {
    [self showLoading];
    [[iFixitAPI sharedInstance] getCategoriesForObject:self withSelector:@selector(gotAreas:)];
}


- (void)gotAreas:(NSDictionary *)areas {
    // Only show backToSites button on Dozuki and if we are a root view
    if ([Config currentConfig].dozuki && self.listViewController.viewControllers.count == 1) {
        [self displayBackToSitesButton];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    self.navigationItem.rightBarButtonItem = nil;
    
    // Areas was nil, meaning we probably had a connection error
    if (!areas) {
        [self showRefreshButton];
        [iFixitAPI displayConnectionErrorAlert];
    }
    
    if ([areas allKeys].count) {
        // Save a master category list to a singleton if it hasn't
        // been created yet
        if (![CategoriesSingleton sharedInstance].masterCategoryList) {
            [CategoriesSingleton sharedInstance].masterCategoryList = areas;
        }
        
        [self setData:areas];
        [self.tableView reloadData];
        [self.listViewController showFavoritesButton:self];
    } else {
        // If there is no area hierarchy, show a guide list instead
//        if ([areas isKindOfClass:[NSArray class]] && ![areas count]) {
            iPhoneDeviceViewController *dvc = [[iPhoneDeviceViewController alloc] initWithTopic:nil];
            [self.navigationController pushViewController:dvc animated:YES];
            [dvc release];
//        }
    }
}

// This is a deprecated method as of iOS 6.0, keeping this in to support older iOS versions
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGRect frame;
    
    if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        switch ([Config currentConfig].site) {
            case ConfigMake:
                break;
            case ConfigDozuki:
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
            case ConfigDozuki:
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
        
        // Disable the favorites button to avoid accidental presses
        self.listViewController.favoritesButton.enabled = NO;
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
        
        self.listViewController.favoritesButton.enabled = YES;
    }
}


- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    // Let the user input text if they are under the char limit or trying to delete text
    return (searchBar.text.length <= 128 || [text isEqualToString:@""]);
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
        
        self.searchResults = [results objectForKey:@"results"];
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
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];    
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus == NotReachable) {
        [iFixitAPI displayConnectionErrorAlert];
    }
    
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
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 44, 0);
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
        if ([categoriesCollection[category] count]) {
            [categories addObject:@{@"name" : category,
                                    @"type" : @(CATEGORY)
            }];
        } else {
            [devices addObject:@{@"name" : category,
                                 @"type" : @(DEVICE)
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
        return NSLocalizedString(@"Search Results", nil);
	
    return NSLocalizedString([self.categoryTypes[section] capitalizedString], nil);
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
    
    static NSString *cellIdentifier;
    id cell;
    
    // If searching, create the cell and bail early
    if (searching) {
        cellIdentifier = @"CellIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        }
        
        if (searchResults.count > 0) {
            [[cell textLabel] setText:searchResults[indexPath.row][@"display_title"]];
        } else {
            [[cell textLabel] setText:NSLocalizedString(@"No Results Found", nil)];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        return cell;
    }
    
    NSDictionary *category = self.categories[self.categoryTypes[indexPath.section]][indexPath.row];
    
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
        
        NSString *thumbnailImage = category[@"thumbnail"];
        thumbnailImage = thumbnailImage.length > 0 ? thumbnailImage : NULL;
        
        [[cell imageView] setImageWithURL:[NSURL URLWithString:thumbnailImage] placeholderImage:[UIImage imageNamed:@"WaitImage.png"]];
    }
    
    [[cell textLabel] setText:category[@"name"]];
    [[cell textLabel] setMinimumFontSize:11.0f];
    [[cell textLabel] setAdjustsFontSizeToFitWidth:YES];
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];    
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // If we can't connect to internet, let's bail early and display an error.
    if (internetStatus == NotReachable) {
        [iFixitAPI displayConnectionErrorAlert];
        return;
    }
    
    [self.view endEditing:YES];
    
    if (searching && ![searchResults count])
        return;
    
    NSDictionary *category = [[[NSDictionary alloc] init] autorelease];
    
    // We limit our searches to devices for now
    if (searching && [searchResults count]) {
        // Create key value object for search result
        category = @{@"name" : searchResults[indexPath.row][@"title"],
                     @"type" : @(CATEGORY)
                   };
    } else
        category = self.categories[self.categoryTypes[indexPath.section]][indexPath.row];
    

    if (category[@"type"] == @(CATEGORY)) {
        CategoriesViewController *vc = [[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController" bundle:nil];
        vc.title = category[@"name"];
        
        if (searching) {
            [self findChildCategoriesFromParent:category[@"name"]];
        }
        
        [vc setData:(searching) ? categorySearchResult : [self.categoryResults valueForKey:category[@"name"]]];
        
        [self.navigationController pushViewController:vc animated:YES];
        [vc.tableView reloadData];
        categorySearchResult = nil;
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
    
    [[iFixitAPI sharedInstance] getCategory:category[@"name"] forObject:self.listViewController.categoryTabBarViewController withSelector:@selector(gotCategoryResult:)];
    
    // Change the back button title to @"Home", only if we have 2 views on the stack
    if (self.navigationController.viewControllers.count == 2) {
        self.listViewController.navigationBar.backItem.title = NSLocalizedString(@"Home", nil);
    }
    
}

// Given a parent category, find the category and it's children
- (void)findChildCategoriesFromParent:(NSString*)parentCategory {
    [self findCategory:parentCategory inList:[CategoriesSingleton sharedInstance].masterCategoryList];
}

// Recursive function to find the search result in our master category list
- (BOOL)findCategory:(NSString*)needle inList:(NSDictionary*)haystack {
    // Try to access the key first
    if (haystack[needle]) {
        categorySearchResult = haystack[needle];
        return TRUE;
    // Key doesn't exist, we must go deeper
    } else {
        for (id category in haystack) {
            // We have another dictionary to look at, lets call ourselves
            if ([haystack[category] count]) {
                // If we return true, that means we found our category, lets stop iterating through our current level
                if ([self findCategory:needle inList:haystack[category]])
                    break;
            }
        }
    }
    
    return FALSE;
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
