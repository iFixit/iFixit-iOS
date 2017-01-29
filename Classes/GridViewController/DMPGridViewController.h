//
//  DMPGridViewController.h
//  DMPGridViewController
//
//  Created by David Patierno on 11/7/11.
//  Copyright (c) 2011. All rights reserved.
//

#import "DMPGridViewDelegate.h"

@interface DMPGridViewController : UITableViewController

@property (nonatomic, assign) id<DMPGridViewDelegate> delegate;

- (id)initWithDelegate:(id<DMPGridViewDelegate>)delegate;

@end
