//
//  EnjoyableApplicationDelegate.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "NJMappingMenuController.h"
#import "NJMappingsViewController.h"
#import "NJDeviceViewController.h"
#import "NJOutputViewController.h"
#import "NJInputController.h"

@interface EnjoyableApplicationDelegate : NSObject <NSApplicationDelegate,
                                                    NJInputControllerDelegate,
                                                    NJDeviceViewControllerDelegate,
                                                    NJMappingsViewControllerDelegate,
                                                    NJOutputViewControllerDelegate,
                                                    NJMappingMenuDelegate,
                                                    NSWindowDelegate>

@property (nonatomic, strong) IBOutlet NJInputController *ic;
@property (nonatomic, strong) IBOutlet NJOutputViewController *oc;
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
