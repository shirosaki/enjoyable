//
//  EnjoyableApplicationDelegate.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class NJMappingsController;

#import "NJMappingMenuController.h"
#import "NJMappingsViewController.h"
#import "NJDeviceViewController.h"
#import "NJOutputController.h"
#import "NJInputController.h"

@interface EnjoyableApplicationDelegate : NSObject <NSApplicationDelegate,
                                                    NJInputControllerDelegate,
                                                    NJDeviceViewControllerDelegate,
                                                    NJMappingsViewControllerDelegate,
                                                    NJMappingMenuDelegate,
                                                    NSWindowDelegate>

@property (nonatomic, strong) IBOutlet NJInputController *inputController;
@property (nonatomic, strong) IBOutlet NJOutputController *outputController;
@property (nonatomic, strong) IBOutlet NJMappingsViewController *mvc;
@property (nonatomic, strong) IBOutlet NJDeviceViewController *dvc;

@property (nonatomic, strong) IBOutlet NSMenu *dockMenu;
@property (nonatomic, strong) IBOutlet NSMenu *statusItemMenu;
@property (nonatomic, strong) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSButton *simulatingEventsButton;

- (IBAction)restoreToForeground:(id)sender;
- (IBAction)importMappingClicked:(id)sender;
- (IBAction)exportMappingClicked:(id)sender;
- (IBAction)simulatingEventsChanged:(NSButton *)sender;

@end
