//
//  Joystick.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class JSAction;

@interface Joystick : NSObject

@property (assign) int vendorId;
@property (assign) int productId;
@property (assign) int index;
@property (copy) NSString *productName;
@property (assign) IOHIDDeviceRef device;
@property (copy) NSArray *children;
@property (readonly) NSString *name;

- (id)initWithDevice:(IOHIDDeviceRef)device;
- (id)handlerForEvent:(IOHIDValueRef)value;
- (JSAction *)actionForEvent:(IOHIDValueRef)value;

@end
