//
//  JSActionButton.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "JSActionButton.h"

@implementation JSActionButton {
    int _max;
}

- (id)initWithName:(NSString *)name idx:(int)idx max:(int)max {
    if ((self = [super init])) {
        _max = max;
        if (name.length)
            self.name = [NSString stringWithFormat:@"Button %d - %@", idx, name];
        else
            self.name = [NSString stringWithFormat:@"Button %d", idx];
    }
    return self;
}

- (id)findSubActionForValue:(IOHIDValueRef)val {
    return (IOHIDValueGetIntegerValue(val) == _max) ? self : nil;
}

- (void)notifyEvent:(IOHIDValueRef)value {
    self.active = IOHIDValueGetIntegerValue(value) == _max;
}

@end
