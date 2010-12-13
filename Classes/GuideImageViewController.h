//
//  GuideImageViewController.h
//  iFixit
//
//  Created by David Patierno on 8/14/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideImage.h"
#import "TapDetectingImageView.h"

@interface GuideImageViewController : UIViewController <UIScrollViewDelegate, TapDetectingImageViewDelegate> {
	id delegate;
    UIScrollView *imageScrollView;
	UIImage *image;
	BOOL doubleTap;
    NSDate *delay;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSDate *delay;

+ (id)initWithUIImage:(UIImage *)image;
- (void)setupTouchEvents:(UIImageView *)imageView;

@end
