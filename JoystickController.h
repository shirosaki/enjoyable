//
//  JoystickController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hid/IOHIDLib.h>

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
@property (readonly) NSMutableArray *runningTargets;
@property (assign) NSPoint mouseLoc;
@property (assign) BOOL frontWindowOnly;

@end
