//
//  NJInput.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "NJInput.h"

@implementation NJInput

- (id)initWithName:(NSString *)newName base:(id <NJInputPathElement>)newBase {
    if ((self = [super init])) {
        self.name = newName;
        self.base = newBase;
    }
    return self;
}

- (id)findSubInputForValue:(IOHIDValueRef)value {
    return nil;
}

- (NSString *)uid {
    return [NSString stringWithFormat:@"%@~%@", _base.uid, _name];
}

- (void)notifyEvent:(IOHIDValueRef)value {
    [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:NJInput.class]
        && [[object uid] isEqualToString:self.uid];
}

- (NSUInteger)hash {
    return self.uid.hash;
}

- (id <NJInputPathElement>)elementForUID:(NSString *)uid {
    if ([uid isEqualToString:self.uid])
        return self;
    else {
        for (id <NJInputPathElement> elem in self.children) {
            id <NJInputPathElement> ret = [elem elementForUID:uid];
            if (ret)
                return ret;
        }
    }
    return nil;
}

@end
