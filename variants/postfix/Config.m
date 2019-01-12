//
//  Config.m
//  iFixit
//
//  Created by David Patierno on 2/3/11.
//  Copyright 2011 iFixit. All rights reserved.
//

#import "Config.h"
#import "iFixitAppDelegate.h"

static Config *currentConfig = nil;

@implementation Config

@synthesize dozuki, answersEnabled, sso, collectionsEnabled, private, store;
@synthesize site, siteData, host, custom_domain, baseURL, backgroundColor, textColor, toolbarColor, navBarColor, introCSS, stepCSS;

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
            self.store = @"http://www.ifixit.com/Store";
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
        case ConfigAccustream:
            self.host = @"accustream.dozuki.com";
            self.baseURL = @"http://accustream.dozuki.com";
            answersEnabled = NO;
            collectionsEnabled = NO;
            self.store = @"http://www.accustream.com/waterjet-parts.html";
            self.private = NO;
            self.scanner = YES;
            break;
        case ConfigMagnolia:
            self.host = @"magnoliamedical.dozuki.com";
            self.baseURL = @"http://magnoliamedical.dozuki.com";
            answersEnabled = NO;
            collectionsEnabled = NO;
            self.store = nil;
            self.private = YES;
            self.scanner = NO;
            break;
        case ConfigComcast:
            self.host = @"comcast.dozuki.com";
            self.baseURL = @"http://comcast.dozuki.com";
            answersEnabled = NO;
            collectionsEnabled = NO;
            self.store = nil;
            self.private = YES;
            self.scanner = NO;
            self.sso = @"http://comcast.dozuki.com";
            break;
        case ConfigDripAssist:
            self.host = @"dripassist.dozuki.com";
            self.baseURL = @"http://dripassist.dozuki.com";
            answersEnabled = NO;
            collectionsEnabled = NO;
            self.store = nil;
            self.private = NO;
            self.scanner = NO;
            break;
        case ConfigPva:
            self.host = @"pva.dozuki.com";
            self.baseURL = @"http://pva.dozuki.com";
            answersEnabled = NO;
            collectionsEnabled = NO;
            self.store = nil;
            self.private = NO;
            self.scanner = NO;
            break;
        case ConfigTechtitanhq:
            self.host = @"techtitanhq.dozuki.com";
            self.baseURL = @"http://techtitanhq.dozuki.com";
            answersEnabled = NO;
            collectionsEnabled = NO;
            self.store = nil;
            self.private = YES;
            self.scanner = NO;
            break;
        case ConfigOscaro:
            self.host = @"oscaro.dozuki.com";
            self.baseURL = @"http://oscaro.dozuki.com";
            answersEnabled = NO;
            collectionsEnabled = NO;
            self.store = nil;
            self.private = NO;
            self.scanner = NO;
            break;
         case ConfigPepsi:
              self.host = @"charlessmith.dozuki.com";
              self.baseURL = @"http://charlessmith.dozuki.com";
              answersEnabled = NO;
              collectionsEnabled = NO;
              self.store = nil;
              self.private = YES;
              self.scanner = NO;
              break;
         case ConfigAristo:
              self.host = @"aristocrat.dozuki.com";
              self.baseURL = @"http://aristocrat.dozuki.com";
              answersEnabled = NO;
              collectionsEnabled = NO;
              self.store = nil;
              self.private = YES;
              self.scanner = NO;
              break;
        /*EAOOptions*/
        default:
            self.host = @"www.dozuki.com";
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
            self.navBarColor = [UIColor whiteColor];
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
            self.toolbarColor = [UIColor colorWithRed:10/255.0f green:10/255.0f blue:10/255.0f alpha:1];
            self.buttonColor = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? [UIColor colorWithRed:0.0f green:113/255.0f blue:206.0/255.0f alpha:1.0] : self.toolbarColor;
            self.navBarColor = [UIColor whiteColor];
            
            // Load intro and step css from the css folder.        
            self.introCSS    = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ifixit_intro" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];
            self.stepCSS     = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ifixit_step" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            self.moreInfoCSS = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
                ? [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_ipad" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil]
                : [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_iphone" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            break;
        // MJ Trim
        case ConfigMjtrim:
            self.textColor = [UIColor blackColor];
            self.backgroundColor = [UIColor whiteColor];
            self.toolbarColor = [UIColor colorWithRed:204/255.0f green:0.0f blue:0.0f alpha:1.0];
            self.buttonColor = [UIColor colorWithRed:234/255.0f green:166.0/255.0f blue:160.0/255.0f alpha:1.0];
            self.tabBarColor = self.toolbarColor;
            self.navBarColor = [UIColor whiteColor];

            self.concreteBackgroundImage = [UIImage imageNamed:@"concreteBackgroundWhite.png"];
            self.introCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"make_intro" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];
            self.stepCSS  = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"make_step" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            break;
        // Config Magnolia
        case ConfigMagnolia:
            self.textColor = [UIColor blackColor];
            self.backgroundColor = [UIColor whiteColor];
            self.toolbarColor = [UIColor whiteColor];
            self.buttonColor = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? [UIColor colorWithRed:0.0f green:113/255.0f blue:206.0/255.0f alpha:1.0] : self.toolbarColor;
            self.tabBarColor = self.buttonColor;
            self.navBarColor = [UIColor whiteColor];

            self.concreteBackgroundImage = [UIImage imageNamed:@"concreteBackgroundWhite.png"];
            self.introCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"make_intro" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];
            self.stepCSS  = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"make_step" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            break;
        case ConfigAccustream:
            self.backgroundColor = [UIColor blackColor];
            self.textColor = [UIColor whiteColor];
            self.toolbarColor = [UIColor blackColor];
            self.buttonColor = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? [UIColor colorWithRed:0.0f green:113/255.0f blue:206.0/255.0f alpha:1.0] : self.toolbarColor;
            self.navBarColor = [UIColor whiteColor];
            
            // Load intro and step css from the css folder.        
            self.introCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"accustream_intro" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];
            self.stepCSS  = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"accustream_step" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            self.moreInfoCSS = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            ? [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_ipad" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil]
            : [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_iphone" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            break;
            
        case ConfigDripAssist:
            self.backgroundColor = [UIColor blackColor];
            self.textColor = [UIColor whiteColor];
            self.toolbarColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0/255.0f alpha:1.0];
            self.buttonColor = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? [UIColor colorWithRed:109.0f/255.0f green:109.0f/255.0f blue:109.0f/255.0f alpha:1.0] : self.toolbarColor;
            self.navBarColor = [UIColor whiteColor];
            
            // Load intro and step css from the css folder.        
            self.introCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ifixit_intro" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];
            self.stepCSS  = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ifixit_step" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            self.moreInfoCSS = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
                ? [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_ipad" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil]
                : [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_iphone" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            break;
        case ConfigTechtitanhq:
            self.backgroundColor = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:43/255.0f alpha:1];
            self.textColor = [UIColor whiteColor];
            self.toolbarColor = [UIColor blackColor];
            self.buttonColor = [UIColor colorWithRed:35.0/255.0f green:217.0/255.0f blue:253.0/255.0f alpha:1.0];
            self.navBarColor = [UIColor whiteColor];
            
            // Load intro and step css from the css folder.        
            self.introCSS    = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ifixit_intro" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];
            self.stepCSS     = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ifixit_step" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            self.moreInfoCSS = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
                ? [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_ipad" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil]
                : [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_iphone" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            break;
        case ConfigZeal:
            self.backgroundColor = [UIColor blackColor];
            self.textColor = [UIColor whiteColor];
            self.toolbarColor = [UIColor blackColor];
            self.buttonColor = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? [UIColor colorWithRed:0.0f green:113/255.0f blue:206.0/255.0f alpha:1.0] : self.toolbarColor;
            self.navBarColor = [UIColor blackColor];
            
            // Load intro and step css from the css folder.        
            self.introCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ifixit_intro" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];
            self.stepCSS  = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ifixit_step" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            self.moreInfoCSS = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
                ? [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_ipad" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil]
                : [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_iphone" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
            break;
         default:
              self.backgroundColor = [UIColor blackColor];
              self.textColor = [UIColor whiteColor];
              self.toolbarColor = [UIColor blackColor];
              self.buttonColor = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? [UIColor colorWithRed:0.0f green:113/255.0f blue:206.0/255.0f alpha:1.0] : self.toolbarColor;
              self.navBarColor = [UIColor whiteColor];
              
              // Load intro and step css from the css folder.
              self.introCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ifixit_intro" ofType:@"css"] encoding:NSUTF8StringEncoding error:nil];
              self.stepCSS  = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ifixit_step" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
              self.moreInfoCSS = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
              ? [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_ipad" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil]
              : [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"category_more_info_iphone" ofType:@"css"]  encoding:NSUTF8StringEncoding error:nil];
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
