//
//  OpenIDViewController.h
//  iFixit
//
//  Created by David Patierno on 2/4/12.
//  Copyright (c) 2012 iFixit. All rights reserved.
//

#import "SVWebViewController.h"

#import "LoginViewControllerDelegate.h"

@interface OpenIDViewController : SVWebViewController <UIAlertViewDelegate>
@property (nonatomic, assign) id<LoginViewControllerDelegate> delegate;
+ (id)viewControllerForHost:(NSString *)host delegate:(id<LoginViewControllerDelegate>)delegate;
@end
