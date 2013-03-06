//
//  NJInputAnalog.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#define DEAD_ZONE 0.3

#import "NJInputAnalog.h"

static float normalize(long p, long min, long max) {
    return 2 * (p - min) / (float)(max - min) - 1;
}

@implementation NJInputAnalog {
    float magnitude;
    long rawMin;
    long rawMax;
}

- (id)initWithIndex:(int)index rawMin:(long)rawMin_ rawMax:(long)rawMax_ {
    if ((self = [super init])) {
        self.name = [[NSString alloc] initWithFormat: @"Axis %d", index];
        self.children = @[[[NJInput alloc] initWithName:@"Low" base:self],
                          [[NJInput alloc] initWithName:@"High" base:self]];
        rawMax = rawMax_;
        rawMin = rawMin_;
    }
    return self;
}

- (id)findSubInputForValue:(IOHIDValueRef)value {
    float mag = normalize(IOHIDValueGetIntegerValue(value), rawMin, rawMax);
    if (mag < -DEAD_ZONE)
        return self.children[0];
    else if (mag > DEAD_ZONE)
        return self.children[1];
    else
        return nil;
}

- (void)notifyEvent:(IOHIDValueRef)value {
    magnitude = normalize(IOHIDValueGetIntegerValue(value), rawMin, rawMax);
    [self.children[0] setMagnitude:fabsf(MIN(magnitude, 0))];
    [self.children[1] setMagnitude:fabsf(MAX(magnitude, 0))];
    [self.children[0] setActive:magnitude < -DEAD_ZONE];
    [self.children[1] setActive:magnitude > DEAD_ZONE];
}

- (float)magnitude {
    return magnitude;
}

@end
