//
//  SSOViewController.h
//  iFixit
//
//  Created by David Patierno on 2/12/12.
//  Copyright (c) 2012 iFixit. All rights reserved.
//

#import "SVWebViewController.h"

#import "LoginViewControllerDelegate.h"

@interface SSOViewController : SVWebViewController <UIAlertViewDelegate>
@property (nonatomic, assign) id<LoginViewControllerDelegate> delegate;
+ (id)viewControllerForURL:(NSString *)url delegate:(id<LoginViewControllerDelegate>)delegate;
@end
