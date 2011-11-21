//
//  DetailIntroViewController.h
//  iFixit
//
//  Created by David Patierno on 11/18/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//


@interface DetailIntroViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIImageView *image;
@property (retain, nonatomic) IBOutlet UIImageView *text;
@property (nonatomic) UIInterfaceOrientation orientationOverride;

- (void)positionImages;

@end
