//
//  NJDevice.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "NJInputPathElement.h"

@class NJInput;

@interface NJDevice : NJInputPathElement

- (id)initWithDevice:(IOHIDDeviceRef)device;

@property (nonatomic, assign) int index;
@property (nonatomic, assign) IOHIDDeviceRef device;

- (NJInput *)handlerForEvent:(IOHIDValueRef)value;
- (NJInput *)inputForEvent:(IOHIDValueRef)value;

@end
