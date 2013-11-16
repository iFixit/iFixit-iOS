//
//  SearchCell.m
//  iFixit
//
//  Created by Stefan Ayala on 11/16/13.
//
//

#import "SearchCell.h"

@implementation SearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self textLabel].font = [UIFont systemFontOfSize:14.0];
        [self textLabel].minimumFontSize = 7.0;
        [self textLabel].numberOfLines = 2;
        [self textLabel].adjustsFontSizeToFitWidth = YES;
    }

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
