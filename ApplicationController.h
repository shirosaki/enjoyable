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

@interface ApplicationController : NSObject <NSApplicationDelegate> {
    IBOutlet NSDrawer *drawer;
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSToolbarItem *activeButton;
    IBOutlet NSMenuItem *activeMenuItem;
    IBOutlet NSMenu *dockMenuBase;
}

@property (nonatomic, strong) IBOutlet JoystickController *jsController;
@property (nonatomic, strong) IBOutlet TargetController *targetController;
@property (nonatomic, strong) IBOutlet ConfigsController *configsController;

- (IBAction)toggleActivity:(id)sender;
- (void)configsChanged;
- (void)configChanged;

@end
