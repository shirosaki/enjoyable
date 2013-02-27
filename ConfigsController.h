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
	NSMutableArray* configs;
	IBOutlet NSButton* removeButton;
	IBOutlet NSTableView* tableView;
	IBOutlet TargetController* targetController;
	Config* currentConfig;
	Config* neutralConfig; /* last config to be manually selected */
}

-(IBAction) addPressed: (id)sender;
-(IBAction) removePressed: (id)sender;
-(void) activateConfig: (Config*)config forApplication: (ProcessSerialNumber*) psn;

-(NSDictionary*) dumpAll;
-(void) loadAllFrom: (NSDictionary*) dict;

@property(strong, readonly) Config* currentConfig;
@property(strong, readonly) Config* currentNeutralConfig;
@property(readonly) NSArray* configs;

-(void) save;
-(void) load;

-(void) applicationSwitchedTo: (NSString*) name withPsn: (ProcessSerialNumber) psn;	

@end
