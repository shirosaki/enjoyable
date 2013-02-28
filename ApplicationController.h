//
//  ApplicationController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class JoystickController;
@class TargetController;
@class ConfigsController;

@interface ApplicationController : NSObject {
    IBOutlet NSDrawer *drawer;
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSToolbarItem *activeButton;
    IBOutlet NSMenuItem *activeMenuItem;
    IBOutlet NSMenu *dockMenuBase;
}

@property (strong) IBOutlet JoystickController *jsController;
@property (strong) IBOutlet TargetController *targetController;
@property (strong) IBOutlet ConfigsController *configsController;

- (IBAction)toggleActivity:(id)sender;
- (void)configsChanged;
- (void)configChanged;

@end
