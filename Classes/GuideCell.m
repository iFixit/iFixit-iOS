//
//  GuideCell.m
//  iFixit
//
//  Created by David Patierno on 9/15/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

#import "GuideCell.h"

@implementation GuideCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.textLabel.font = [UIFont systemFontOfSize:14.0];
        self.textLabel.minimumFontSize = 7.0;
        self.textLabel.numberOfLines = 2;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.imageView.frame = CGRectMake(5.0, 5.0, 48.0, 36.0);
}

- (void)displayLanguage:(NSString*)languageId {
     
     CGRect cell=self.frame;
     UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(cell.size.width-15, 0, 15, 15)];
     [myTextField setBackgroundColor:[UIColor whiteColor]];
     [myTextField setText:[languageId uppercaseString]];
     myTextField.layer.borderColor=[[UIColor blackColor]CGColor];
     myTextField.layer.borderWidth=1.0;
     myTextField.font = [UIFont systemFontOfSize:10.0];
     myTextField.minimumFontSize = 5.0;
     [self addSubview:myTextField];
     [myTextField release];
}

@end
