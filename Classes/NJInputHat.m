//
//  NJInputHat.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "NJInputHat.h"

static BOOL active_eightway[36] = {
    NO,  NO,  NO,  NO , // center
    YES, NO,  NO,  NO , // N
    YES, NO,  NO,  YES, // NE
    NO,  NO,  NO,  YES, // E
    NO,  YES, NO,  YES, // SE
    NO,  YES, NO,  NO , // S
    NO,  YES, YES, NO , // SW
    NO,  NO,  YES, NO , // W
    YES, NO,  YES, NO , // NW
};

static BOOL active_fourway[20] = {
    NO,  NO,  NO,  NO , // center
    YES, NO,  NO,  NO , // N
    NO,  NO,  NO,  YES, // E
    NO,  YES, NO,  NO , // S
    NO,  NO,  YES, NO , // W
};

@implementation NJInputHat {
    CFIndex _max;
}

- (id)initWithElement:(IOHIDElementRef)element
                index:(int)index
               parent:(NJInputPathElement *)parent
{
    if ((self = [super initWithName:NJINPUT_NAME(NSLocalizedString(@"hat switch %d", @"hat switch name"), index)
                                eid:NJINPUT_EID("Hat Switch", index)
                            element:element
                               parent:parent])) {
        self.children = @[[[NJInput alloc] initWithName:NSLocalizedString(@"hat up", @"hat switch up state")
                                                    eid:@"Up"
                                                   parent:self],
                          [[NJInput alloc] initWithName:NSLocalizedString(@"hat down", @"hat switch down state")
                                                    eid:@"Down"
                                                   parent:self],
                          [[NJInput alloc] initWithName:NSLocalizedString(@"hat left", @"hat switch left state")
                                                    eid:@"Left"
                                                   parent:self],
                          [[NJInput alloc] initWithName:NSLocalizedString(@"hat right", @"hat switch right state")
                                                    eid:@"Right"
                                                   parent:self]];
        _max = IOHIDElementGetLogicalMax(element);
    }
    return self;
}

- (id)findSubInputForValue:(IOHIDValueRef)value {
    long parsed = IOHIDValueGetIntegerValue(value);
    switch (_max) {
        case 7: // 8-way switch, 0-7.
            switch (parsed) {
                case 0: return self.children[0];
                case 4: return self.children[1];
                case 6: return self.children[2];
                case 2: return self.children[3];
                default: return nil;
            }
        case 8: // 8-way switch, 1-8 (neutral 0).
            switch (parsed) {
                case 1: return self.children[0];
                case 5: return self.children[1];
                case 7: return self.children[2];
                case 3: return self.children[3];
                default: return nil;
            }
        case 3: // 4-way switch, 0-3.
            switch (parsed) {
                case 0: return self.children[0];
                case 2: return self.children[1];
                case 3: return self.children[2];
                case 1: return self.children[3];
                default: return nil;
            }
        case 4: // 4-way switch, 1-4 (neutral 0).
            switch (parsed) {
                case 1: return self.children[0];
                case 3: return self.children[1];
                case 4: return self.children[2];
                case 2: return self.children[3];
                default: return nil;
            }
        default:
            return nil;
    }
}

- (void)notifyEvent:(IOHIDValueRef)value {
    long parsed = IOHIDValueGetIntegerValue(value);
    long size = _max;
    // Skip first row in table if 0 is not neutral.
    if (size & 1) {
        parsed++;
        size++;
    }
    BOOL *activechildren = (size == 8) ? active_eightway : active_fourway;
    for (unsigned i = 0; i < 4; i++) {
        BOOL active = activechildren[parsed * 4 + i];
        [self.children[i] setActive:active];
        [self.children[i] setMagnitude:active];
    }
}

@end
