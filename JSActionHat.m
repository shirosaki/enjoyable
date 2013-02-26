//
//  JSActionHat.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

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

@implementation JSActionHat

- (id)init {
    if ((self = [super init])) {
        self.subActions = @[[[SubAction alloc] initWithIndex: 0 name: @"Up" base: self],
                            [[SubAction alloc] initWithIndex: 1 name: @"Down" base: self],
                            [[SubAction alloc] initWithIndex: 2 name: @"Left" base: self],
                            [[SubAction alloc] initWithIndex: 3 name: @"Right" base: self]];
        // TODO(jfw): Should have an indexed name, like everything else.
        self.name = @"Hat switch";
    }
    return self;
}

- (id)findSubActionForValue:(IOHIDValueRef)value {
    int parsed = IOHIDValueGetIntegerValue(value);
    switch (IOHIDElementGetLogicalMax(IOHIDValueGetElement(value))) {
        case 7: // 8-way switch, 0-7.
            switch (parsed) {
                case 0: return self.subActions[0];
                case 4: return self.subActions[1];
                case 6: return self.subActions[2];
                case 2: return self.subActions[3];
                default: return nil;
            }
        case 8: // 8-way switch, 1-8 (neutral 0).
            switch (parsed) {
                case 1: return self.subActions[0];
                case 5: return self.subActions[1];
                case 7: return self.subActions[2];
                case 3: return self.subActions[3];
                default: return nil;
            }
        case 3: // 4-way switch, 0-3.
            switch (parsed) {
                case 0: return self.subActions[0];
                case 2: return self.subActions[1];
                case 3: return self.subActions[2];
                case 1: return self.subActions[3];
                default: return nil;
            }
        case 4: // 4-way switch, 1-4 (neutral 0).
            switch (parsed) {
                case 1: return self.subActions[0];
                case 3: return self.subActions[1];
                case 4: return self.subActions[2];
                case 2: return self.subActions[3];
                default: return nil;
            }
        default:
            return nil;
    }
}

- (void)notifyEvent:(IOHIDValueRef)value {
    int parsed = IOHIDValueGetIntegerValue(value);
    int size = IOHIDElementGetLogicalMax(IOHIDValueGetElement(value));
    // Skip first row in table if 0 is not neutral.
    if (size & 1) {
        parsed++;
        size++;
    }
    BOOL *activeSubactions = (size == 8) ? active_eightway : active_fourway;
    for (int i = 0; i < 4; i++)
        [self.subActions[i] setActive:activeSubactions[parsed * 4 + i]];
}

@end
