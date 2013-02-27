//
//  JSActionButton.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

@implementation JSActionButton {
    BOOL active;
}

@synthesize max;
@synthesize active;

- (id)initWithName:(NSString *)name_ idx:(int)idx max:(int)max_ {
    if ((self = [super init])) {
        self.index = idx;
        self.max = max_;
        if (name_.length)
            self.name = [NSString stringWithFormat:@"Button %d - %@", self.index, name_];
        else
            self.name = [NSString stringWithFormat:@"Button %d", self.index];
    }
    return self;
}

- (id)findSubActionForValue:(IOHIDValueRef)val {
    return (IOHIDValueGetIntegerValue(val) == max) ? self : nil;
}

- (void)notifyEvent:(IOHIDValueRef)value {
    active = IOHIDValueGetIntegerValue(value) == max;
}

@end
