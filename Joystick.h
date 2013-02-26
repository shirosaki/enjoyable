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
@property (readonly) NSArray *children;
@property (readonly) NSString *name;

-(void) populateActions;
-(id) handlerForEvent: (IOHIDValueRef) value;
-(id)initWithDevice: (IOHIDDeviceRef) newDevice;
-(JSAction*) actionForEvent: (IOHIDValueRef) value;

@end
