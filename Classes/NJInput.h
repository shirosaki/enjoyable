//
//  NJInput.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "NJInputPathElement.h"

@interface NJInput : NJInputPathElement

#define NJINPUT_EID(name, index) [[NSString alloc] initWithFormat:@"%s %d", name, index]
#define NJINPUT_NAME(name, index) [[NSString alloc] initWithFormat:name, index]

- (id)initWithName:(NSString *)name
               eid:(NSString *)eid
           element:(IOHIDElementRef)element
            parent:(NJInputPathElement *)parent;

@property (nonatomic, readonly) IOHIDElementCookie cookie;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) float magnitude;

- (void)notifyEvent:(IOHIDValueRef)value;
- (id)findSubInputForValue:(IOHIDValueRef)value;

@end
