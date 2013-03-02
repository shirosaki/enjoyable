//
//  JSAction.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "JSAction.h"

@implementation JSAction

- (id)initWithName:(NSString *)newName base:(id <NJActionPathElement>)newBase {
    if ((self = [super init])) {
        self.name = newName;
        self.base = newBase;
    }
    return self;
}

- (id)findSubActionForValue:(IOHIDValueRef)value {
    return NULL;
}

- (NSString *)uid {
    return [NSString stringWithFormat:@"%@~%@", [_base uid], _name];
}

- (void)notifyEvent:(IOHIDValueRef)value {
    [self doesNotRecognizeSelector:_cmd];
}

- (float)magnitude {
    return 0.f;
}

@end
