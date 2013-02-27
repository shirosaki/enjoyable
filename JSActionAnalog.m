//
//  JSActionAnalog.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

// TODO: Dead zone should be configurable per-device.
#define DEAD_ZONE 0.3

#import "JSActionAnalog.h"

@implementation JSActionAnalog {
    float magnitude;
}

@synthesize offset, scale;

- (id)initWithIndex:(int)newIndex offset:(float)offset_ scale:(float)scale_ {
    if ((self = [super init])) {
        self.children = @[[[SubAction alloc] initWithIndex:0 name:@"Low" base:self],
                          [[SubAction alloc] initWithIndex:1 name:@"High" base:self]];
        self.index = newIndex;
        self.offset = offset_;
        self.scale = scale_;
        self.name = [[NSString alloc] initWithFormat: @"Axis %d", self.index + 1];
    }
    return self;
}

- (id)findSubActionForValue:(IOHIDValueRef)value {
    int raw = IOHIDValueGetIntegerValue(value);
    float mag = offset + scale * raw;
    if (mag < -DEAD_ZONE)
        return self.children[0];
    else if (mag > DEAD_ZONE)
        return self.children[1];
    else
        return nil;
}

- (void)notifyEvent:(IOHIDValueRef)value {
    int raw = IOHIDValueGetIntegerValue(value);
    magnitude = offset + scale * raw;
    [self.children[0] setActive:magnitude < -DEAD_ZONE];
    [self.children[1] setActive:magnitude > DEAD_ZONE];
}

- (float)magnitude {
    return magnitude;
}

@end
