//
//  SplashViewController.h
//  iFixit
//
//  Created by David Patierno on 12/19/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CachedImageLoader.h"


@interface SplashViewController : UIViewController <ImageConsumer> {
    NSArray *guides;
    
    UIButton *button1;
    UIButton *button2;
    UIButton *button3;
    UIButton *button4;
    UIButton *button5;
    UIButton *button6;
    UILabel *label1;
    UILabel *label2;
    UILabel *label3;
    UILabel *label4;
    UILabel *label5;
    UILabel *label6;
    NSInteger numImagesLoaded;
}

@property (nonatomic, retain) NSArray *guides;

@property (nonatomic, retain) IBOutlet UIButton* button1;
@property (nonatomic, retain) IBOutlet UIButton* button2;
@property (nonatomic, retain) IBOutlet UIButton* button3;
@property (nonatomic, retain) IBOutlet UIButton* button4;
@property (nonatomic, retain) IBOutlet UIButton* button5;
@property (nonatomic, retain) IBOutlet UIButton* button6;
@property (nonatomic, retain) IBOutlet UILabel* label1;
@property (nonatomic, retain) IBOutlet UILabel* label2;
@property (nonatomic, retain) IBOutlet UILabel* label3;
@property (nonatomic, retain) IBOutlet UILabel* label4;
@property (nonatomic, retain) IBOutlet UILabel* label5;
@property (nonatomic, retain) IBOutlet UILabel* label6;
@property (nonatomic) NSInteger numImagesLoaded;

- (IBAction)showGuide:(UIButton *)button;
- (IBAction)browseAll:(UIButton *)button;
- (void)startImageDownloads;

@end
