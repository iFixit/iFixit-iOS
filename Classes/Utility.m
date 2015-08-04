//
//  Utility.m
//  iFixit
//
//  Created by Stefan Ayala on 3/7/14.
//
//

#import "Utility.h"

@implementation Utility

+ (NSString *)serializeDictionary:(NSDictionary *)dictionary {
    NSError *error;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)deserializeJsonString:(NSString*)jsonString {
    NSError *error;

    return [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                           options:0
                                             error:&error];
}

+ (NSString *)getDeviceLanguage {
    return [[[NSLocale preferredLanguages] objectAtIndex:0] substringToIndex:2];
}

@end
