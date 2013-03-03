//
//  TargetController.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "NJKeyInputField.h"

@class NJMappingsController;
@class NJInputController;
@class Target;
@class TargetMouseMove;

@interface TargetController : NSObject <NJKeyInputFieldDelegate> {
    IBOutlet NJKeyInputField *keyInput;
    IBOutlet NSMatrix *radioButtons;
    IBOutlet NSSegmentedControl *mouseDirSelect;
    IBOutlet NSSegmentedControl *mouseBtnSelect;
    IBOutlet NSSegmentedControl *scrollDirSelect;
    IBOutlet NSTextField *title;
    IBOutlet NSPopUpButton *mappingPopup;
    IBOutlet NJMappingsController *mappingsController;
    IBOutlet NJInputController *joystickController;
}

@property (assign) BOOL enabled;

- (void)loadCurrent;
- (void)refreshMappings;
- (IBAction)radioChanged:(id)sender;
- (IBAction)mdirChanged:(id)sender;
- (IBAction)mbtnChanged:(id)sender;
- (IBAction)sdirChanged:(id)sender;
- (void)focusKey;

@end
