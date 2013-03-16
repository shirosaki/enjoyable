//
//  NJDeviceController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "NJHIDManager.h"
#import "NJDeviceViewController.h"

@class NJDevice;
@class NJInput;
@class NJMappingsController;
@class NJOutputController;
@class NJDeviceViewController;

@interface NJDeviceController : NSObject <NJDeviceViewControllerDelegate,
                                          NJHIDManagerDelegate> {
    IBOutlet NJOutputController *outputController;
    IBOutlet NJMappingsController *mappingsController;
    IBOutlet NSButton *simulatingEventsButton;
    IBOutlet NJDeviceViewController *devicesViewController;
}

@property (nonatomic, readonly) NJInput *selectedInput;
@property (nonatomic, assign) NSPoint mouseLoc;
@property (nonatomic, assign) BOOL simulatingEvents;

- (IBAction)simulatingEventsChanged:(NSButton *)sender;

@end
