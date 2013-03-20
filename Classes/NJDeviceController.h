//
//  NJDeviceController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "NJHIDManager.h"

@class NJDevice;
@class NJInput;
@class NJInputPathElement;
@class NJMappingsController;

@protocol NJDeviceControllerDelegate;

@interface NJDeviceController : NSObject <NJHIDManagerDelegate> {
    IBOutlet NJMappingsController *mappingsController;
}

@property (nonatomic, weak) IBOutlet id <NJDeviceControllerDelegate> delegate;

@property (nonatomic, assign) NSPoint mouseLoc;
@property (nonatomic, assign) BOOL simulatingEvents;
@property (nonatomic, readonly) NSArray *devices;

- (NJInputPathElement *)elementForUID:(NSString *)uid;

@end

@protocol NJDeviceControllerDelegate

- (void)deviceController:(NJDeviceController *)dc didAddDevice:(NJDevice *)device;
- (void)deviceController:(NJDeviceController *)dc didRemoveDeviceAtIndex:(NSInteger)idx;
- (void)deviceController:(NJDeviceController *)dc didInput:(NJInput *)input;
- (void)deviceControllerDidStartHID:(NJDeviceController *)dc;
- (void)deviceControllerDidStopHID:(NJDeviceController *)dc;
- (void)deviceController:(NJDeviceController *)dc didError:(NSError *)error;

@end
