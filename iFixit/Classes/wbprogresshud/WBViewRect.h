// WBViewRect.h -- rectangle drawing methods for UIView
// by allen brunson  march 2 2009

#ifndef GUITOUCH_WBVIEWRECT_H
#define GUITOUCH_WBVIEWRECT_H

#import <UIKit/UIKit.h>


/****************************************************************************/
/*                                                                          */
/***  WBViewRect category                                                 ***/
/*                                                                          */
/****************************************************************************/

@interface UIView (WBViewRect)

// points
-(void)drawPoint:(CGPoint)point;
-(void)drawPoint:(CGPoint)point color:(UIColor*)color;

// filled rects
-(void)fillRect:(CGRect)rect;
-(void)fillRect:(CGRect)rect color:(UIColor*)color;

// filled rects with rounded corners
-(void)fillRoundRect:(CGRect)rect;
-(void)fillRoundRect:(CGRect)rect color:(UIColor*)color;
-(void)fillRoundRect:(CGRect)rect color:(UIColor*)color 
 radius:(CGFloat)radius;

// outlined rects
-(void)strokeRect:(CGRect)rect;
-(void)strokeRect:(CGRect)rect color:(UIColor*)color;

// outlined rects with rounded corners
-(void)strokeRoundRect:(CGRect)rect;
-(void)strokeRoundRect:(CGRect)rect color:(UIColor*)color;
-(void)strokeRoundRect:(CGRect)rect color:(UIColor*)color
 radius:(CGFloat)radius;

@end


/****************************************************************************/
/*                                                                          */
/***  WBViewRect category                                                 ***/
/*                                                                          */
/****************************************************************************

overview
--------

UIView add-on methods for drawing points and rectangles

*/

#endif  // GUITOUCH_WBVIEWRECT_H
