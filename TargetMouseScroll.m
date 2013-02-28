//
//  TargetMouseScroll.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TargetMouseScroll.h"

@implementation TargetMouseScroll

@synthesize amount;

+ (NSString *)serializationCode {
    return @"mscroll";
}

- (NSDictionary *)serialize {
    return @{ @"type": @"mscroll", @"amount": @(self.amount) };
}

+ (Target *)targetDeserialize:(NSDictionary *)serialization
                  withConfigs:(NSArray *)configs {
	TargetMouseScroll *target = [[TargetMouseScroll alloc] init];
    target.amount = [serialization[@"amount"] intValue];
	return target;
}
-(void) trigger {
    CGEventRef scroll = CGEventCreateScrollWheelEvent(NULL,
                                                      kCGScrollEventUnitLine,
                                                      1,
                                                      self.amount);
    CGEventPost(kCGHIDEventTap, scroll);
    CFRelease(scroll);
}

@end
