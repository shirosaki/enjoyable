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

@interface JoystickController : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate> {
	IBOutlet NSOutlineView *outlineView;
	IBOutlet TargetController *targetController;
	IBOutlet ConfigsController *configsController;
}

- (void)setup;
- (Joystick *)findJoystickByRef:(IOHIDDeviceRef)device;

@property (nonatomic, readonly) JSAction *selectedAction;
@property (nonatomic, assign) NSPoint mouseLoc;
@property (nonatomic, assign) BOOL frontWindowOnly;
@property (nonatomic, assign) BOOL sendingRealEvents;

@end
