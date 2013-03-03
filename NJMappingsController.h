//
//  NJMappingsController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class NJMapping;
@class TargetController;

@interface NJMappingsController : NSObject <NSTableViewDataSource,
                                            NSTableViewDelegate,
                                            NSOpenSavePanelDelegate> {
    IBOutlet NSButton *removeButton;
    IBOutlet NSTableView *tableView;
    IBOutlet TargetController *targetController;
}

@property (nonatomic, readonly) NJMapping *currentMapping;
@property (nonatomic, readonly) NSArray *mappings;

- (NJMapping *)objectForKeyedSubscript:(NSString *)name;


- (IBAction)addPressed:(id)sender;
- (IBAction)removePressed:(id)sender;
- (IBAction)importPressed:(id)sender;
- (IBAction)exportPressed:(id)sender;
- (void)activateMapping:(NJMapping *)mapping;
- (void)activateMappingForProcess:(NSString *)processName;

- (void)save;
- (void)load;

@end
