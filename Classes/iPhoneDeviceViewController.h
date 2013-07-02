//
//  iPhoneDeviceViewController.h
//  iFixit
//
//  Created by David Patierno on 9/15/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

@class ListViewController;

@interface iPhoneDeviceViewController : UITableViewController <UIAlertViewDelegate> {
    BOOL loading;
}
    
@property (nonatomic, copy) NSString *topic;
@property (nonatomic, retain) NSArray *guides;
@property (nonatomic, retain) NSString *currentCategory;
@property (nonatomic, retain) NSString *moreInfoHTML;
@property (nonatomic, retain) NSDictionary *categoryMetaData;
@property (nonatomic, retain) ListViewController *listViewController;
@property (nonatomic, retain) NSArray *categoryGuides;

@property BOOL showAnswers;
@property BOOL showMoreInfo;

- (id)initWithTopic:(NSString *)topic;
- (void)getGuides;
- (void)showLoading;

@end
