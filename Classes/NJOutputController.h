//
//  NJOutputController.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "NJKeyInputField.h"

@class NJMappingsController;
@class NJDeviceController;
@class NJOutput;
@class NJOutputMouseMove;

@interface NJOutputController : NSObject <NJKeyInputFieldDelegate> {
    IBOutlet NJKeyInputField *keyInput;
    IBOutlet NSMatrix *radioButtons;
    IBOutlet NSSegmentedControl *mouseDirSelect;
    IBOutlet NSSlider *mouseSpeedSlider;
    IBOutlet NSSegmentedControl *mouseBtnSelect;
    IBOutlet NSSegmentedControl *scrollDirSelect;
    IBOutlet NSSlider *scrollSpeedSlider;
    IBOutlet NSTextField *title;
    IBOutlet NSPopUpButton *mappingPopup;
    IBOutlet NJMappingsController *mappingsController;
    IBOutlet NJDeviceController *inputController;
    IBOutlet NSButton *smoothCheck;
}

@property (assign) BOOL enabled;

- (void)loadCurrent;
- (IBAction)radioChanged:(id)sender;
- (IBAction)mdirChanged:(id)sender;
- (IBAction)mbtnChanged:(id)sender;
- (IBAction)sdirChanged:(id)sender;
- (IBAction)mouseSpeedChanged:(id)sender;
- (IBAction)scrollSpeedChanged:(id)sender;
- (IBAction)scrollTypeChanged:(id)sender;

- (void)focusKey;

@end
