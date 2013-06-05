//
//  Utils.m
//  iFixit
//
//  Created by Stefan Ayala on 5/28/13.
//
//

#import "Utils.h"
#import "Config.h"

@implementation Utils

+(NSURLRequest*)buildCategoryWebViewURL:(NSString*)category webViewType:(NSString*)type {
    NSString *urlString = ([type isEqualToString:@"info"])
        ? [NSString stringWithFormat:@"http://%@/c/%@", [Config currentConfig].host, category]
        : [NSString stringWithFormat:@"http://%@/Answers/Device/%@", [Config currentConfig].host, category];
    
    NSURL *URL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    return [NSURLRequest requestWithURL:URL];
}

+ (void)showLoading:(UINavigationItem*)navigationItem {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 20.0f)];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [container addSubview:spinner];
    [spinner startAnimating];
    [spinner release];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:container];
    navigationItem.rightBarButtonItem = button;
    [container release];
    [button release];
}
@end
