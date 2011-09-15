// WBView.mm -- extra UIView methods
// by allen brunson  march 2 2009

#include "WBView.h"

@implementation UIView (WBView)

-(void)autoresizeWidthHeight;
{
    UIViewAutoresizing  mask = 0;

    mask |= UIViewAutoresizingFlexibleWidth;
    mask |= UIViewAutoresizingFlexibleHeight;

    self.autoresizingMask = mask;
}

-(void)contextRestore:(CGContextRef)context
{
    assert(context);
    CGContextRestoreGState(context);
}

-(CGContextRef)contextSave
{
    CGContextRef  ctxt = UIGraphicsGetCurrentContext();

    CGContextSaveGState(ctxt);

    return ctxt;
}

-(void)removeSubviews
{
    NSArray*   list = [self subviews];
    NSInteger  size = [list count];
    UIView*    view = nil;

    for (NSInteger vnum = 0; vnum < size; vnum++)
    {
        view = [list objectAtIndex:vnum];
        [view removeFromSuperview];
    }
}

@end
