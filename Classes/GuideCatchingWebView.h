//
//  GuideCatchingWebView.h
//  iFixit
//
//  Created by David Patierno on 4/21/11.
//  Copyright 2011 iFixit. All rights reserved.
//

@interface GuideCatchingWebView : UIWebView <UIWebViewDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) id<UIWebViewDelegate> externalDelegate;
@property (nonatomic, retain) NSNumberFormatter *formatter;
@property (nonatomic, retain) NSURL *externalURL;
@property (nonatomic, assign) UIViewController *modalDelegate;
@property (nonatomic) BOOL linksOpenInSameWindow;

@end
