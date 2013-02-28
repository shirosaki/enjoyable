//
//  JSActionAnalog.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

// TODO: Dead zone should be configurable per-device.
#define DEAD_ZONE 0.3

#import "JSActionAnalog.h"

static float normalize(int p, int min, int max) {
    return 2 * (p - min) / (float)(max - min) - 1;
}

@implementation JSActionAnalog {
    float magnitude;
    int rawMin;
    int rawMax;
}

- (id)initWithIndex:(int)index rawMin:(int)rawMin_ rawMax:(int)rawMax_ {
    if ((self = [super init])) {
        self.name = [[NSString alloc] initWithFormat: @"Axis %d", index];
        self.children = @[[[JSAction alloc] initWithName:@"Low" base:self],
                          [[JSAction alloc] initWithName:@"High" base:self]];
        rawMax = rawMax_;
        rawMin = rawMin_;
    }
    return self;
}

- (id)findSubActionForValue:(IOHIDValueRef)value {
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
    [self.children[0] setActive:magnitude < -DEAD_ZONE];
    [self.children[1] setActive:magnitude > DEAD_ZONE];
}

- (float)magnitude {
    return magnitude;
}

@end
