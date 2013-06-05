//
//  CategoryWebViewController.h
//  iFixit
//
//  Created by Stefan Ayala on 5/29/13.
//
//

#import <UIKit/UIKit.h>

@interface CategoryWebViewController : UIViewController <UIWebViewDelegate>

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) NSString *webViewType;
@property (retain, nonatomic) NSString *category;

@end
