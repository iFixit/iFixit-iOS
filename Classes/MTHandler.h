//
//  MTHandler.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MTHandler : NSObject {
	id object;
	SEL selector;
}

@property (nonatomic, retain) id object;
@property (nonatomic) SEL selector;

+ (MTHandler *)initForObject:(id)object withSelector:(SEL)selector;

@end
