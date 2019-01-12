#import "NIKFontAwesomePathFactory.h"

#import <CoreText/CoreText.h>

static NSString *const FONT_NAME = @"FontAwesome";
static NSString *const FONT_EXTENSION = @"otf";

@implementation NIKFontAwesomePathFactory

- (CGPathRef)createPathForIcon:(NIKFontAwesomeIcon)icon
                        height:(CGFloat)height
                      maxWidth:(CGFloat)width CF_RETURNS_RETAINED {

    CGPathRef path = [self createPathForIcon:icon height:height];
    CGRect bounds = CGPathGetBoundingBox(path);
    static const float EPSILON = 0.01;
    if (bounds.size.width > width + EPSILON) {
        CGPathRef scaledPath = [self createScaledPath:path scale:width / bounds.size.width];
        CGPathRelease(path);
        path = scaledPath;
        bounds = CGPathGetBoundingBox(path);
    }
    if (bounds.size.height > height + EPSILON) {
        // Some icons (e.g. odnoklassniki) exceed their bounds.
        // We lose pixel perfection here, but better than clipping.
        CGPathRef scaledPath = [self createScaledPath:path scale:height / bounds.size.height];
        CGPathRelease(path);
        path = scaledPath;
    }
    return path;
}

- (CGPathRef)createPathForIcon:(NIKFontAwesomeIcon)icon height:(CGFloat)height CF_RETURNS_RETAINED {
    CTFontRef font = [self font];
    CGFloat fontHeight = CTFontGetSize(font);
    CGAffineTransform scale = CGAffineTransformMakeScale(height / fontHeight,
                                                         height / fontHeight);
    CGAffineTransform transform = CGAffineTransformTranslate(scale, 0, CTFontGetDescent(font));
    return CTFontCreatePathForGlyph(font, [self glyphForIcon:icon], &transform);
}

- (CTFontRef)font {
    static CTFontRef __font;
    static dispatch_once_t __onceToken;
    dispatch_once(&__onceToken, ^{
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSURL *url = [bundle URLForResource:FONT_NAME withExtension:FONT_EXTENSION];
        NSAssert(url, @"Font Awesome not found in bundle.", nil);
        CGDataProviderRef provider = CGDataProviderCreateWithURL((__bridge CFURLRef)url);
        CGFontRef cgFont = CGFontCreateWithDataProvider(provider);
        CTFontDescriptorRef fontDescriptor =
            CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)@{});

        __font = CTFontCreateWithGraphicsFont(cgFont, 0, NULL, fontDescriptor);

        CFRelease(fontDescriptor);
        CFRelease(cgFont);
        CFRelease(provider);
    });
    return __font;
}

- (CGPathRef)createScaledPath:(CGPathRef)path scale:(CGFloat)factor CF_RETURNS_RETAINED {
    CGAffineTransform scale = CGAffineTransformMakeScale(factor, factor);
    return CGPathCreateCopyByTransformingPath(path, &scale);
}

- (CGGlyph)glyphForIcon:(NIKFontAwesomeIcon)icon {
    UniChar const characters[] = {icon};
    CGGlyph glyph;
    CTFontGetGlyphsForCharacters([self font], characters, &glyph, 1);
    return glyph;
}

@end
