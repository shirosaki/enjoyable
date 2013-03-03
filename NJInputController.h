//
//  NJInputController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class NJDevice;
@class NJInput;
@class ConfigsController;
@class TargetController;

@interface NJInputController : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate> {
	IBOutlet NSOutlineView *outlineView;
	IBOutlet TargetController *targetController;
	IBOutlet ConfigsController *configsController;
}

- (void)setup;
- (NJDevice *)findJoystickByRef:(IOHIDDeviceRef)device;

@property (nonatomic, readonly) NJInput *selectedInput;
@property (nonatomic, assign) NSPoint mouseLoc;
@property (nonatomic, assign) BOOL frontWindowOnly;
@property (nonatomic, assign) BOOL translatingEvents;

@end
