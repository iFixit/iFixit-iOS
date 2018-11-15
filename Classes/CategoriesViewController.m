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
#import "SearchCell.h"
#import "UIImageView+WebCache.h"
#import "GuideViewController.h"
#import "CategoriesSingleton.h"
#import "Reachability.h"
#import "ZBarReaderViewController.h"
#import "ZBarImageScanner.h"
#import "Guide.h"
#import "GuideBookmarks.h"
#import "GuideLib.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "WikiVC.h"

@implementation CategoriesViewController

@synthesize delegate, searchBar, searchResults, noResults, categorySearchResult;

BOOL searchViewEnabled;

- (id)init {
     if ((self = [super initWithNibName:nil bundle:nil])) {
          self.categories = nil;
          self.searching = NO;
          searchResults = [[NSMutableDictionary alloc] initWithCapacity:2];
     }
     return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {    
     if (!self.categories)
          [self getAreas];
     
}

- (void)orientationChanged:(NSNotification *)notification{
     if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone &&
         searchViewEnabled && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
          [self enableSearchView:YES];
     }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
     [self orientationChanged:nil];
}


- (void)viewDidLoad {
     [super viewDidLoad];
     [self presentTransparentNavigationBar];
     
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(orientationChanged:)
                                                  name:UIDeviceOrientationDidChangeNotification
                                                object:nil
      ];
     
     searchViewEnabled = NO;
     
     // Create a reference to the navigation controller
     self.listViewController = (ListViewController*)self.navigationController;
     
     // Create our empty dictionary
     searchResults = [[NSMutableDictionary alloc] initWithCapacity:2];
     
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
               case ConfigMjtrim:
                    titleImage = [UIImage imageNamed:@"titleImageMjtrim.png"];
                    imageTitle = [[UIImageView alloc] initWithImage:titleImage];
                    self.navigationItem.titleView = imageTitle;
                    break;
               case ConfigHyperthermToolkit:
                    titleImage = [UIImage imageNamed:@"accustream_logo_transparent.png"];
                    imageTitle = [[UIImageView alloc] initWithImage:titleImage];
                    self.navigationItem.titleView = imageTitle;
                    break;
               case ConfigAccustream:
                    titleImage = [UIImage imageNamed:@"accustream_logo_transparent.png"];
                    imageTitle = [[UIImageView alloc] initWithImage:titleImage];
                    self.navigationItem.titleView = imageTitle;
                    break;
               case ConfigMagnolia:
                    titleImage = [UIImage imageNamed:@"titleImageMagnoliamedical.png"];
                    imageTitle = [[UIImageView alloc] initWithImage:titleImage];
                    self.navigationItem.titleView = imageTitle;
                    break;
               case ConfigComcast:
                    titleImage = [UIImage imageNamed:@"titleImageComcast.png"];
                    imageTitle = [[UIImageView alloc] initWithImage:titleImage];
                    self.navigationItem.titleView = imageTitle;
                    break;
               case ConfigDripAssist:
                    titleImage = [UIImage imageNamed:@"titleImageDripassist.png"];
                    imageTitle = [[UIImageView alloc] initWithImage:titleImage];
                    self.navigationItem.titleView = imageTitle;
                    break;
               case ConfigPva:
                    titleImage = [UIImage imageNamed:@"titleImagePva.png"];
                    imageTitle = [[UIImageView alloc] initWithImage:titleImage];
                    self.navigationItem.titleView = imageTitle;
                    break;
               case ConfigOscaro:
                    titleImage = [UIImage imageNamed:@"titleImageOscaro.png"];
                    imageTitle = [[UIImageView alloc] initWithImage:titleImage];
                    self.navigationItem.titleView = imageTitle;
                    break;
               case ConfigTechtitanhq:
                    titleImage = [UIImage imageNamed:@"titleImageTechtitanhq.png"];
                    imageTitle = [[UIImageView alloc] initWithImage:titleImage];
                    self.navigationItem.titleView = imageTitle;
                    break;
               case ConfigPepsi:
                    
                    titleImage = [UIImage imageNamed:@"titleImagePepsi.png"];
                    imageTitle = [[UIImageView alloc] initWithImage:titleImage];
                    imageTitle.frame = CGRectMake(0, 0, 144, 44);
                    //self.navigationItem.titleView = imageTitle;
                    
                    imageTitle.contentMode = UIViewContentModeScaleAspectFit;
                    imageTitle.center = CGPointMake(self.navigationController.navigationBar.frame.size.width / 2.0, 22.0);
                    imageTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                    
                    [self.navigationController.navigationBar addSubview:imageTitle];
                    break;
               case ConfigAristo:
                    titleImage = [UIImage imageNamed:@"titleImageAristocrat.png"];
                    imageTitle = [[UIImageView alloc] initWithImage:titleImage];
                    self.navigationItem.titleView = imageTitle;
                    break;
                    /*EAOTitle*/
          }
     }
     
     // Configure our search bar
     [self configureSearchBar];
     
     // Make room for the toolbar
     [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
     
     self.navigationItem.titleView.contentMode = UIViewContentModeScaleAspectFit;
     
     // Display the favorites button on the top right
     [self.listViewController showFavoritesButton:self];
     
     // Solves an edge case dealing with categories not always loading
     if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && self.listViewController.viewControllers.count == 1) {
          [self viewWillAppear:NO];
     }
     
     // Be explicit for iOS 7
     self.tableView.backgroundColor = [UIColor whiteColor];
     
     // Only needed for iOS 7 + iPhone
     if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
          self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y
                                            , self.tableView.frame.size.width, self.tableView.frame.size.height + self.tabBarController.tabBar.frame.size.height);
          
     }
     
     self.tableView.rowHeight = 43.5;
     
}

- (void)configureSearchBar {
     if ([Config currentConfig].scanner) {
          self.searchBar.placeholder = NSLocalizedString(@"Search or Scan", nil);
          self.scannerIcon.hidden = NO;
     } else {
          self.searchBar.placeholder = NSLocalizedString(@"Search", nil);
          self.scannerIcon.hidden = YES;
     }
     
     // Fix for iOS 8, without this, the search bar and scope bar won't show up
     [self.searchBar sizeToFit];
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
     // Bail early if viewing iFixit from within the Dozuki app
     if ([[Config currentConfig].siteData[@"name"] isEqualToString:@"ifixit"]) {
          return;
     }
     
     UIImageView *imageTitle = [[UIImageView alloc] init];
     imageTitle.contentMode = UIViewContentModeScaleAspectFit;
     [imageTitle setImageWithURL:[NSURL URLWithString:URL]];
     
     self.navigationItem.titleView = imageTitle;
     
     [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
}

- (void)presentTransparentNavigationBar
{
     //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Default"] forBarMetrics:UIBarMetricsDefault];
     [self.navigationController.navigationBar setBarTintColor:[Config currentConfig].navBarColor];
     self.navigationController.navigationItem.title = @"";
     //     [self.navigationController.navigationBar setTranslucent:YES];
     //     [self.navigationController.navigationBar setShadowImage:[UIImage new]];
     //     [self.navigationController setNavigationBarHidden:NO animated:YES];
     //   self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
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
     if (!areas[@"hierarchy"]) {
          [self showRefreshButton];
          [iFixitAPI displayLoggedOutErrorAlert:self];
     }
     
     if ([areas[@"hierarchy"] allKeys].count) {
          // Save a master category list to a singleton if it hasn't
          // been created yet
          if (![CategoriesSingleton sharedInstance].masterCategoryList) {
               [CategoriesSingleton sharedInstance].masterCategoryList = areas[@"hierarchy"];
          }
          
          if (![CategoriesSingleton sharedInstance].masterDisplayTitleList) {
               [CategoriesSingleton sharedInstance].masterDisplayTitleList = areas[@"display_titles"];
          }
          
          [self setData:areas[@"hierarchy"]];
          [self.tableView reloadData];
          [self.listViewController showFavoritesButton:self];
     } else {
          // If there is no area hierarchy, show a guide list instead
          if ([areas[@"hierarchy"] isKindOfClass:[NSArray class]] && ![areas count]) {
               iPhoneDeviceViewController *dvc = [[iPhoneDeviceViewController alloc] initWithTopic:nil];
               [self.navigationController pushViewController:dvc animated:YES];
               [dvc release];
          }
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
               case ConfigMjtrim:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 75;
                    frame.size.height = 24;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigAccustream:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 95.0;
                    frame.size.height = 44.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigHyperthermToolkit:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 95.0;
                    frame.size.height = 44.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigMagnolia:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 257.0;
                    frame.size.height = 70.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigComcast:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 257.0;
                    frame.size.height = 30.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigDripAssist:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 257.0;
                    frame.size.height = 30.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigPva:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 257.0;
                    frame.size.height = 30.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigOscaro:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 257.0;
                    frame.size.height = 30.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigPepsi:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 257.0;
                    frame.size.height = 30.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigTechtitanhq:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 257.0;
                    frame.size.height = 30.0;
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
               case ConfigMjtrim:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 137;
                    frame.size.height = 35;
                    self.navigationItem.titleView.frame = frame;
                    break;
                    
               case ConfigHyperthermToolkit:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 157.0;
                    frame.size.height = 55.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigAccustream:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 157.0;
                    frame.size.height = 55.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigMagnolia:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 157;
                    frame.size.height = 65.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigComcast:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 157.0;
                    frame.size.height = 40.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigDripAssist:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 157.0;
                    frame.size.height = 40.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigPva:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 157.0;
                    frame.size.height = 40.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigOscaro:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 157.0;
                    frame.size.height = 40.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigPepsi:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = self.view.frame.size.width;
                    frame.size.height = 40.0;
                    self.navigationItem.titleView.frame = frame;
                    break;
               case ConfigTechtitanhq:
                    frame = self.navigationItem.titleView.frame;
                    frame.size.width = 157.0;
                    frame.size.height = 40.0;
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
     // If the user is about to search for something, let's sn
     if (self.tableView.decelerating) {
          [self.tableView scrollToRowAtIndexPath:self.tableView.indexPathsForVisibleRows[0]
                                atScrollPosition:UITableViewScrollPositionNone
                                        animated:NO
           ];
     }
     
     
     [self enableSearchView:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
     
     [searchBar setShowsCancelButton:NO animated:YES];
     [self enableSearchView:NO];
     
     if ([theSearchBar.text isEqual:@""]) {
          noResults = NO;
          [self.tableView reloadData];
     }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar {
     searchBar.text = @"";
     noResults = NO;
     [self enableSearchView:NO];
     [self.view endEditing:YES];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
     NSString *scopeFilter = self.searchBar.scopeButtonTitles[selectedScope];
     
     if (self.searchBar.text.length && ![self.searchResults[scopeFilter] count]) {
          NSString *filter = self.searchBar.selectedScopeButtonIndex == 0 ? @"guide,teardown" : @"category";
          [[iFixitAPI sharedInstance] getSearchResults:self.searchBar.text withFilter:filter forObject:self withSelector:@selector(gotSearchResults:)];
     } else {
          [self.tableView reloadData];
     }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
     
     // Let the user input text if they are under the char limit or trying to delete text
     return (searchBar.text.length <= 128 || [text isEqualToString:@""]);
}

- (NSString*)getFilter {
     return (searchBar.selectedScopeButtonIndex == 0) ? @"guide,teardown" : @"category";
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
     
     if ([searchText isEqual:@""]) {
          self.searching = NO;
          noResults = NO;
          [self.tableView reloadData];
          return;
     }
     
     if (!self.searching) {
          self.searching = YES;
     }
     
     if (searchText.length <= 3) {
          [[iFixitAPI sharedInstance] getSearchResults:searchText withFilter:[self getFilter] forObject:self withSelector:@selector(gotSearchResults:)];
     } else {
          [self performSelector:@selector(throttle:) withObject:searchText afterDelay:0.3];
     }
     
}

- (void)throttle:(NSString *)searchText {
     if ([searchText isEqualToString:self.searchBar.text]) {
          [[iFixitAPI sharedInstance] getSearchResults:searchText withFilter:[self getFilter] forObject:self withSelector:@selector(gotSearchResults:)];
     }
}

- (void)gotSearchResults:(NSDictionary *)results {
     NSString *filter = self.searchBar.scopeButtonTitles[self.searchBar.selectedScopeButtonIndex];
     
     if ([results[@"search"] isEqualToString:self.searchBar.text]) {
          [searchResults removeAllObjects];
          self.currentSearchTerm = self.searchBar.text;
          searchResults[filter] = [results objectForKey:@"results"];
          noResults = ([searchResults[filter] count] == 0);
          [self.tableView reloadData];
          
          NSDictionary *gaInfo = [[GAIDictionaryBuilder createEventWithCategory:@"Search" action:@"query" label:[NSString stringWithFormat:@"User searched for: %@", results[@"search"]] value:nil] build];
          [[[GAI sharedInstance] defaultTracker] send:gaInfo];
     }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
     
     Reachability *reachability = [Reachability reachabilityForInternetConnection];
     NetworkStatus internetStatus = [reachability currentReachabilityStatus];
     
     if (internetStatus == NotReachable) {
          [iFixitAPI displayConnectionErrorAlert];
     }
     
     [self.view endEditing:YES];
}

// Helper function for devices older than 7.0 to help with odd UI rotation issues when using the search bar
- (void)repositionFramesForLegacyDevices:(double)navigationBarHeight searchEnabled:(BOOL)enabled {
     self.view.frame = CGRectMake(0, enabled ? -navigationBarHeight : 0, self.view.frame.size.width, self.view.frame.size.height);
     self.navigationController.navigationBar.bounds = CGRectMake(0, 0, self.navigationController.navigationBar.bounds.size.width,
                                                                 enabled ? 0 : navigationBarHeight
                                                                 );
     
}

- (void)enableSearchView:(BOOL)option {
     [searchBar setShowsCancelButton:option animated:YES];
     
     [UIView transitionWithView:self.tableView
                       duration:0.2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                          self.tableView.transform = option ? CGAffineTransformMakeTranslation(0, [Config currentConfig].scanner ? 88 : 44) : CGAffineTransformIdentity;
                     } completion:nil
      ];
     
     
     
     // Only on iPhone do we want to make more room
     if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
          
          // On iOS 7 we can simply move the whole view frame and take advantage of sexy animations
          if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
               double statusBarHeight = 20;
               [UIView beginAnimations:@"search" context:nil];
               [UIView setAnimationDuration:0.3];
               self.view.frame = CGRectMake(0,
                                            option ? statusBarHeight :
                                            (self.navigationController.navigationBar.frame.size.height + statusBarHeight), self.view.frame.size.width, self.view.frame.size.height
                                            );
               
               [UIView commitAnimations];
               // Older devices are a bit more complicated, we have to essentially remove the navigation bar bounds temporarily
          } else {
               double navigationBarHeightForPortrait = 44.0;
               double navigationBarHeightForLandscape = 32.0;
               UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
               
               
               [self repositionFramesForLegacyDevices:UIDeviceOrientationIsPortrait(interfaceOrientation)
                ? navigationBarHeightForPortrait : navigationBarHeightForLandscape
                                        searchEnabled:option];
          }
          
          [self.navigationController.navigationBar setHidden:option];
          self.listViewController.favoritesButton.enabled = !option;
     }
     
     // Toggle the favorites button
     [UIView transitionWithView:self.scannerIcon
                       duration:option ? 0 : 0.4
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                          self.scannerIcon.hidden = [Config currentConfig].scanner && !self.searching ? option : YES;
                     } completion:nil
      ];
     
     searchViewEnabled = option;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
     if (searchViewEnabled) {
          [self.view endEditing:YES];
          [self enableSearchView:NO];
     }
}

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
     return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
     // Make room for the toolbar
     if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
          self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
          self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 60, 0);
     }
     
     // Reset the searching view offset to prevent rotating weirdness.
     if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
          CGRect bounds = self.navigationController.view.bounds;
          bounds.origin.y = 0.0;
          self.navigationController.view.bounds = bounds;
     }
     
     [[UIApplication sharedApplication] setStatusBarOrientation:toInterfaceOrientation animated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (void)setData:(NSDictionary *)dict {
     self.categoryResults = dict;
     self.categories = [self parseCategories:dict];
     self.categoryTypes = [NSMutableArray arrayWithArray:[[self.categories allKeys] sortedArrayUsingSelector:@selector(compare:)]];
}

- (NSMutableDictionary*)parseCategories:(NSDictionary *)categoriesCollection {
     NSMutableArray *categories = [[[NSMutableArray alloc] init] autorelease];
     NSMutableArray *devices = [[[NSMutableArray alloc] init] autorelease];
     NSMutableDictionary *allCategories = [[[NSMutableDictionary alloc] init] autorelease];
     NSDictionary *categoryDisplayTitles = [[[NSDictionary alloc]
                                             initWithDictionary:[CategoriesSingleton sharedInstance].masterDisplayTitleList]
                                            autorelease];
     
     // Bail early, we are working with a category with no children
     if ([categoriesCollection isEqual:[NSNull null]]) {
          return allCategories;
     }
     
     // Split categories from devices for iFixit and create key-value objects in the process
     for (id category in categoriesCollection) {
          if (categoriesCollection[category] != [NSNull null]) {
               [categories addObject:@{@"name" : category,
                                       @"display_title" : categoryDisplayTitles[category] ?
                                       categoryDisplayTitles[category] : category,
                                       @"type" : @(CATEGORY)
                                       }];
          } else {
               [devices addObject:@{@"name" : category,
                                    @"display_title" : categoryDisplayTitles[category] ?
                                    categoryDisplayTitles[category] : category,
                                    @"type" : @(DEVICE)
                                    }];
          }
     }
     
     // Sort categories and devices alphabetically
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
          else if (categories.count)
               allCategories[CATEGORIES] = categories;
     }
     
     return allCategories;
}

// Custom sort for our category objects, sort by alphabetical order
- (NSMutableArray*)sortCategories:(NSMutableArray*)categories {
     // Sort by alphabetical order
     return [NSMutableArray arrayWithArray:[categories sortedArrayUsingComparator:^NSComparisonResult(id category1, id category2) {
          return [category1[@"display_title"] compare:category2[@"display_title"] options:NSCaseInsensitiveSearch];
     }]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
     if (self.searching) {
          return 1;
     }
     NSLog(@"categories %d",self.categoryTypes.count);
     return self.categoryTypes.count;
}
- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
     return 40.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
     if ([self.categories[self.categoryTypes[section]] count] == 0) {
          UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
          return view;
     }
     UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
     /* Create custom view to display section header... */
     [view setBackgroundColor:[UIColor redColor]];
     UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, tableView.frame.size.width, 20)];
     label.font = [UIFont fontWithName:@"MuseoSans-500" size:18.0];
     //[label setFont:[UIFont boldSystemFontOfSize:14]];
     [label setTextColor:[UIColor whiteColor]];
     NSString *string =(section==0)?NSLocalizedString(@"Categories", nil):((section==1)?NSLocalizedString(@"Guides", nil):NSLocalizedString(@"Wikis", nil));//[list objectAtIndex:section];
     
     /* Section header is in 0th index... */
     [label setText:string];
     [view addSubview:label];
     [view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:28/255.0 blue:0/255.0 alpha:1.0]]; //your background color...
     
     UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
     imageView.image = [UIImage imageNamed:(section==0)?@"GuidesSection":((section==1)?@"CategoriesSection":@"WikisSection")];
     
     [view addSubview:imageView];
     return view;
}
/*
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 if (self.searching) {
 NSString *string = self.searchBar.scopeButtonTitles[self.searchBar.selectedScopeButtonIndex];
 return NSLocalizedString(string, nil);
 }
 
 return NSLocalizedString([self.categoryTypes[section] capitalizedString], nil);
 }*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     
     if (self.searching) {
          NSString *filter = self.searchBar.scopeButtonTitles[self.searchBar.selectedScopeButtonIndex];
          if ([searchResults[filter] count]) {
               return [searchResults[filter] count];
          } else if (noResults) {
               return 1;
          } else {
               return 0;
          }
          
     }
     
     return [self.categories[self.categoryTypes[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     
     static NSString *cellIdentifier;
     id cell;
     
     // If searching, create the cell and bail early
     if (self.searching) {
          NSString *filter = self.searchBar.scopeButtonTitles[self.searchBar.selectedScopeButtonIndex];
          cellIdentifier = @"SearchCell";
          cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
          
          if (cell == nil) {
               cell = [[[SearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
          }
          
          if ([searchResults[filter] count] > 0) {
               NSDictionary *result = [[[NSDictionary alloc] init] autorelease];
               result = searchResults[filter][indexPath.row];
               
               if ([result[@"dataType"] isEqualToString:@"guide"]) {
                    [cell textLabel].text = result[@"title"];
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
               } else {
                    [cell textLabel].text = result[@"display_title"];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
               }
          } else {
               [cell textLabel].text = NSLocalizedString(@"No Results Found", nil);
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
          [[cell textLabel] setText:category[@"display_title"]];
          
     } else {
          cellIdentifier = @"GuideCell";
          cell = (GuideCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
          
          if (cell == nil) {
               cell = [[[GuideCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
          }
          
          [cell setAccessoryType:UITableViewCellAccessoryNone];
          
          NSString *thumbnailImage = category[@"image"] == [NSNull null] ? nil : category[@"image"][@"thumbnail"];
          
          [[cell imageView] setImageWithURL:[NSURL URLWithString:thumbnailImage] placeholderImage:[UIImage imageNamed:@"WaitImage.png"]];
          
          [[cell textLabel] setText:category[@"name"]];
          [[cell textLabel] setMinimumFontSize:11.0f];
          [[cell textLabel] setAdjustsFontSizeToFitWidth:YES];
     }
     
     
     return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     Reachability *reachability = [Reachability reachabilityForInternetConnection];
     NetworkStatus internetStatus = [reachability currentReachabilityStatus];
     
     iFixitAppDelegate *appDelegate = (iFixitAppDelegate*)[UIApplication sharedApplication].delegate;
     NSString *filter = self.searchBar.scopeButtonTitles[self.searchBar.selectedScopeButtonIndex];
     
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
     [self.view endEditing:YES];
     
     if (self.searching && ![searchResults[filter] count]) {
          return;
     }
     
     NSDictionary *category = [[[NSDictionary alloc] init] autorelease];
     
     if (self.searching && [searchResults[filter] count]) {
          // If we are dealing with a guide we bail early
          if ([searchResults[filter][indexPath.row][@"dataType"] isEqualToString:@"guide"]) {
               [GuideLib loadAndPresentGuideForGuideid:searchResults[filter][indexPath.row][@"guideid"]];
               [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
               
               return;
          } else {
               category = @{@"name" : searchResults[filter][indexPath.row][@"title"],
                            @"type" : @(CATEGORY)
                            };
          }
     } else {
          category = self.categories[self.categoryTypes[indexPath.section]][indexPath.row];
     }
     
     // Category
     if (category[@"type"] == @(CATEGORY)) {
          CategoriesViewController *vc = [[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController" bundle:nil];
          //      vc.title = category[@"display_title"];
          vc.categoryMetaData = category;
          
          if (self.searching) {
               [self findChildCategoriesFromParent:category[@"name"]];
          }
          
          [vc setData:(self.searching) ? categorySearchResult : [self.categoryResults valueForKey:category[@"name"]]];
          
          [self.navigationController pushViewController:vc animated:YES];
          [vc.tableView reloadData];
          categorySearchResult = nil;
          [vc release];
          
          // Device
     } else if (category[@"type"] == @(DEVICE)) {
          if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
               iPhoneDeviceViewController *vc = [[iPhoneDeviceViewController alloc] initWithTopic:category[@"name"]];
               //           vc.title = category[@"display_title"];
               [self.navigationController pushViewController:vc animated:YES];
               [vc release];
          } else {
               self.categoryMetaData = category;
          }
          // Guide
     } else if (category[@"type"] == @(GUIDE)) {
          [GuideLib loadAndPresentGuideForGuideid:category[@"guideid"]];
          
          [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
          return;
     } else if (category[@"type"] == @(WIKI)) {
          [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
          NSString *url = [category[@"url"] isEqual:@""] ? @"http://www.dozuki.com" : category[@"url"];
          WikiVC *viewController = [[WikiVC alloc] initWithNibName:@"WikiVC" bundle:nil];
          viewController.url = url;
          [self.navigationController pushViewController:viewController animated:true];
          return;
     }
     
     [[iFixitAPI sharedInstance] getCategory:category[@"name"] forObject:self.listViewController.categoryTabBarViewController withSelector:@selector(gotCategoryResult:)];
     
     // Change the back button title to @"Home", only if we have 2 views on the stack
     if (self.navigationController.viewControllers.count == 2) {
          //       self.listViewController.navigationBar.backItem.title = NSLocalizedString(@"Home", nil);
     }
     
}

// Given a parent category, find the category and it's children
- (void)findChildCategoriesFromParent:(NSString*)parentCategory {
     // TODO: Check to see if the category is on the top level, if it isn't, then do recursion =/
     [self findCategory:parentCategory inList:[CategoriesSingleton sharedInstance].masterCategoryList];
}

// Recursive function to find the search result in our master category list
- (BOOL)findCategory:(NSString*)needle inList:(NSDictionary*)haystack {
     
     // Try to access the key first
     if ([[haystack allKeys] containsObject:needle]) {
          categorySearchResult = haystack[needle];
          return TRUE;
          // Key doesn't exist, we must go deeper
     } else {
          for (id category in haystack) {
               // We have another dictionary to look at, lets call ourselves
               if (haystack[category] != [NSNull null] && haystack[category] != nil) {
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
          guide[@"name"] = [guide[@"title"] isEqual:@""] ? NSLocalizedString(@"Untitled", nil) : guide[@"title"];
     }
}

// Massage the data to match our already gathered data
- (void)modifyTypesForWikis:(NSArray*)wikis {
     for (id wiki in wikis) {
          wiki[@"type"] = @(WIKI);
          wiki[@"name"] = [wiki[@"display_title"] isEqual:@""] ? NSLocalizedString(@"Untitled", nil) : wiki[@"display_title"];
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

// Add guides to the tableview if they exist
- (void)addWikisToTableView:(NSArray*)wikis {
     [self modifyTypesForWikis:wikis];
     
     // Begin the update
     [self.tableView beginUpdates];
     [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.categoryTypes.count] withRowAnimation:UITableViewRowAnimationFade];
     
     // Add the new guides to our category list
     [self.categories addEntriesFromDictionary:@{@"wikis": wikis}];
     
     // Add a new category type "wikis"
     [self.categoryTypes addObject:@"wikis"];
     
     // Donezo
     [self.tableView endUpdates];
}

- (IBAction)scannerViewTouched:(id)sender {
     
     ZBarReaderViewController *qrReader = [ZBarReaderViewController new];
     qrReader.readerDelegate = self;
     qrReader.supportedOrientationsMask = ZBarOrientationMaskAll;
     
     ZBarImageScanner *qrScanner = qrReader.scanner;
     [qrScanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
     
     iFixitAppDelegate *appDelegate = (iFixitAppDelegate*)[UIApplication sharedApplication].delegate;
     [appDelegate.window.rootViewController presentModalViewController:qrReader animated:YES];
     
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
     
     // Get the results from the reader
     id<NSFastEnumeration> results = info[ZBarReaderControllerResults];
     
     ZBarSymbol *symbol = nil;
     
     for (symbol in results) {
          // We only care about the first symbol we find
          break;
     }
     
     BOOL validUrl = [self openUrlFromScanner:symbol.data];
     
     [picker dismissViewControllerAnimated:YES completion:^{
          if (!validUrl) {
               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                   message:NSLocalizedString(@"Not a valid QR Code", nil)
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                         otherButtonTitles:nil, nil];
               [alertView show];
               [alertView release];
          }
     }];
     
     if (validUrl) {
          [self showLoading];
     }
}

- (void)gotGuide:(Guide*)guide {
     if (guide.iGuideid) {
          GuideViewController *guideViewController = [[GuideViewController alloc] initWithGuide:guide];
          UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:guideViewController];
          
          iFixitAppDelegate *appDelegate = (iFixitAppDelegate*)[UIApplication sharedApplication].delegate;
          [appDelegate.window.rootViewController presentModalViewController:navigationController animated:YES];
          
          [guideViewController release];
          [navigationController release];
     } else {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                              message:NSLocalizedString(@"Guide not found", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                    otherButtonTitles:nil, nil];
          [alertView show];
          [alertView release];
     }
     
     [self.listViewController showFavoritesButton:self];
}

// We want to look for the a valid category/device or guide URL
- (BOOL)openUrlFromScanner:(NSString*)url {
     NSError *error = nil;
     NSNumber *iGuideId = nil;
     
     NSRegularExpression *guideRegex = [NSRegularExpression regularExpressionWithPattern:@"(guide|teardown)/.+?/(\\d+)"
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:&error];
     NSRegularExpression *categoryRegex = [NSRegularExpression regularExpressionWithPattern:@"(device|c)\\/([^\\/]+)"
                                                                                    options:NSRegularExpressionCaseInsensitive
                                                                                      error:&error];
     NSArray *guideMatches = [guideRegex matchesInString:url
                                                 options:0
                                                   range:NSMakeRange(0, url.length)];
     
     NSArray *categoryMatches = [categoryRegex matchesInString:url
                                                       options:0
                                                         range:NSMakeRange(0, url.length)];
     
     if (guideMatches.count) {
          NSRange guideIdRange = [guideMatches[0] rangeAtIndex:2];
          NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
          iGuideId = [formatter numberFromString:[url substringWithRange:guideIdRange]];
          [formatter release];
          [[iFixitAPI sharedInstance] getGuide:iGuideId forObject:self withSelector:@selector(gotGuide:)];
          
          return YES;
     }
     
     if (categoryMatches.count) {
          NSRange categoryIdRange = [categoryMatches[0] rangeAtIndex:2];
          NSString *category = [url substringWithRange:categoryIdRange];
          [[iFixitAPI sharedInstance] getCategory:category forObject:self withSelector:@selector(gotCategoryResult:)];
          
          return YES;
     }
     
     return NO;
}

- (void)gotCategoryResult:(NSDictionary *)results {
     if (!results) {
          [iFixitAPI displayLoggedOutErrorAlert:self];
          return;
     }
     
     NSString *category = results[@"title"];
     [self findChildCategoriesFromParent:category];
     
     if (categorySearchResult) {
          CategoriesViewController *vc = [[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController" bundle:nil];
          
          vc.title = category;
          [vc setData:categorySearchResult];
          [self.navigationController pushViewController:vc animated:YES];
          [vc.tableView reloadData];
          
          if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone &&
              [self.listViewController.topViewController respondsToSelector:@selector
               (addGuidesToTableView:)] && [results[@"guides"] count]) {
                   [vc addGuidesToTableView:results[@"guides"]];
              }
          
          [vc release];
          
          categorySearchResult = nil;
          
          [self.listViewController.categoryTabBarViewController updateTabBar:results];
          [self.listViewController.categoryTabBarViewController showTabBar:YES];
     } else {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                              message:NSLocalizedString(@"Category not found", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                    otherButtonTitles:nil, nil];
          [alertView show];
          [alertView release];
     }
     
     [self.listViewController showFavoritesButton:self];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
     // Releases the view if it doesn't have a superview.
     [super didReceiveMemoryWarning];
     // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
     [self setScannerBarView:nil];
     [self setScannerIcon:nil];
     [self setTableView:nil];
     [super viewDidUnload];
     self.searchBar = nil;
     // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
     // For example: self.myOutlet = nil;
}

- (void)dealloc {
     [_scannerBarView release];
     [_scannerIcon release];
     [searchBar release];
     [searchResults release];
     [self.listViewController release];
     [self.categories release];
     [self.categoryTypes release];
     [self.categoryResults release];
     
     [_tableView release];
     [super dealloc];
}

@end
