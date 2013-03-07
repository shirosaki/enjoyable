//
//  NJDevice.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "NJInputPathElement.h"

@class NJInput;

@interface NJDevice : NSObject <NJInputPathElement>

@property (nonatomic, assign) int index;
@property (nonatomic, copy) NSString *productName;
@property (nonatomic, assign) IOHIDDeviceRef device;
@property (nonatomic, copy) NSArray *children;
@property (nonatomic, readonly) NSString *name;
@property (readonly) NSString *uid;

- (id)initWithDevice:(IOHIDDeviceRef)device;
- (NJInput *)handlerForEvent:(IOHIDValueRef)value;
- (NJInput *)inputForEvent:(IOHIDValueRef)value;

@end
