//
//  NJMappingsController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class NJMapping;
@class NJOutputController;

@interface NJMappingsController : NSObject <NSTableViewDataSource,
                                            NSTableViewDelegate,
                                            NSOpenSavePanelDelegate,
                                            NSPopoverDelegate,
                                            NSFastEnumeration>
{
    IBOutlet NSButton *removeButton;
    IBOutlet NSTableView *tableView;
    IBOutlet NSButton *popoverActivate;
    IBOutlet NSPopover *popover;
    IBOutlet NSButton *moveUp;
    IBOutlet NSButton *moveDown;
}

@property (nonatomic, readonly) NJMapping *currentMapping;

- (NJMapping *)objectForKeyedSubscript:(NSString *)name;
- (NJMapping *)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)addMappingWithContentsOfURL:(NSURL *)url;
- (void)activateMapping:(NJMapping *)mapping;
- (void)activateMappingForProcess:(NSRunningApplication *)app;
- (void)save;
- (void)load;

- (IBAction)mappingPressed:(id)sender;
- (IBAction)addPressed:(id)sender;
- (IBAction)removePressed:(id)sender;
- (IBAction)moveUpPressed:(id)sender;
- (IBAction)moveDownPressed:(id)sender;
- (IBAction)importPressed:(id)sender;
- (IBAction)exportPressed:(id)sender;

@end
