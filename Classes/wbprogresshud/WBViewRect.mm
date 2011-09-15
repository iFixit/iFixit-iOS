// WBViewRect.mm -- rectangle drawing methods for UIView
// by allen brunson  march 2 2009

#include "WBView.h"
#include "WBViewRect.h"

#pragma mark module data

static const CGFloat kCornerRadius = 5.0;

static CGRect rectStrokeAdjust(CGRect rect)
{
    rect = CGRectIntegral(rect);

    rect.origin.x    += 0.5;
    rect.origin.y    += 0.5;
    rect.size.width  -= 1.0;
    rect.size.height -= 1.0;

    return rect;
}

static void roundRect(CGContextRef context, CGRect rect,
 CGFloat ovalWidth, CGFloat ovalHeight)
{
    const CGFloat  fw = rect.size.width  / ovalWidth;
    const CGFloat  fh = rect.size.height / ovalHeight;

    assert(ovalWidth  >= 1.0);
    assert(ovalHeight >= 1.0);

    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);

    CGContextMoveToPoint(context, fw, fh / 2.0);
    CGContextAddArcToPoint(context, fw,  fh,  fw / 2.0, fh,  1.0);
    CGContextAddArcToPoint(context, 0.0, fh,  0.0, fh / 2.0, 1.0);
    CGContextAddArcToPoint(context, 0.0, 0.0, fw / 2.0, 0.0, 1.0);
    CGContextAddArcToPoint(context, fw,  0.0, fw, fh / 2.0,  1.0);

    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

@implementation UIView (WBRectView)

-(void)drawPoint:(CGPoint)point
{
    [self drawPoint:point color:nil];
}

-(void)drawPoint:(CGPoint)point color:(UIColor*)color
{
    const CGRect rect = CGRectMake(point.x, point.y, 1.0, 1.0);
    [self fillRect:rect color:color];
}

-(void)fillRect:(CGRect)rect
{
    [self fillRect:rect color:nil];
}

-(void)fillRect:(CGRect)rect color:(UIColor*)color
{
    CGContextRef  ctxt = [self contextSave];

    if (color)
    {
        CGContextSetFillColorWithColor(ctxt, [color CGColor]);
    }

    // this works, but cannot handle semi-transparent colors
    // UIRectFill(rect);

    // this method works with transparent colors
    CGContextFillRect(ctxt, rect);

    [self contextRestore:ctxt];
}

-(void)fillRoundRect:(CGRect)rect
{
    [self fillRoundRect:rect color:nil radius:kCornerRadius];
}

-(void)fillRoundRect:(CGRect)rect color:(UIColor*)color
{
    [self fillRoundRect:rect color:color radius:kCornerRadius];
}

-(void)fillRoundRect:(CGRect)rect color:(UIColor*)color radius:(CGFloat)radius
{
    CGContextRef  ctxt = [self contextSave];

    roundRect(ctxt, rect, radius, radius);

    if (color)
    {
        CGContextSetFillColorWithColor(ctxt, [color CGColor]);
    }

    CGContextFillPath(ctxt);
    [self contextRestore:ctxt];
}

-(void)strokeRect:(CGRect)rect
{
    [self strokeRect:rect color:nil];
}

-(void)strokeRect:(CGRect)rect color:(UIColor*)color
{
    CGContextRef  ctxt = [self contextSave];

    if (color)
    {
        CGContextSetStrokeColorWithColor(ctxt, [color CGColor]);
    }

    // this works, but gives poor results
    // CGContextStrokeRect(ctxt, rect);

    // this one draws nice clean one-pixel lines
    UIRectFrame(rect);

    [self contextRestore:ctxt];
}

-(void)strokeRoundRect:(CGRect)rect
{
    [self strokeRoundRect:rect color:nil radius:kCornerRadius];
}

-(void)strokeRoundRect:(CGRect)rect color:(UIColor*)color
{
    [self strokeRoundRect:rect color:color radius:kCornerRadius];
}

-(void)strokeRoundRect:(CGRect)rect color:(UIColor*)color
 radius:(CGFloat)radius
{
    CGContextRef  ctxt = [self contextSave];

    rect = rectStrokeAdjust(rect);
    roundRect(ctxt, rect, radius, radius);

    if (color)
    {
        CGContextSetStrokeColorWithColor(ctxt, [color CGColor]);
    }

    CGContextStrokePath(ctxt);
    [self contextRestore:ctxt];
}

@end
