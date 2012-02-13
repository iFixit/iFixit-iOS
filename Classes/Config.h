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

@interface Config : NSObject

@property (nonatomic) BOOL dozuki;
@property (nonatomic) BOOL answersEnabled;
@property (nonatomic) BOOL collectionsEnabled;
@property (nonatomic, retain) NSString *store;
@property (nonatomic) NSInteger site;
@property (nonatomic, copy) NSString *sso;
@property (nonatomic, retain) NSDictionary *siteData;
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
