//
//  CategoryWebViewController.m
//  iFixit
//
//  Created by Stefan Ayala on 5/29/13.
//
//

#import "CategoryWebViewController.h"
#import "ListViewController.h"
#import "BookmarksViewController.h"
#import "WBProgressHUD.h"
#import "Config.h"

@interface CategoryWebViewController ()

@end

@implementation CategoryWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewWillAppear:(BOOL)animated {
    // Only on iPhone do we want to have a nav bar with a title
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.categoryNavigationBar.topItem.title = self.category;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_webView release];
    [_categoryNavigationBar release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setWebView:nil];
    [self setCategoryNavigationBar:nil];
    [super viewDidUnload];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    // Hide any previous loading items
    [self.loading hide];
    
    // Hide the webview with a transition
    [UIView transitionWithView:self.webView
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.webView.hidden = YES;
                    }
                    completion:nil
     ];
    
    // Figure out the yCoord for the loading icon
    double yCoord = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 300.0 : 160.0;
    CGRect frame = CGRectMake(self.view.frame.size.width/ 2.0 - 60, yCoord, 120.0, 120.0);
    
    self.loading = [[[WBProgressHUD alloc] initWithFrame:frame] autorelease];
    self.loading.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.loading showInView:self.view];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIView transitionWithView:self.webView
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.webView.hidden = NO;
                        [self.loading hide];
                    }
                    completion:nil
    ];
}

- (void)configureProperties {
    // Only configure the nav bar on iPhone
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self configureNavigationBar];
    }
}

- (void)configureNavigationBar {
    self.categoryNavigationBar.tintColor = [Config currentConfig].toolbarColor;
    self.categoryNavigationBar.hidden = NO;
    
    UINavigationItem *backButtonItem = [[[UINavigationItem alloc] initWithTitle:@""] autorelease];
    UINavigationItem *titleItem = [[[UINavigationItem alloc] initWithTitle:@""] autorelease];
    UINavigationItem *favoritesButtonItem = self.categoryNavigationBar.items[0];
    
    favoritesButtonItem.title = NSLocalizedString(@"Favorites", nil);
    
    // Hack to get a back button, title view, and a right bar button item on a navigation bar without having to use a navigation controller
    self.categoryNavigationBar.items = @[backButtonItem, titleItem, favoritesButtonItem];
    self.categoryNavigationBar.delegate = self.categoryTabBarViewController;
}

- (IBAction)favoritesButtonPushed:(id)sender {
    BookmarksViewController *bvc = [[BookmarksViewController alloc] initWithNibName:@"BookmarksView" bundle:nil];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:bvc];
    
    // Use deprecated method on purpose to preserve iOS 4.3
    [self presentModalViewController:nvc animated:YES];
    
    [bvc release];
    [nvc release];
}

// Configure our html and load custom CSS for our More Info webview
+ (NSString*)configureHtmlForWebview:(NSDictionary*)categoryMetaData {
    // Load our css
    NSString *header = [NSString stringWithFormat:@"<html><head><style type=\"text/css\"> %@ </style></head><body>", [Config currentConfig].moreInfoCSS];
    NSString *footer = @"</body></html>";
    
    // Build our image tag that will display an image of the category we are looking at
    NSString *image = [categoryMetaData[@"image"] count] > 0
        ? [NSString stringWithFormat:@"<div id=\"categoryImage\"><img src=\"%@.standard\"></div>", categoryMetaData[@"image"][@"text"]]
        : @"";
    
    // Add our wiki content
    NSString *content = [NSString stringWithFormat:@"<div id=\"moreInfoContent\">%@</div>", categoryMetaData[@"contents"]];
    
    return [NSString stringWithFormat:@"%@%@%@%@", header, image, content, footer];
}

@end
