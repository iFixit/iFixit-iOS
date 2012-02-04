//
//  LoginViewControllerDelegate.h
//  iFixit
//
//  Created by David Patierno on 5/26/11.
//  Copyright 2011 iFixit. All rights reserved.
//

@protocol LoginViewControllerDelegate <NSObject>

- (void)refresh;
- (void)presentModalViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
