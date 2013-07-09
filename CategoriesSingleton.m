//
//  CategoriesSingleton.m
//  iFixit
//
//  Created by Stefan Ayala on 7/8/13.
//
//

#import "CategoriesSingleton.h"

@implementation CategoriesSingleton

+(CategoriesSingleton*)sharedInstance{
    static dispatch_once_t pred;
    static CategoriesSingleton *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[CategoriesSingleton alloc] init];
    });
    return shared;
}

@end
