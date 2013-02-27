//
//  JSAction.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "JSAction.h"

@implementation JSAction

@synthesize cookie;
@synthesize index;
@synthesize children;
@synthesize base;
@synthesize name;

- (id)findSubActionForValue:(IOHIDValueRef)value {
    return NULL;
}

- (NSString *)stringify {
    return [NSString stringWithFormat: @"%@~%p", [base stringify], cookie];
}

- (void)notifyEvent:(IOHIDValueRef)value {
    [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)active {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

@end
