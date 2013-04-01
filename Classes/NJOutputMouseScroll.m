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
              @"speed": @(_speed),
              @"smooth": @(_smooth),
              };
}

+ (NJOutput *)outputWithSerialization:(NSDictionary *)serialization {
    NJOutputMouseScroll *output = [[NJOutputMouseScroll alloc] init];
    output.direction = [serialization[@"direction"] intValue];
    output.speed = [serialization[@"speed"] floatValue];
    output.smooth = [serialization[@"smooth"] boolValue];
    return output;
}

- (BOOL)isContinuous {
    return _smooth;
}

- (int)wheel:(int)n {
    int amount =  abs(_direction) == n ? _direction / n : 0;
    if (self.smooth)
        amount *= _speed * self.magnitude;
    return amount;
}

- (void)trigger {
    if (!_smooth) {
        CGEventRef scroll = CGEventCreateScrollWheelEvent(NULL,
                                                          kCGScrollEventUnitLine,
                                                          2,
                                                          [self wheel:1],
                                                          [self wheel:2]);
        CGEventPost(kCGHIDEventTap, scroll);
        CFRelease(scroll);
    }
}

- (BOOL)update:(NJInputController *)ic {
    if (self.magnitude < 0.05f)
        return NO; // dead zone
    
    CGEventRef scroll = CGEventCreateScrollWheelEvent(NULL,
                                                      kCGScrollEventUnitPixel,
                                                      2,
                                                      [self wheel:1],
                                                      [self wheel:2]);
    CGEventPost(kCGHIDEventTap, scroll);
    CFRelease(scroll);

    return YES;
}

@end
