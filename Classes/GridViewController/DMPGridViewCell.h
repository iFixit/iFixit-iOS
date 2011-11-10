//
//  DMPGridViewCell.h
//  DMPGridViewController
//
//  Created by David Patierno on 11/7/11.
//  Copyright (c) 2011. All rights reserved.
//

#import "DMPGridViewDelegate.h"

typedef enum {
    DMPGridViewCellStylePortrait1  = 0,
    DMPGridViewCellStylePortrait2  = 1,
    DMPGridViewCellStylePortrait3  = 2,
    DMPGridViewCellStylePortrait4  = 3,
    DMPGridViewCellStyleLandscape1 = 4,
    DMPGridViewCellStyleLandscape2 = 5,
    DMPGridViewCellStyleLandscape3 = 6,
    DMPGridViewCellStyleLandscape4 = 7
} DMPGridViewCellStyle;

@interface DMPGridViewCell : UIView

@property (nonatomic) DMPGridViewCellStyle style;
@property (nonatomic) NSUInteger index;
@property (nonatomic, assign) id<DMPGridViewDelegate> delegate;

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *textLabel;

+ (NSUInteger)cellsPerRowForStyle:(DMPGridViewCellStyle)style;
- (id)initWithStyle:(DMPGridViewCellStyle)style index:(NSUInteger)index;
- (void)setupView;

@end
