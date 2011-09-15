//
//  ListViewController.h
//  iFixit
//
//  Created by David Patierno on 3/24/11.
//  Copyright 2011. All rights reserved.
//


@interface ListViewController : UINavigationController {
    NSArray *allStack;
    UIViewController *bookmarksTVC;
}

@property (nonatomic, retain) NSArray *allStack;
@property (nonatomic, retain) UIViewController *bookmarksTVC;

@end
