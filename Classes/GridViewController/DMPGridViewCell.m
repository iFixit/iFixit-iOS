//
//  DMPGridViewCell.m
//  DMPGridViewController
//
//  Created by David Patierno on 11/7/11.
//  Copyright (c) 2011. All rights reserved.
//

#import "DMPGridViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation DMPGridViewCell

@synthesize style = _style, index = _index, delegate = _delegate;
@synthesize imageView = _imageView, textLabel = _textLabel;

+ (NSUInteger)cellsPerRowForStyle:(DMPGridViewCellStyle)style {
    NSUInteger result = 0;
    
    switch (style) {
        case DMPGridViewCellStylePortrait1:
            result = 2;
            break;
        case DMPGridViewCellStylePortrait2:
            result = 2;
            break;
        case DMPGridViewCellStylePortrait3:
            result = 2;
            break;
        case DMPGridViewCellStylePortrait4:
            result = 3;
            break;
        case DMPGridViewCellStyleLandscape1:
            result = 3;
            break;
        case DMPGridViewCellStyleLandscape2:
            result = 2;
            break;
        case DMPGridViewCellStyleLandscape3:
            result = 3;
            break;
        case DMPGridViewCellStyleLandscape4:
            result = 3;
            break;
        case DMPGridViewCellStylePortraitColumns:
            result = 2;
            break;
        case DMPGridViewCellStyleLandscapeColumns:
            result = 2;
            break;
    }
    
    return result;
}

- (CGRect)pickFrame {
    CGRect frame;
    
    switch (_style) {
        case DMPGridViewCellStylePortrait1:
            switch (_index) {
                case 0: frame = CGRectMake( 10.0, 10.0, 300.0, 225.0); break;
                case 1: frame = CGRectMake(320.0, 10.0, 440.0, 225.0); break;
            }
            break;
        case DMPGridViewCellStylePortrait2:
            switch (_index) {
                case 0: frame = CGRectMake( 10.0, 10.0, 440.0, 225.0); break;
                case 1: frame = CGRectMake(460.0, 10.0, 300.0, 225.0); break;
            }
            break;
        case DMPGridViewCellStylePortrait3:
            switch (_index) {
                case 0: frame = CGRectMake( 10.0, 10.0, 370.0, 225.0); break;
                case 1: frame = CGRectMake(390.0, 10.0, 370.0, 225.0); break;
            }
            break;
        case DMPGridViewCellStylePortrait4:
            switch (_index) {
                case 0: frame = CGRectMake( 10.0, 10.0, 243.0, 225.0); break;
                case 1: frame = CGRectMake(263.0, 10.0, 243.0, 225.0); break;
                case 2: frame = CGRectMake(516.0, 10.0, 244.0, 225.0); break;
            }
            break;
        case DMPGridViewCellStyleLandscape1:
            switch (_index) {
                case 0: frame = CGRectMake( 10.0, 10.0, 280.0, 225.0); break;
                case 1: frame = CGRectMake(300.0, 10.0, 424.0, 225.0); break;
                case 2: frame = CGRectMake(734.0, 10.0, 280.0, 225.0); break;
            }
            break;
        case DMPGridViewCellStyleLandscape2:
            switch (_index) {
                case 0: frame = CGRectMake( 10.0, 10.0, 497.0, 225.0); break;
                case 1: frame = CGRectMake(517.0, 10.0, 497.0, 225.0); break;
            }
            break;
        case DMPGridViewCellStyleLandscape3:
            switch (_index) {
                case 0: frame = CGRectMake( 10.0, 10.0, 328.0, 225.0); break;
                case 1: frame = CGRectMake(348.0, 10.0, 328.0, 225.0); break;
                case 2: frame = CGRectMake(686.0, 10.0, 328.0, 225.0); break;
            }
            break;
        case DMPGridViewCellStyleLandscape4:
            switch (_index) {
                case 0: frame = CGRectMake( 10.0, 10.0, 328.0, 225.0); break;
                case 1: frame = CGRectMake(348.0, 10.0, 328.0, 225.0); break;
                case 2: frame = CGRectMake(686.0, 10.0, 328.0, 225.0); break;
            }
            break;
            
        case DMPGridViewCellStylePortraitColumns:
            switch (_index) {
                case 0: frame = CGRectMake( 10.0, 10.0, 369.0, 225.0); break;
                case 1: frame = CGRectMake(389.0, 10.0, 369.0, 225.0); break;
            }
            break;
        case DMPGridViewCellStyleLandscapeColumns:
            switch (_index) {
                case 0: frame = CGRectMake( 10.0, 10.0, 337.0, 225.0); break;
                case 1: frame = CGRectMake(357.0, 10.0, 337.0, 225.0); break;
            }
            break;
        default:
            frame = CGRectMake(10.0, 10.0, 300.0, 225.0);
            break;
    }
    return frame;
}

- (id)initWithStyle:(DMPGridViewCellStyle)style index:(NSUInteger)index {
    if ((self = [super init])) {
        _style = style;
        _index = index;

        self.frame = [self pickFrame];
        [self setupView];
        
        // Add a drop shadow.
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        self.layer.shadowRadius = 6.0;
        self.layer.shadowOpacity = 1;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath; 
    }
    return self;
}

- (void)setupView {    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    // Image
    self.imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)] autorelease];
    _imageView.backgroundColor = [UIColor whiteColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
    
    // Title
    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 175.0, width, 50.0)];
    overlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    self.textLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, width - 20.0, 40.0)] autorelease];
    _textLabel.font = [UIFont boldSystemFontOfSize:16.0];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.backgroundColor = [UIColor clearColor];
    [overlayView addSubview:_textLabel];
    [self addSubview:overlayView];
    [overlayView release];
}

- (void)dealloc {
    [_imageView release];
    [_textLabel release];
    [super dealloc];
}

@end
