//
//  CategoryTabBarViewController.m
//  iFixit
//
//  Created by Stefan Ayala on 6/20/13.
//
//

#import "CategoryTabBarViewController.h"
#import "Config.h"
#import "CategoriesViewController.h"
#import "CategoryWebViewController.h"
#import "iFixitAPI.h"
#import "GANTracker.h"
#import <QuartzCore/QuartzCore.h>

@interface CategoryTabBarViewController ()

@end

BOOL onTablet, initialLoad;

@implementation CategoryTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initializeProperties];
        [self initializeViewControllers];
        [self configureTabBar];
        [self buildTabBarConstants];
        [self buildTabBarItems];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    initialLoad = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Initialize our properties that will be used throughout the program
- (void)initializeProperties {
    onTablet = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    initialLoad = YES;
    
    // This is a hack built on top of a hack. We have a filler image we use when we hide the tabbar to avoid funky resizing issues of the view
    if (onTablet) {
        UIImageView *filler = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tabBar.frame.size.width, self.tabBar.frame.size.height)];
        filler.image = [UIImage imageNamed:@"concreteBackground.png"];
        [self.view addSubview:filler];
        
        self.toolBarFillerImage = filler;
        [filler release];
        
        self.browseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.browseButton setTitle:NSLocalizedString(@"Browse", nil) forState:UIControlStateNormal];
        [self.browseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.browseButton setBackgroundColor:[UIColor blackColor]];
        [self.browseButton addTarget:self action:@selector(browseButtonPushed) forControlEvents:UIControlEventTouchUpInside];
        
        self.browseButton.frame = CGRectMake(7, 5, 100, 34);
        self.browseButton.layer.cornerRadius = 10;
        self.browseButton.clipsToBounds = YES;
        [self.view.subviews[1] addSubview:self.browseButton];
        self.browseButton.hidden = YES;
    }
    
    self.delegate = self;
}

- (void)browseButtonPushed {
    [self.popOverController presentPopoverFromRect:self.browseButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)configureTabBar {
    // On iPad we move the tabbar to the top of the frame.
    if (onTablet) {
        self.tabBar.frame = CGRectMake(0, 324, 768, 44);
    } else {
        [self showTabBar:NO];
    }
}

- (void)configureTabBarFrame:(UIInterfaceOrientation)orientation {
    if (UIDeviceOrientationIsLandscape(orientation)) {
        self.tabBar.frame = CGRectMake(0, 255, [UIScreen mainScreen].bounds.size.width, 44);
    } else {
        // There is some terribly odd behavior with starting the app in portrait mode on initial load,
        // this deals with that by having custom frame logic only on initial load + Portrait.
        if (initialLoad) {
            self.tabBar.frame = CGRectMake(0, 69, [UIScreen mainScreen].bounds.size.width, 44);
        } else {
            self.tabBar.frame = CGRectMake(0, -256, [UIScreen mainScreen].bounds.size.width, 44);
        }
        
    }
}

// Dynamically build our tab bar constants which depends on our config settings.
- (void)buildTabBarConstants{
    // Set up constants
    if ([Config currentConfig].answersEnabled) {
        self.GUIDES = 0;
        self.ANSWERS = 1;
        self.MORE_INFO = 2;
    } else {
        self.GUIDES = 0;
        self.MORE_INFO = 1;
    }
}

// Build tab bar items and insert them into our tabbar
- (void)buildTabBarItems {
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    
    // If on a tablet, we initialize the guide layout as our first viewcontroller
    if (onTablet) {
        [viewControllers addObject:self.detailGridViewController];
        self.detailGridViewController.tabBarItem.title = NSLocalizedString(@"Guides", nil);
        self.detailGridViewController.tabBarItem.tag = self.GUIDES;
        self.detailGridViewController.tabBarItem.image = [UIImage imageNamed:@"guides"];
    } else {
        // On iPhone our first view controller is a navigation controller
        [viewControllers addObject:self.listViewController];
        self.listViewController.tabBarItem.title = NSLocalizedString(@"Guides", nil);
        self.listViewController.tabBarItem.tag = self.GUIDES;
        self.listViewController.tabBarItem.image = [UIImage imageNamed:@"guides"];
        // Create a reference that our navigation controller can use to access the tabbar controller easily
        self.listViewController.categoryTabBarViewController = self;
    }
    
    self.categoryMoreInfoViewController.tabBarItem.title = NSLocalizedString(@"More Info", nil);
    self.categoryMoreInfoViewController.tabBarItem.tag = self.MORE_INFO;
    self.categoryMoreInfoViewController.tabBarItem.image = [UIImage imageNamed:@"moreinfo"];
    
    // Not every site has answers enabled
    if ([Config currentConfig].answersEnabled) {
        self.categoryAnswersWebViewController.tabBarItem.title = NSLocalizedString(@"Answers", nil);
        self.categoryAnswersWebViewController.tabBarItem.tag = self.ANSWERS;
        self.categoryAnswersWebViewController.tabBarItem.image = [UIImage imageNamed:@"answers"];
        [viewControllers addObject:self.categoryAnswersWebViewController];
    }
    
    // Lastly add our moreInfoViewController, this maintains order and simplifies a lot of code.
    [viewControllers addObject:self.categoryMoreInfoViewController];
    
    self.tabBarViewControllers = viewControllers;
    [self setViewControllers:self.tabBarViewControllers animated:YES];
    [viewControllers release];
    
    // Disable our tabBarItems since we don't show it on the root view
    [self enableTabBarItems:NO];
    
    // iPad is wonky, we have to resize the subview since we are already doing hacky things, this is the path
    // of least resistance.
    if (onTablet) {
        [self.view.subviews[0] setFrame:CGRectMake(0, 44, [self.view.subviews[0] frame].size.width, [self.view.subviews[0] frame].size.height + 5)];
    }
}

- (void)hideTabBarItems:(BOOL)option {
    self.viewControllers = option ? nil : self.tabBarViewControllers;
}

- (void)showTabBar:(BOOL)option {
    [UIView transitionWithView:self.tabBar
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        // If on a tablet, we manipulate the opacity and show the filler image
                        // This is much more sane then removing the tabBar on iPad to avoid view manipulations
                        // and strange bugs.
                        if (onTablet) {
                            if (option) {
                                self.tabBar.alpha = 1.0;
                                self.toolBarFillerImage.alpha = 0.0;
                            } else {
                                self.tabBar.alpha = 0.0;
                                self.toolBarFillerImage.alpha = 1.0;
                            }
                        } else {
                            // We can get away with just hiding the tabBar on iPhone since we aren't doing
                            // anything crazy, ie: moving the tabbar from it's default position
                            self.tabBar.hidden = !option;
                            
                            // Resize the subview, it is sane to do this on an iPhone
                            [self configureSubViewFrame:0];
                        }
                    }
                    completion:nil
    ];
}

- (void)enableTabBarItems:(BOOL)option {
    [UIView transitionWithView:self.tabBar
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        if (onTablet) {
                            for (id tabBarItem in self.tabBar.items)
                                [tabBarItem setEnabled:option];
                        // Since iPhone will always have the guide tab enabled, we only want to
                        // manipulate the other tabBar Items
                        } else {
                            [self.tabBar.items[self.MORE_INFO] setEnabled:option];
                            
                            if ([Config currentConfig].answersEnabled) {
                                [self.tabBar.items[self.ANSWERS] setEnabled:option];
                            }
                        }
                    }
                    completion:nil
     ];
}

// Build references to our view controllers that will be used in our tabBar
- (void)initializeViewControllers {
    // Only create the references if we need to
    if (onTablet) {
        self.detailGridViewController = [[[DetailGridViewController alloc] init] autorelease];
    } else {
        self.categoriesViewController = [[[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController" bundle:nil] autorelease];
        self.listViewController = [[ListViewController alloc] initWithRootViewController:self.categoriesViewController];
    }
    
    self.categoryMoreInfoViewController = [self configureWebViewController:self.categoryMoreInfoViewController];
    
    // Answers isn't enabled for everyone
    if ([Config currentConfig].answersEnabled) {
        self.categoryAnswersWebViewController = [self configureWebViewController:self.categoryAnswersWebViewController];
        self.categoryAnswersWebViewController.webViewType = @"answers";
    }
}

// Configure our webViewControllers so they can be reused
- (CategoryWebViewController*)configureWebViewController:(id)viewController {
    viewController = [[CategoryWebViewController alloc] initWithNibName:@"CategoryWebViewController" bundle:nil];
    [viewController loadView];
    [viewController setCategoryTabBarViewController:self];
    [viewController configureProperties];
    
    return viewController;
}

// Configure our subview frame depending on what view we are looking at
- (void)configureSubViewFrame:(int)viewControllerIndex {
    id subView = self.view.subviews[0];
    CGRect bounds = self.view.bounds;
    
    // Tablet is tricky because we are already doing things we shouldn't be doing
    if (onTablet) {
        if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
            [subView setFrame:(viewControllerIndex == self.GUIDES)
                ? CGRectMake(0, 44, [subView frame].size.width, 655)
                : CGRectMake(0, 0, [subView frame].size.width, 746)];
        } else {
            [subView setFrame:(viewControllerIndex == self.GUIDES)
                ? CGRectMake(0, 44, [subView frame].size.width, 950)
                : CGRectMake(0, 0, [subView frame].size.width, 1005)];
        }
    // For iPhone we change the subview frame to account for hidden tabbar
    } else {
        [subView setFrame:(self.listViewController.viewControllers.count == 1)
            ? CGRectMake(0, 0, bounds.size.width, bounds.size.height + 44)
            : CGRectMake(0, 0, bounds.size.width, bounds.size.height - 2)];
    }
}

// Update the tab bar once we get more information about the category we are currently viewing
- (void)updateTabBar:(NSDictionary *)results {
    self.categoryMetaData = results;
    
    [UIView transitionWithView:self.tabBar
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        
                        // Only on a tablet can the Guides tab be enabled/disabled
                        if (onTablet)
                            [self.tabBar.items[self.GUIDES] setEnabled:[results[@"guides"] count] > 0];
                        
                        [self.tabBar.items[self.MORE_INFO] setEnabled:[results[@"contents"] length] > 0];
                        
                        if ([Config currentConfig].answersEnabled) {
                            [self.tabBar.items[self.ANSWERS] setEnabled:[results[@"solutions"][@"count"] integerValue] > 0];
                        }
                        
                        // Only on the tablet do we force an update to our tabBarSelection
                        if (onTablet)
                            [self updateTabBarSelection];
                    }
                    completion:nil
     ];
}

// Force a tab bar selection on the first item that is enabled
- (void)updateTabBarSelection {
    for (int i = 0; i < self.tabBar.items.count; i++) {
        // We only care about the first item that is enabled
        if ([self.tabBar.items[i] isEnabled]) {
            [self tabBar:self.tabBar didSelectItem:self.tabBar.items[i]];
            [self setSelectedIndex:i];
            
            // Don't show the noGuides Image if we found something
            [self.detailGridViewController showNoGuidesImage:NO];
            
            // Bail early if we got what we needed
            return;
        }
    }
    
    // If we get this far, it's because the category has no guides/answers/more-info.
    // In this case we disable all the tabBar items, force a selection to Guides index,
    // then show the noGuides image.
    [self enableTabBarItems:NO];
    [self setSelectedIndex:0];
    [self.detailGridViewController setCategory:nil];
    [self.detailGridViewController showNoGuidesImage:YES];
    [self configureSubViewFrame:self.GUIDES];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (onTablet)
        return true;
    else
        return tabBarController.selectedViewController != viewController;
}

// Delegate method, called when a tabBarItem is selected, or when I want to force a selection programatically
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag == self.selectedIndex && !onTablet) {
        return;
    }
    
    NSString *category = self.categoryMetaData[@"topic_info"][@"name"];
    
    if (item.tag == self.GUIDES) {
        if (![category isEqualToString:self.detailGridViewController.category])
            self.detailGridViewController.category = category;
    } else if (item.tag == self.MORE_INFO) {
        [self prepareWebViewController:self.categoryMoreInfoViewController fromTag:item.tag withCategory:category];
    } else {
        [self prepareWebViewController:self.categoryAnswersWebViewController fromTag:item.tag withCategory:category];
    }
    
    // Configure the subview frame to take into account the tabbar being moved to the top
    if (onTablet) {
        [self configureSubViewFrame:item.tag];
    }

    // Google Analytics
    [self recordAnalyticsEvent:item.tag withCategory:category];
}

// Google Analytics: record category and action
- (void)recordAnalyticsEvent:(int)event withCategory:(NSString*)category {
    
    // Bail early if we are just navigating through Guides
    if (event == self.GUIDES) {
        return;
    }
    
    NSString *eventType;
    
    if (event == self.MORE_INFO) {
        eventType = @"more info";
    } else if (event == self.ANSWERS) {
        eventType = @"answers";
    }
    
    [[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/category/%@", eventType] withError:NULL];
    [[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/category/%@/%@", eventType, category] withError:NULL];
}

// Prepare our webViewController before presenting it to the user
- (void)prepareWebViewController:(id)viewController fromTag:(int)tag withCategory:(NSString *)category {
    
    // Don't reload the page if we are looking at the current category
    if (![category isEqualToString:[viewController category]]) {
        // Empty the page
        [[viewController webView] stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
        
        // Our more info page needs to be configured
        if (tag == self.MORE_INFO) {
            [[viewController webView] loadHTMLString:[CategoryWebViewController configureHtmlForWebview:self.categoryMetaData] baseURL:nil];
        // Answers is a straight webview so no HTML manipulation is needed, just load the request
        } else {
            [[viewController webView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.categoryMetaData[@"solutions"][@"url"]]]];
        }
        
        [viewController setCategory:category];
        
        // Hack to create the back arrow on a Navigation bar that is not using a navigation controller
        // This is the most elegant solution sadly.
        if (!onTablet) {
            [[viewController categoryNavigationBar].items[1] setTitle:[self.listViewController.navigationBar.items[self.listViewController.navigationBar.items.count - 2] title]];
        }
    }
    
}

// Method is called when we get a response back from our API
- (void)gotCategoryResult:(NSDictionary *)results {
    if (!results) {
        [iFixitAPI displayConnectionErrorAlert];
        return;
    }
    
    [self showTabBar:YES];
    
    [self.listViewController.topViewController setCategoryMetaData:results];
    
    // Only on iPhone do we want to add a guides section to the tableView
    if (!onTablet && [self.listViewController.topViewController respondsToSelector:@selector(addGuidesToTableView:)] && [results[@"guides"] count] > 0) {
        // Add guides to our top level view controller's tableview
        [self.listViewController.topViewController addGuidesToTableView:results[@"guides"]];
    }
    
    [self updateTabBar:results];
}

// Override the default behavior of our navigation bar. This is only used for iPhone
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    
    // Select our guide tab bar item and pop a viewcontroller of the stack
    self.selectedIndex = self.GUIDES;
    [self.listViewController popViewControllerAnimated:YES];
    
    return NO;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    
    [self showTabBar:YES];
    [self configureTabBarFrame:UIInterfaceOrientationMaskPortrait];
    [self configureFistImageView:UIInterfaceOrientationMaskPortrait];
    
    if (self.listViewController.viewControllers.count == 1) {
        [self hideTabBarItems:YES];
    }
    
    self.popOverController = pc;
    self.browseButton.hidden = NO;
    self.detailGridViewController.orientationOverride = UIInterfaceOrientationPortrait;
    [self.detailGridViewController.tableView reloadData];
}

- (void)configureFistImageView:(UIInterfaceOrientation)orientation {
    UIImageView *fistImageView = self.detailGridViewController.fistImage;
    int yCoord = UIDeviceOrientationIsLandscape(orientation) ? 0 : 250;
    
    if (initialLoad)
        fistImageView.frame = CGRectMake(0, yCoord, [[UIScreen mainScreen] bounds].size.width, fistImageView.frame.size.height);
    else {
        [UIView transitionWithView:fistImageView
                          duration:0.3
                           options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            fistImageView.frame = CGRectMake(0, yCoord, [[UIScreen mainScreen] bounds].size.width, fistImageView.frame.size.height);
                        } completion:nil
         ];
    }
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    [self showTabBar:(self.listViewController.viewControllers.count > 1)];
    [self configureFistImageView:UIInterfaceOrientationLandscapeLeft];
    [self configureTabBarFrame:UIInterfaceOrientationLandscapeLeft];
    [self hideTabBarItems:NO];
    self.popOverController = nil;
    self.browseButton.hidden = YES;
    self.detailGridViewController.orientationOverride = UIInterfaceOrientationLandscapeLeft;
    [self.detailGridViewController.tableView reloadData];
}
@end
