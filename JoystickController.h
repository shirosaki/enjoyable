//
//  JoystickController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class Joystick;
@class JSAction;
@class ConfigsController;
@class TargetController;
@class Config;

@interface JoystickController : NSObject {
	IBOutlet NSOutlineView *outlineView;
	IBOutlet TargetController *targetController;
	IBOutlet ConfigsController *configsController;
}

- (void)setup;
- (Joystick *)findJoystickByRef:(IOHIDDeviceRef)device;

@property (readonly) Config *currentConfig;
@property (readonly) JSAction *selectedAction;
@property (readonly) NSMutableArray *joysticks;
@property (assign) NSPoint mouseLoc;
@property (assign) BOOL frontWindowOnly;
@property (assign) BOOL sendingRealEvents;

@end
