//
//  TargetMouseScroll.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TargetMouseScroll.h"

@implementation TargetMouseScroll

@synthesize howMuch;

+ (NSString *)serializationCode {
    return @"mscroll";
}

- (NSDictionary *)serialize {
    return @{ @"type": @"mscroll", @"howMuch": @(self.howMuch) };
}

+ (Target *)targetDeserialize:(NSDictionary *)serialization
                  withConfigs:(NSArray *)configs {
	TargetMouseScroll *target = [[TargetMouseScroll alloc] init];
    target.howMuch = [serialization[@"howMuch"] intValue];
	return target;
}
-(void) trigger {
    CGEventRef scroll = CGEventCreateScrollWheelEvent(NULL,
                                                      kCGScrollEventUnitLine,
                                                      1,
                                                      self.howMuch);
    CGEventPost(kCGHIDEventTap, scroll);
    CFRelease(scroll);
}

@end
