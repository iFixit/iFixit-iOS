//
//  ThinDeviceViewController.h
//  iFixit
//
//  Created by David Patierno on 4/20/11.
//  Copyright 2011 iFixit. All rights reserved.
//

@class GuideCatchingWebView;
@class WBProgressHUD;

@interface ThinDeviceViewController : UIViewController <UIWebViewDelegate> {
    GuideCatchingWebView *webView;
    WBProgressHUD *loading;
    NSURL *startURL;
}

@property (nonatomic, retain) IBOutlet GuideCatchingWebView *webView;
@property (nonatomic, retain) WBProgressHUD *loading;
@property (nonatomic, retain) NSURL *startURL;

- (id)initWithURL:(NSURL *)url;

@end
