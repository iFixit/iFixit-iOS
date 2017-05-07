//
//  WikiVC.h
//  iFixit
//
//  Created by Robert Pascazio on 5/6/17.
//
//

#import <UIKit/UIKit.h>

@interface WikiVC : UIViewController

@property (retain, nonatomic) IBOutlet UIWebView *webView;

@property (assign, nonatomic) NSString *url;

@end
