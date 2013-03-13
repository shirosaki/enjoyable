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
    NSString *fullname = [NSString stringWithFormat:NSLocalizedString(@"button %d", @"button name"), idx];
    if (name.length)
        fullname = [fullname stringByAppendingFormat:@"- %@", name];
    NSString *did = [[NSString alloc] initWithFormat:@"Button %d", idx];
    if ((self = [super initWithName:fullname did:did base:nil])) {
        _max = max;
    }
    return self;
}

- (id)findSubInputForValue:(IOHIDValueRef)val {
    return (IOHIDValueGetIntegerValue(val) == _max) ? self : nil;
}

- (void)notifyEvent:(IOHIDValueRef)value {
    self.active = IOHIDValueGetIntegerValue(value) == _max;
    self.magnitude = IOHIDValueGetIntegerValue(value) / (float)_max;
}

@end
