//
//  NJOutputMouseScroll.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/28/12.
//

#import "NJOutputMouseScroll.h"

@implementation NJOutputMouseScroll

+ (NSString *)serializationCode {
    return @"mouse scroll";
}

- (NSDictionary *)serialize {
    return @{ @"type": self.class.serializationCode,
              @"direction": @(_direction),
              @"speed": @(_speed)
              };
}

+ (NJOutput *)outputDeserialize:(NSDictionary *)serialization
                  withMappings:(NSArray *)mappings {
    NJOutputMouseScroll *output = [[NJOutputMouseScroll alloc] init];
    output.direction = [serialization[@"direction"] intValue];
    output.speed = [serialization[@"direction"] floatValue];
    return output;
}

- (BOOL)isContinuous {
    return !!self.speed;
}

- (void)trigger {
    if (!self.speed) {
        CGEventRef scroll = CGEventCreateScrollWheelEvent(NULL,
                                                          kCGScrollEventUnitLine,
                                                          1,
                                                          _direction);
        CGEventPost(kCGHIDEventTap, scroll);
        CFRelease(scroll);
    }
}

- (BOOL)update:(NJDeviceController *)jc {
    if (self.magnitude < 0.05f)
        return NO; // dead zone
    
    int amount = (int)(_speed * self.magnitude * _direction);
    CGEventRef scroll = CGEventCreateScrollWheelEvent(NULL,
                                                      kCGScrollEventUnitPixel,
                                                      1,
                                                      amount);
    CGEventPost(kCGHIDEventTap, scroll);
    CFRelease(scroll);

    return YES;
}

@end
