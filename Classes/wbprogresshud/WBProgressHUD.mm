// WBProgressHUD.mm -- UIProgressHUD replacement
// by allen brunson  february 23 2010

#include "WBFont.h"
#include "WBGeometry.h"
#include "WBProgressHUD.h"
#include "WBViewRect.h"

// default background color

static UIColor* defaultBackgroundColor()
{
    return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.78];
}

// default foreground color

static UIColor* defaultForegroundColor()
{
    return [UIColor whiteColor];
}

@implementation WBProgressHUD

@synthesize colorBackground, colorForeground;
@synthesize progressIndicator, progressMessage;

// override the built-in UIView method. for our drawing to work, this color
// must always be invisible

-(UIColor*)backgroundColor
{
    return [UIColor clearColor];
}

-(void)dealloc
{
    self.colorBackground   = nil;
    self.colorForeground   = nil;
    self.progressIndicator = nil;
    self.progressMessage   = nil;
    
    [super dealloc];
}

// draw background: semi-transparent round rect

-(void)drawRect:(CGRect)rect
{
    [self fillRoundRect:self.bounds color:self.colorBackground radius:10.0];
}

// hide the view

-(void)hide
{
    self.alpha = 0.0;
    [self.progressIndicator stopAnimating];
}

// constructor work

-(id)initWithFrame:(CGRect)frame
{
    UIActivityIndicatorView*      prog = nil;
    CGRect                        rect = CGRectZero;
    UILabel*                      text = nil;
    UIActivityIndicatorViewStyle  type = (UIActivityIndicatorViewStyle) 0;
    
    // create superview
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    // view properties
    self.alpha           = 0.0;
    self.opaque          = FALSE;
    self.colorBackground = defaultBackgroundColor();
    self.colorForeground = defaultForegroundColor();
    
    // create indicator view
    type = UIActivityIndicatorViewStyleWhiteLarge;
    prog = [UIActivityIndicatorView alloc];
    prog = [prog initWithActivityIndicatorStyle:type];
    [prog autorelease];
    prog.frame = [self rectIndicator:prog.frame.size];
    
    // create text label
    rect = [self rectMessage];
    text = [[[UILabel alloc] initWithFrame:rect] autorelease];
    
    // text properties
    text.backgroundColor = [UIColor clearColor];
    text.textColor       = self.colorForeground;
    text.textAlignment   = UITextAlignmentCenter;
    
    // set child views
    [self addSubview:prog];
    [self addSubview:text];
    
    // save view pointers
    self.progressIndicator = prog;
    self.progressMessage   = text;
    
    // default text
    [self setFontSize:14.0];
    [self setText:[NSString stringWithFormat:@"  %@", NSLocalizedString(@"Loading...", nil)]];
    
    return self;
}

-(void)layoutSubviews
{
    const CGSize  size = self.progressIndicator.frame.size;
    
    self.progressIndicator.frame = [self rectIndicator:size];
    self.progressMessage.frame   = [self rectMessage];
}

// frame rect for the activity indicator

-(CGRect)rectIndicator:(CGSize)size
{
    const CGRect  bnds = self.bounds;
    CGRect        area = bnds;
    CGRect        rect = CGRectZero;
    
    // indicator area is upper half of the view
    area.size.height = [self rectIndicatorHeight];
    
    // indicator size is determined at construction time
    rect.size = size;
    
    // center indicator over its area, then move it down a bit
    rect = rectCenter(area, rect);
    rect.origin.y += [self rectNudge] + 8;
    
    return rect;
}

// height pixels for the activity indicator

-(CGFloat)rectIndicatorHeight
{
    const CGRect bnds = self.bounds;
    return floor(bnds.size.height / 2.0);
}

// frame rect for the UILabel control

-(CGRect)rectMessage
{
    const CGRect   bnds = self.bounds;
    CGRect         area = bnds;
    CGRect         rect = CGRectZero;
    const CGFloat  size = [self rectIndicatorHeight];
    
    // message area is lower half of the view
    area.size.height = bnds.size.height - size;
    area.size.width  = bnds.size.width;
    area.origin.y   += size;
    
    // message size
    rect.size.width  = bnds.size.width - 8.0;
    rect.size.height = self.progressMessage.font.pixelHeight;
    
    // center message over its area, then move it up a bit
    rect = rectCenter(area, rect);
    rect.origin.y -= [self rectNudge];
    
    return rect;
}

// nudge the activity indicator and the text label towards the center of the
// view by this many pixels

-(CGFloat)rectNudge
{
    const CGRect bnds = self.bounds;
    return floor(bnds.size.height * 0.06);
}

// this color should never be set. use the colorBackground property instead

-(void)setBackgroundColor:(UIColor*)color
{
    assert(false);
}

-(void)setFontSize:(CGFloat)size
{
    self.progressMessage.font = [UIFont boldSystemFontOfSize:size];
}

-(void)setText:(NSString*)text
{
    self.progressMessage.text = text;
}

// display this progress hud over 'view'

-(void)showInView:(UIView*)view
{
    self.alpha = 1.0;
    self.progressMessage.textColor = self.colorForeground;
    
    [view addSubview:self];
    [self.progressIndicator startAnimating];
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

// convenience method for creating a WBProgressHUD with a default size

+(WBProgressHUD*)view
{
    const CGRect rect = CGRectMake(0.0, 0.0, 240.0, 140.0);
    return [WBProgressHUD viewWithFrame:rect];
}

// convenience method for creating a WBProgressHUD with the given frame rect

+(WBProgressHUD*)viewWithFrame:(CGRect)frame
{
    return [[[WBProgressHUD alloc] initWithFrame:frame] autorelease];
}

@end
