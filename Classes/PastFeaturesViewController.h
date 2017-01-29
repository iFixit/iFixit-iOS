//
//  PastFeaturesViewController.h
//  iFixit
//
//  Created by David Patierno on 11/7/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

#import "PastFeaturesViewDelegate.h"

@interface PastFeaturesViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *collections;
@property (nonatomic, retain) NSDateFormatter *dateFormat;
@property (nonatomic, assign) id<PastFeaturesViewDelegate> delegate;

@end
