//
//  Joystick.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "NJActionPathElement.h"

@class JSAction;

@interface Joystick : NSObject <NJActionPathElement>

@property (nonatomic, assign) int index;
@property (nonatomic, copy) NSString *productName;
@property (nonatomic, assign) IOHIDDeviceRef device;
@property (nonatomic, copy) NSArray *children;
@property (nonatomic, readonly) NSString *name;
@property (readonly) NSString *uid;

- (id)initWithDevice:(IOHIDDeviceRef)device;
- (JSAction *)handlerForEvent:(IOHIDValueRef)value;
- (JSAction *)actionForEvent:(IOHIDValueRef)value;

@end
