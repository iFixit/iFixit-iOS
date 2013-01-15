//
//  iPhoneDeviceViewController.h
//  iFixit
//
//  Created by David Patierno on 9/15/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

@interface iPhoneDeviceViewController : UITableViewController <UIAlertViewDelegate> {
    BOOL loading;
}
    
@property (nonatomic, copy) NSString *topic;
@property (nonatomic, retain) NSArray *guides;

- (id)initWithTopic:(NSString *)topic;
- (void)getGuides;
- (void)showLoading;
- (void)createInfoButton;

@end
