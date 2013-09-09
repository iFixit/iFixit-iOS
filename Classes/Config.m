//
//  Config.m
//  iFixit
//
//  Created by David Patierno on 2/3/11.
//  Copyright 2011 iFixit. All rights reserved.
//

#import "Config.h"

static Config *currentConfig = nil;

@implementation Config

@synthesize dozuki, answersEnabled, sso, collectionsEnabled, private, store;
@synthesize site, siteData, host, custom_domain, baseURL, backgroundColor, textColor, toolbarColor, introCSS, stepCSS;

+ (Config *)currentConfig {
    if (!currentConfig) {
        currentConfig = [[self alloc] init];
        currentConfig.site = ConfigIFixit;
        currentConfig.dozuki = NO;
    }
    return currentConfig;
}

- (void)setSite:(NSInteger)theSite {
    
    site = theSite;

    switch (site) {
        case ConfigIFixit:
            self.host = @"www.ifixit.com";
            self.baseURL = @"http://www.ifixit.com/Guide";
            answersEnabled = YES;
            collectionsEnabled = YES;
            self.store = @"http://www.ifixit.com/Parts-Store";
            break;
        case ConfigIFixitDev:
            self.host = @"www.cominor.com";
            self.baseURL = @"http://www.cominor.com/Guide";
            answersEnabled = YES;
            collectionsEnabled = YES;
            self.store = @"http://www.ifixit.com/Parts-Store";
            break;
        case ConfigMake:
            self.host = @"makeprojects.com";
            self.baseURL = @"http://makeproject.com";
            answersEnabled = NO;
            collectionsEnabled = YES;
            self.store = nil;
            break;
        case ConfigMakeDev:
            self.host = @"make.cominor.com";
            self.baseURL = @"http://make.cominor.com";
            answersEnabled = NO;
            collectionsEnabled = YES;
            self.store = nil;
            break;
        case ConfigZeal:
            self.host = @"zealoptics.dozuki.com";
            self.baseURL = @"http://zealoptics.dozuki.com";
            answersEnabled = NO;
            collectionsEnabled = NO;
            self.store = nil;
            break;
        case ConfigMjtrim:
            self.host = @"mjtrim.dozuki.com";
            self.baseURL = @"http://mjtrim.dozuki.com";
            answersEnabled = NO;
            collectionsEnabled = NO;
            self.store = @"http://www.mjtrim.com/";
            self.private = NO;
            break;
        /*EAOOptions*/
        default:
            self.host = nil;
            self.baseURL = nil;
            answersEnabled = NO;
            collectionsEnabled = NO;
            self.store = nil;
            self.title = nil;
    }
    
    switch (site) {
        // Make
        // We should probably remove this
        case ConfigMake:
        case ConfigMakeDev:
            self.backgroundColor = [UIColor whiteColor];
            self.textColor = [UIColor blackColor];
            self.toolbarColor = [UIColor colorWithRed:0.16 green:0.67 blue:0.89 alpha:1.0];
            
            // Load intro and step css from the css folder.
            self.introCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"make_intro" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];
            self.stepCSS  = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"make_step" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            break;
        // iFixit
        case ConfigIFixit:
        case ConfigIFixitDev:
            self.backgroundColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:43/255.0f alpha:1];
            self.textColor = [UIColor whiteColor];
            self.toolbarColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:43/255.0f alpha:1];

            // Load intro and step css from the css folder.        
            self.introCSS    = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ifixit_intro" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];
            self.stepCSS     = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ifixit_step" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            self.moreInfoCSS = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
                ? [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_ipad" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil]
                : [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_iphone" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            self.answersCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_answers" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];
            break;
        // MJ Trim
        case ConfigMjtrim:
            self.textColor = [UIColor blackColor];
            self.backgroundColor = [UIColor whiteColor];
            self.toolbarColor = [UIColor blackColor];
            self.buttonColor = [UIColor blackColor];
            
            self.concreteBackgroundImage = [UIImage imageNamed:@"concreteBackgroundWhite.png"];
            self.introCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"make_intro" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];
            self.stepCSS  = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"make_step" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            break;
        default:
            self.backgroundColor = [UIColor blackColor];
            self.textColor = [UIColor whiteColor];
            //self.toolbarColor = [UIColor darkGrayColor];
            self.toolbarColor = [UIColor colorWithRed:.19 green:.21 blue:.23 alpha:1.0];
            
            // Load intro and step css from the css folder.        
            self.introCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ifixit_intro" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];
            self.stepCSS  = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ifixit_step" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            self.moreInfoCSS = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
                ? [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_ipad" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil]
                : [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_iphone" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            self.answersCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_answers" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];
            break;
            
    }
}

+ (NSString *)host {
    // SSO sites on a custom domain need access to their own sessionid.
    if ([Config currentConfig].sso && [Config currentConfig].custom_domain)
        return [Config currentConfig].custom_domain;
    // Everyone else uses the main .dozuki.com host.
    return [Config currentConfig].host;
}
+ (NSString *)baseURL {
    return [Config currentConfig].baseURL;
}

@end
