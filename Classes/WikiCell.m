//
//  WikiCell.m
//  iFixit
//
//  Created by Robert Pascazio on 5/6/17.
//
//

#import "WikiCell.h"

@interface WikiCell ()

@end

@implementation WikiCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_wikiImage release];
    [_wikiTitle release];
    [super dealloc];
}
@end
