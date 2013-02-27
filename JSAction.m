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
@synthesize active;

- (id)initWithName:(NSString *)newName base:(JSAction *)newBase {
    if ((self = [super init])) {
        self.name = newName;
        self.base = newBase;
    }
    return self;
}

- (id)findSubActionForValue:(IOHIDValueRef)value {
    return NULL;
}

- (NSString *)stringify {
    if (cookie)
        return [NSString stringWithFormat: @"%@~%p", [base stringify], cookie];
    else
        return [NSString stringWithFormat: @"%@~%@", [base stringify], name];
}

- (void)notifyEvent:(IOHIDValueRef)value {
    [self doesNotRecognizeSelector:_cmd];
}

- (float)magnitude {
    return 0.f;
}

@end
