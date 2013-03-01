//
//  ConfigsController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class Config;
@class TargetController;

@interface ConfigsController : NSObject <NSTableViewDataSource, NSTableViewDelegate, NSOpenSavePanelDelegate> {
    IBOutlet NSButton *removeButton;
    IBOutlet NSTableView *tableView;
    IBOutlet TargetController *targetController;
    IBOutlet NSButton *exportButton;
}

@property (readonly) Config *currentConfig;
@property (readonly) NSArray *configs;

- (IBAction)addPressed:(id)sender;
- (IBAction)removePressed:(id)sender;
- (IBAction)exportPressed:(id)sender;
- (void)activateConfig:(Config *)config;
- (void)activateConfigForProcess:(NSString *)processName;

- (void)save;
- (void)load;

@end
