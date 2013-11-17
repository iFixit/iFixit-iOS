//
//  CategoriesSingleton.h
//  iFixit
//
//  Created by Stefan Ayala on 7/8/13.
//
//

#import <Foundation/Foundation.h>

@interface CategoriesSingleton : NSObject

@property (nonatomic, retain) NSDictionary *masterCategoryList;
@property (nonatomic, retain) NSDictionary *masterDisplayTitleList;

+(CategoriesSingleton*)sharedInstance;
@end
