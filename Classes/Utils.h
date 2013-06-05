//
//  Utils.h
//  iFixit
//
//  Created by Stefan Ayala on 5/28/13.
//
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+(void)showLoading:(UINavigationItem*)navigationItem;
+(NSURLRequest*)buildCategoryWebViewURL:(NSString*)category webViewType:(NSString*)type;

@end
