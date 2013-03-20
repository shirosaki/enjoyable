//
//  NJOutputController.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "NJKeyInputField.h"

@class NJInput;
@class NJOutput;
@class NJMapping;

@protocol NJOutputViewControllerDelegate;

@interface NJOutputViewController : NSObject <NJKeyInputFieldDelegate> {
    IBOutlet NJKeyInputField *keyInput;
    IBOutlet NSMatrix *radioButtons;
    IBOutlet NSSegmentedControl *mouseDirSelect;
    IBOutlet NSSlider *mouseSpeedSlider;
    IBOutlet NSSegmentedControl *mouseBtnSelect;
    IBOutlet NSSegmentedControl *scrollDirSelect;
    IBOutlet NSSlider *scrollSpeedSlider;
    IBOutlet NSTextField *title;
    IBOutlet NSPopUpButton *mappingPopup;
    IBOutlet NSButton *smoothCheck;
    IBOutlet NSButton *unknownMapping;
}

@property (nonatomic, weak) IBOutlet id <NJOutputViewControllerDelegate> delegate;

- (void)loadOutput:(NJOutput *)output forInput:(NJInput *)input;
- (void)focusKey;

- (IBAction)radioChanged:(id)sender;
- (IBAction)mdirChanged:(id)sender;
- (IBAction)mbtnChanged:(id)sender;
- (IBAction)sdirChanged:(id)sender;
- (IBAction)mouseSpeedChanged:(id)sender;
- (IBAction)scrollSpeedChanged:(id)sender;
- (IBAction)scrollTypeChanged:(id)sender;

@end

@protocol NJOutputViewControllerDelegate

- (NJMapping *)outputViewController:(NJOutputViewController *)ovc
                    mappingForIndex:(NSUInteger)index;
- (void)outputViewController:(NJOutputViewController *)ovc
                   setOutput:(NJOutput *)output
                    forInput:(NJInput *)input;

@end
