//
//  EnjoyableApplicationDelegate.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class NJDeviceController;
@class NJOutputController;
@class NJMappingsController;

@interface EnjoyableApplicationDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSMenu *dockMenuBase;
    IBOutlet NSWindow *window;
}

@property (nonatomic, strong) IBOutlet NJDeviceController *inputController;
@property (nonatomic, strong) IBOutlet NJMappingsController *mappingsController;

@end
