// WBView.h -- extra UIView methods
// by allen brunson  march 2 2009

#ifndef GUITOUCH_WBVIEW_H
#define GUITOUCH_WBVIEW_H

#import <UIKit/UIKit.h>


/****************************************************************************/
/*                                                                          */
/***  WBView category                                                     ***/
/*                                                                          */
/****************************************************************************/

@interface UIView (WBView)

// autoresize mask settings
-(void)autoresizeWidthHeight;

// save and restore graphics context
-(void)contextRestore:(CGContextRef)context;
-(CGContextRef)contextSave;

// remove all subviews
-(void)removeSubviews;

@end


/****************************************************************************/
/*                                                                          */
/***  WBView category                                                     ***/
/*                                                                          */
/****************************************************************************

overview
--------

extra methods for UIView

*/

#endif  // GUITOUCH_WBVIEW_H
