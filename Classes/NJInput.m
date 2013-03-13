//
//  NJInput.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "NJInput.h"

@implementation NJInput

- (id)initWithName:(NSString *)name
               did:(NSString *)did
            cookie:(IOHIDElementCookie)cookie
              base:(NJInputPathElement *)base {
    if ((self = [super initWithName:name did:did base:base])) {
        self.cookie = cookie;
    }
    return self;
}

- (id)findSubInputForValue:(IOHIDValueRef)value {
    return nil;
}

- (void)notifyEvent:(IOHIDValueRef)value {
    [self doesNotRecognizeSelector:_cmd];
}

@end
