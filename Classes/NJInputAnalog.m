//
//  NJInputAnalog.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#define DEAD_ZONE 0.3

#import "NJInputAnalog.h"

static float normalize(CFIndex p, CFIndex min, CFIndex max) {
    return 2 * (p - min) / (float)(max - min) - 1;
}

@implementation NJInputAnalog {
    CFIndex _rawMin;
    CFIndex _rawMax;
}

- (id)initWithElement:(IOHIDElementRef)element
                index:(int)index
               parent:(NJInputPathElement *)parent
{
    if ((self = [super initWithName:NJINPUT_NAME(NSLocalizedString(@"axis %d", @"axis name"), index)
                                eid:NJINPUT_EID("Axis", index)
                            element:element
                             parent:parent])) {
        self.children = @[[[NJInput alloc] initWithName:NSLocalizedString(@"axis low", @"axis low trigger")
                                                    eid:@"Low"
                                                   parent:self],
                          [[NJInput alloc] initWithName:NSLocalizedString(@"axis high", @"axis high trigger")
                                                    eid:@"High"
                                                   parent:self]];
        _rawMax = IOHIDElementGetPhysicalMax(element);
        _rawMin = IOHIDElementGetPhysicalMin(element);
    }
    return self;
}

- (id)findSubInputForValue:(IOHIDValueRef)value {
    float mag = normalize(IOHIDValueGetIntegerValue(value), _rawMin, _rawMax);
    if (mag < -DEAD_ZONE)
        return self.children[0];
    else if (mag > DEAD_ZONE)
        return self.children[1];
    else
        return nil;
}

- (void)notifyEvent:(IOHIDValueRef)value {
    float magnitude = self.magnitude = normalize(IOHIDValueGetIntegerValue(value), _rawMin, _rawMax);
    if (fabsf(magnitude) < DEAD_ZONE)
        magnitude = self.magnitude = 0;
    [self.children[0] setMagnitude:fabsf(MIN(magnitude, 0))];
    [self.children[1] setMagnitude:fabsf(MAX(magnitude, 0))];
    [self.children[0] setActive:magnitude < -DEAD_ZONE];
    [self.children[1] setActive:magnitude > DEAD_ZONE];
}

@end
