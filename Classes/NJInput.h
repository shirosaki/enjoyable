//
//  NJInput.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "NJInputPathElement.h"

@interface NJInput : NJInputPathElement

- (id)initWithName:(NSString *)name
               did:(NSString *)did
            cookie:(IOHIDElementCookie)cookie
              base:(NJInputPathElement *)base;

@property (nonatomic, assign) IOHIDElementCookie cookie;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) float magnitude;

- (void)notifyEvent:(IOHIDValueRef)value;
- (id)findSubInputForValue:(IOHIDValueRef)value;

@end
