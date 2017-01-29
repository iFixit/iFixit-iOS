// WBFont.h -- extra UIFont methods
// by allen brunson  april 3 2009

#ifndef GUITOUCH_WBFONT_H
#define GUITOUCH_WBFONT_H

#import <UIKit/UIKit.h>


/****************************************************************************/
/*                                                                          */
/***  WBFont category                                                     ***/
/*                                                                          */
/****************************************************************************/

@interface UIFont (WBFont)

// class methods
+(UIFont*)boldSystemFont;
+(UIFont*)systemFont;

// properties
-(CGFloat)pixelHeight;

@end


/****************************************************************************/
/*                                                                          */
/***  WBFont category                                                     ***/
/*                                                                          */
/****************************************************************************

overview
--------

extra methods for UIFont

*/

#endif  // GUITOUCH_WBFONT_H
