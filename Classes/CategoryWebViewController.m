//
//  CategoryWebViewController.m
//  iFixit
//
//  Created by Stefan Ayala on 5/29/13.
//
//

#import "CategoryWebViewController.h"
#import "Utils.h"
#import "ListViewController.h"
#import "BookmarksViewController.h"
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_webView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [Utils showLoading:self.navigationItem];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.navigationItem.rightBarButtonItem = nil;
    [self.listViewController showFavoritesButton:self];
}

@end
