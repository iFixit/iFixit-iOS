//
//  LoginBackgroundViewController.m
//  iFixit
//
//  Created by David Patierno on 2/13/12.
//  Copyright (c) 2012 iFixit. All rights reserved.
//

#import "LoginBackgroundViewController.h"

#import "Config.h"

@implementation LoginBackgroundViewController

- (void)viewDidLoad {
    UIColor *bgColor = [Config currentConfig].backgroundColor;
    if ([bgColor isEqual:[UIColor whiteColor]])
        bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"concreteBackgroundWhite.png"]];
    else
        bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"concreteBackground.png"]];
    self.view.backgroundColor = bgColor;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return YES;
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
