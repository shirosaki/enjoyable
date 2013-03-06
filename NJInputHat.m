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

@implementation NJInputHat

- (id)initWithIndex:(int)index {
    if ((self = [super init])) {
        self.children = @[[[NJInput alloc] initWithName:@"Up" base:self],
                          [[NJInput alloc] initWithName:@"Down" base:self],
                          [[NJInput alloc] initWithName:@"Left" base:self],
                          [[NJInput alloc] initWithName:@"Right" base:self]];
        self.name = [NSString stringWithFormat:@"Hat Switch %d", index];
    }
    return self;
}

- (id)findSubInputForValue:(IOHIDValueRef)value {
    long parsed = IOHIDValueGetIntegerValue(value);
    switch (IOHIDElementGetLogicalMax(IOHIDValueGetElement(value))) {
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
    long size = IOHIDElementGetLogicalMax(IOHIDValueGetElement(value));
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
