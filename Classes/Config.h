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
    ConfigDozuki,
    ConfigZeal,
    ConfigMjtrim,
    ConfigAccustream,
    ConfigMagnolia,
    ConfigComcast,
    ConfigDripAssist,
    ConfigPva,
    ConfigOscaro,
    ConfigTechtitanhq,
     ConfigPepsi,
     ConfigAristo
    /*EAOConfig*/
};

@interface Config : NSObject

@property (nonatomic) BOOL dozuki;
@property (nonatomic) BOOL answersEnabled;
@property (nonatomic) BOOL collectionsEnabled;
@property (nonatomic) BOOL private;
@property (nonatomic) BOOL scanner;
@property (nonatomic, retain) NSString *store;
@property (nonatomic) NSInteger site;
@property (nonatomic, copy) NSString *sso;
@property (nonatomic, retain) NSDictionary *siteData;
@property (nonatomic, retain) NSString *host;
@property (nonatomic, retain) NSString *custom_domain;
@property (nonatomic, retain) NSString *baseURL;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *toolbarColor;
@property (nonatomic, retain) UIColor *buttonColor;
@property (nonatomic, retain) UIColor *tabBarColor;
@property (nonatomic, retain) NSString *introCSS;
@property (nonatomic, retain) NSString *stepCSS;
@property (nonatomic, retain) NSString *moreInfoCSS;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) UIImage *concreteBackgroundImage;
@property (nonatomic, retain) NSDictionary *siteInfo;

+ (Config *)currentConfig;

+ (NSString *)host;
+ (NSString *)baseURL;

@end
