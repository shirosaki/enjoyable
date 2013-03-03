//
//  NJOutputMouseScroll.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/28/12.
//

#import "NJOutputMouseScroll.h"

@implementation NJOutputMouseScroll {
    int sign;
}

+ (NSString *)serializationCode {
    return @"mouse scroll";
}

- (NSDictionary *)serialize {
    return @{ @"type": @"mouse scroll", @"amount": @(_amount) };
}

+ (NJOutput *)outputDeserialize:(NSDictionary *)serialization
                  withMappings:(NSArray *)mappings {
	NJOutputMouseScroll *output = [[NJOutputMouseScroll alloc] init];
    output.amount = [serialization[@"amount"] intValue];
	return output;
}

- (void)trigger {
    if (!self.magnitude) {
        CGEventRef scroll = CGEventCreateScrollWheelEvent(NULL,
                                                          kCGScrollEventUnitLine,
                                                          1,
                                                          _amount);
        CGEventPost(kCGHIDEventTap, scroll);
        CFRelease(scroll);
    }
}

- (BOOL)update:(NJDeviceController *)jc {
    if (fabsf(self.magnitude) < 0.01f) {
        sign = 0;
        return NO; // dead zone
    }
    
    // If the input crossed over High/Low, this output is done.
    if (!sign)
        sign = self.magnitude < 0 ? -1 : 1;
    else if (sign / self.magnitude < 0) {
        sign = 0;
        return NO;
    }

    int amount = (int)(16.f * fabsf(self.magnitude) * _amount);
    CGEventRef scroll = CGEventCreateScrollWheelEvent(NULL,
                                                      kCGScrollEventUnitPixel,
                                                      1,
                                                      amount);
    CGEventPost(kCGHIDEventTap, scroll);
    CFRelease(scroll);

    return YES;
}

- (BOOL)isContinuous {
    return YES;
}

@end
