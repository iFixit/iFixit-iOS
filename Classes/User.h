//
//  User.h
//  iFixit
//
//  Created by David Patierno on 5/25/11.
//  Copyright 2011 iFixit. All rights reserved.
//

@interface User : NSObject

@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSNumber *iUserid;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSNumber *iImageid;
@property (nonatomic, retain) NSString *session;

+ (User *)userWithDictionary:(NSDictionary *)dict;

@end
