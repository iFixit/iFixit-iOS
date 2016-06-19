//
//  LoginViewControllerDelegate.h
//  iFixit
//
//  Created by David Patierno on 5/26/11.
//  Copyright 2011 iFixit. All rights reserved.
//

@protocol LoginViewControllerDelegate <NSObject>

- (void)refresh;
- (void)presentViewController:(UIViewController *  _Nonnull)viewController animated:(BOOL)animated completion:(void (^ _Nullable)(void))completion;

@end
