// WBProgressHUD.h -- UIProgressHUD replacement
// by allen brunson  february 23 2010

#ifndef GUITOUCH_WBPROGRESSHUD_H
#define GUITOUCH_WBPROGRESSHUD_H

#import <UIKit/UIKit.h>


/****************************************************************************/
/*                                                                          */
/***  WBProgressHUD class                                                 ***/
/*                                                                          */
/****************************************************************************/

@interface WBProgressHUD: UIView
{
    @private
    
    UIColor*                  colorBackground;
    UIColor*                  colorForeground;
    UIActivityIndicatorView*  progressIndicator;
    UILabel*                  progressMessage;
}

// properties

@property(nonatomic, retain) UIColor*                  colorBackground;
@property(nonatomic, retain) UIColor*                  colorForeground;
@property(nonatomic, retain) UIActivityIndicatorView*  progressIndicator;
@property(nonatomic, retain) UILabel*                  progressMessage;

// class methods

+(WBProgressHUD*)view;
+(WBProgressHUD*)viewWithFrame:(CGRect)frame;

// construction and destruction

-(void)dealloc;
-(id)initWithFrame:(CGRect)rect;

// custom methods

-(void)hide;
-(void)setFontSize:(CGFloat)size;
-(void)setText:(NSString*)text;
-(void)showInView:(UIView*)view;

// UIView methods

-(UIColor*)backgroundColor;
-(void)drawRect:(CGRect)rect;
-(void)layoutSubviews;
-(void)setBackgroundColor:(UIColor*)color;

// private methods

-(CGRect)rectIndicator:(CGSize)size;
-(CGFloat)rectIndicatorHeight;
-(CGRect)rectMessage;
-(CGFloat)rectNudge;

@end


/****************************************************************************/
/*                                                                          */
/***  WBProgressHUD class                                                 ***/
/*                                                                          */
/****************************************************************************

overview
--------

more-or-less exact replacement for UIProgressHUD, the undocumented class that
you can't use in real-live programs, because apple would spank you.


using the class
---------------

call [WBProgressHUD viewWithFrame:] to create a new view. when ready to
display it, call [WBProgressHUD showInView:] to put it onscreen and start
it animating. call [WBProgressHUD hide] to hide the view without removing it
from its parent view.

you can customize the text string displayed in the view by calling
[WBProgressHUD setText:] and [WBProgressHUD setFontSize:]. these methods
can be called at any time, including while the view is being displayed.

you can customize the background color and text color with the colorBackground
and colorForeground properties, which default to translucent black and pure
white, respectively. i haven't tested this very much. it might not work so
hot to change the foreground color, because the activity indicator would
remain white.


translucent drawing
-------------------

to make background drawing partially translucent, i had to commandeer the
view's background color, and force it to always be clear. attempts to set the
background color to something else will cause an assertion failure. if you
want to change the background color, set the colorBackground property.

*/

#endif // GUITOUCH_WBPROGRESSHUD_H
