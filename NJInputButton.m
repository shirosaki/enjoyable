//
//  NJInputButton.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "NJInputButton.h"

@implementation NJInputButton {
    long _max;
}

- (id)initWithName:(NSString *)name idx:(int)idx max:(long)max {
    if ((self = [super init])) {
        _max = max;
        if (name.length)
            self.name = [NSString stringWithFormat:@"Button %d - %@", idx, name];
        else
            self.name = [NSString stringWithFormat:@"Button %d", idx];
    }
    return self;
}

- (id)findSubInputForValue:(IOHIDValueRef)val {
    return (IOHIDValueGetIntegerValue(val) == _max) ? self : nil;
}

- (void)notifyEvent:(IOHIDValueRef)value {
    self.active = IOHIDValueGetIntegerValue(value) == _max;
}

@end
