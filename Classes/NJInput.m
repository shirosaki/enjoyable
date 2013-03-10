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

@end
