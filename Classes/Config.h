//
//  Config.h
//  iFixit
//
//  Created by David Patierno on 2/3/11.
//  Copyright 2011 iFixit. All rights reserved.
//

enum {
    ConfigIFixit,
    ConfigIFixitDev,
    ConfigMake,
    ConfigMakeDev,
    ConfigDozuki
};

@interface Config : NSObject {
    BOOL dozuki;
    NSInteger site;
    NSString *host;
    NSString *baseURL;
    UIColor *backgroundColor;
    UIColor *textColor;
    UIColor *toolbarColor;
    NSString *introCSS;
    NSString *stepCSS;
}

@property (nonatomic) BOOL dozuki;
@property (nonatomic) NSInteger site;
@property (nonatomic, retain) NSString *host;
@property (nonatomic, retain) NSString *baseURL;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *toolbarColor;
@property (nonatomic, retain) NSString *introCSS;
@property (nonatomic, retain) NSString *stepCSS;

+ (Config *)currentConfig;

+ (NSString *)host;
+ (NSString *)baseURL;

@end
