//
//  EnjoyableApplicationDelegate.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class NJDeviceController;
@class NJMappingsController;

@interface EnjoyableApplicationDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSMenu *dockMenu;
    IBOutlet NSMenu *statusItemMenu;
    IBOutlet NSMenu *mappingsMenu;
    IBOutlet NSWindow *window;
}

@property (nonatomic, strong) IBOutlet NJDeviceController *inputController;
@property (nonatomic, strong) IBOutlet NJMappingsController *mappingsController;

- (IBAction)restoreToForeground:(id)sender;

@end
