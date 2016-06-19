// WBGeometry.h -- geometry add-ons
// by allen brunson  april 20 2009

#ifndef GUITOUCH_WBGEOMETRY_H
#define GUITOUCH_WBGEOMETRY_H

#import <stdint.h>
#import <UIKit/UIKit.h>


/****************************************************************************/
/*                                                                          */
/***  iphone graphics constants                                           ***/
/*                                                                          */
/****************************************************************************

these values are for reference and for writing sanity checks. when you need
the "real" dimensions of something, ask the operating system. really, i mean
it. don't make me cut you.                                                  */

// iphone screen size
const CGFloat kPhoneScreenWidth  = 320.0;
const CGFloat kPhoneScreenHeight = 480.0;
const CGSize  kPhoneScreenSize   = {kPhoneScreenWidth, kPhoneScreenHeight};

// ipad screen size
const CGFloat kPadScreenWidth  =  768.0;
const CGFloat kPadScreenHeight = 1024.0;
const CGSize  kPadScreenSize   = {kPadScreenWidth, kPadScreenHeight};

// tab bar image size
const CGFloat kTabBarImageWidth = 30.0;
const CGSize  kTabBarImageSize  = {kTabBarImageWidth, kTabBarImageWidth};

// minimum height or width for user-selectable target
const CGFloat kMinTargetSize = 44.0;

// iphone graphic elements
const CGFloat kStatusBarHeight = 20.0;
const CGFloat kToolbarHeight   = 44.0;


/****************************************************************************/
/*                                                                          */
/***  point and rect helper methods                                       ***/
/*                                                                          */
/****************************************************************************/

// center point of a rect

inline CGPoint pointCenter(CGRect rect)
{
    CGPoint  cgpt = CGPointZero;

    cgpt.x = rect.origin.x + floor(rect.size.width  / 2.0);
    cgpt.y = rect.origin.y + floor(rect.size.height / 2.0);

    return cgpt;
}

inline CGPoint pointLowerLeft(CGRect rect)
{
    return CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - 1.0);
}

inline CGPoint pointLowerRight(CGRect rect)
{
    return CGPointMake(CGRectGetMaxX(rect) - 1.0, CGRectGetMaxY(rect) - 1.0);
}

inline CGPoint pointUpperLeft(CGRect rect)
{
    return CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
}

inline CGPoint pointUpperRight(CGRect rect)
{
    return CGPointMake(CGRectGetMaxX(rect) - 1.0, CGRectGetMinY(rect));
}

// center 'target' over 'rect'

inline CGRect rectCenter(CGRect rect, CGRect target)
{
    CGPoint  cgpt = pointCenter(rect);

    target.origin.x = cgpt.x - floor(target.size.width  / 2.0);
    target.origin.y = cgpt.y - floor(target.size.height / 2.0);

    return target;
}

// "zooms" a rect by adding zoomSize pixels to each side. the returned rect
// will be centered directly over the old one.

inline CGRect rectZoom(CGRect rect, CGFloat zoomSize)
{
    rect.origin.x    -= zoomSize;
    rect.origin.y    -= zoomSize;

    rect.size.width  += (zoomSize * 2.0);
    rect.size.height += (zoomSize * 2.0);

    return rect;
}

inline CGSize swapWidthAndHeight(CGSize size)
{
    CGFloat  swap = size.width;

    size.width  = size.height;
    size.height = swap;

    return size;
}


/****************************************************************************/
/*                                                                          */
/***  misc helper methods                                                 ***/
/*                                                                          */
/****************************************************************************/

// degrees to radians, useful for affine translations

inline CGFloat degreesToRadians(CGFloat degrees)
{
    return M_PI * (degrees / 180.0);
}

// distance between two points

inline double distance(CGPoint point1, CGPoint point2)
{
    const double  dstx = point1.x - point2.x;
    const double  dsty = point1.y - point2.y;
    
    return sqrt((dstx * dstx) + (dsty * dsty));
}


/****************************************************************************/
/*                                                                          */
/***  WBGeometry module                                                   ***/
/*                                                                          */
/****************************************************************************

overview
--------

inline functions and defines for graphics operations

*/

#endif  // GUITOUCH_WBGEOMETRY_H
