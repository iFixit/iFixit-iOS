//
//  CategoryWebViewController.h
//  iFixit
//
//  Created by Stefan Ayala on 5/29/13.
//
//

#import <UIKit/UIKit.h>
#import "WBProgressHUD.h"

@class ListViewController;
@class CategoryTabBarViewController;

@interface CategoryWebViewController : UIViewController <UIWebViewDelegate>

@property (retain, nonatomic) IBOutlet UIBarButtonItem *favoritesButton;
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) WBProgressHUD *loading;
@property (retain, nonatomic) NSString *webViewType;
@property (retain, nonatomic) NSString *category;
@property (retain, nonatomic) IBOutlet UINavigationBar *categoryNavigationBar;

@property (retain, nonatomic) ListViewController *listViewController;
@property (retain, nonatomic) CategoryTabBarViewController *categoryTabBarViewController;


- (void)configureProperties;
+ (NSString*)configureHtmlForWebview:(NSDictionary*)categoryMetaData;
    
@end
