//
//  NJDeviceController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class NJDevice;
@class NJInput;
@class NJMappingsController;
@class NJOutputController;

@interface NJDeviceController : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate> {
    IBOutlet NSOutlineView *outlineView;
    IBOutlet NJOutputController *outputController;
    IBOutlet NJMappingsController *mappingsController;
    IBOutlet NSButton *translatingEventsButton;
    IBOutlet NSView *connectDevicePrompt;
    IBOutlet NSView *hidSleepingPrompt;
}

@property (nonatomic, readonly) NJInput *selectedInput;
@property (nonatomic, assign) NSPoint mouseLoc;
@property (nonatomic, assign) BOOL translatingEvents;

- (IBAction)translatingEventsChanged:(NSButton *)sender;

@end
