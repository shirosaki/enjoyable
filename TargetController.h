//
//  TargetController.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class KeyInputTextView;
@class ConfigsController;
@class JoystickController;
@class Target;
@class TargetMouseMove;

@interface TargetController : NSObject {
    IBOutlet KeyInputTextView *keyInput;
    IBOutlet NSMatrix *radioButtons;
    IBOutlet NSSegmentedControl *mouseDirSelect;
    IBOutlet NSSegmentedControl *mouseBtnSelect;
    IBOutlet NSSegmentedControl *scrollDirSelect;
    IBOutlet NSTextField *title;
    IBOutlet NSPopUpButton *configPopup;
    IBOutlet ConfigsController *configsController;
    IBOutlet JoystickController *joystickController;
}

@property (assign) BOOL enabled;

- (void)keyChanged;
- (void)load;
- (void)reset;
- (void)refreshConfigsPreservingSelection:(BOOL)preserve;
- (IBAction)configChosen:(id)sender;
- (IBAction)radioChanged:(id)sender;
- (IBAction)mdirChanged:(id)sender;
- (IBAction)mbtnChanged:(id)sender;
- (IBAction)sdirChanged:(id)sender;
- (void)focusKey;

@end
