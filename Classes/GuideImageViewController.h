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
#import "SDWebImage/UIImageView+WebCache.h"

@interface GuideImageViewController : UIViewController <UIScrollViewDelegate, TapDetectingImageViewDelegate> {
	BOOL doubleTap;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) UIScrollView *imageScrollView;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSDate *delay;

+ (id)zoomWithUIImage:(UIImage *)image delegate:(id)delegate;
- (void)setupTouchEvents:(UIImageView *)imageView;

@end
