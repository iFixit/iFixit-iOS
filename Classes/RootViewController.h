//
//  RootViewController.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface RootViewController : UITableViewController {
    id delegate;
    DetailViewController *detailViewController;
	NSMutableDictionary *tree;
	NSArray *keys;
	NSArray *leafs;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) NSMutableDictionary *tree;
@property (nonatomic, retain) NSArray *keys;
@property (nonatomic, retain) NSArray *leafs;

- (void)setData:(NSDictionary *)dict;

@end
