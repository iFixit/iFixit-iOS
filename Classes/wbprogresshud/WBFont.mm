// WBFont.mm -- extra UIFont methods
// by allen brunson  april 3 2009

#include "WBFont.h"

@implementation UIFont (WBFont)

+(UIFont*)boldSystemFont
{
    const CGFloat  size = [UIFont systemFontSize] + 1.0;
    UIFont*        font = [UIFont boldSystemFontOfSize:size];

    return font;
}

-(CGFloat)pixelHeight
{
    return ceil(fabs(self.leading));
}

+(UIFont*)systemFont
{
    const CGFloat  size = [UIFont systemFontSize];
    UIFont*        font = [UIFont systemFontOfSize:size];

    return font;
}

@end
