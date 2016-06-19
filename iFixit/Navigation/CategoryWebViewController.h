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

@property (retain, nonatomic, nullable) IBOutlet UIBarButtonItem *favoritesButton;
@property (retain, nonatomic, nonnull) IBOutlet UIWebView *webView;
@property (retain, nonatomic, nullable) WBProgressHUD *loading;
@property (retain, nonatomic, nullable) NSString *webViewType;
@property (retain, nonatomic, nullable) NSString *category;
@property (retain, nonatomic, nonnull) IBOutlet UINavigationBar *categoryNavigationBar;

@property (retain, nonatomic, nullable) ListViewController *listViewController;
@property (retain, nonatomic, nullable) CategoryTabBarViewController *categoryTabBarViewController;


- (void)configureProperties;
+ (NSString* _Nullable)configureHtmlForWebview:(NSDictionary*  _Nonnull)categoryMetaData;
    
@end
