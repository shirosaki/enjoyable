//
//  ConfigsController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Config;
@class TargetController;

@interface ConfigsController : NSObject {
	IBOutlet NSButton *removeButton;
	IBOutlet NSTableView *tableView;
	IBOutlet TargetController *targetController;
}

- (IBAction)addPressed:(id)sender;
- (IBAction)removePressed:(id)sender;
- (void)activateConfig:(Config *)config forApplication:(ProcessSerialNumber *)psn;

- (NSDictionary *)dumpAll;
- (void)loadAllFrom:(NSDictionary*) dict;

@property (readonly) Config *currentConfig;
@property (readonly) Config *currentNeutralConfig;
@property (readonly) NSArray *configs;

- (void)save;
- (void)load;

- (void)applicationSwitchedTo:(NSString *)name withPsn:(ProcessSerialNumber)psn;

@end
