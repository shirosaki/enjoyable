//
//  NJMappingsViewController.h
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/17/13.
//
//

@class NJMapping;
@protocol NJMappingsViewControllerDelegate;

@interface NJMappingsViewController : NSViewController <NSTableViewDataSource,
                                                        NSTableViewDelegate,
                                                        NSOpenSavePanelDelegate,
                                                        NSPopoverDelegate>

@property (nonatomic, weak) IBOutlet id <NJMappingsViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet NSButton *removeMapping;
@property (nonatomic, strong) IBOutlet NSTableView *mappingList;
@property (nonatomic, strong) IBOutlet NSButton *mappingListTrigger;
@property (nonatomic, strong) IBOutlet NSPopover *mappingListPopover;
@property (nonatomic, strong) IBOutlet NSButton *moveUp;
@property (nonatomic, strong) IBOutlet NSButton *moveDown;

- (IBAction)addClicked:(id)sender;
- (IBAction)removeClicked:(id)sender;
- (IBAction)moveUpClicked:(id)sender;
- (IBAction)moveDownClicked:(id)sender;
- (IBAction)mappingTriggerClicked:(id)sender;

- (void)addedMappingAtIndex:(NSInteger)index startEditing:(BOOL)startEditing;
- (void)removedMappingAtIndex:(NSInteger)index;
- (void)changedActiveMappingToIndex:(NSInteger)index;

- (void)reloadData;
- (void)beginUpdates;
- (void)endUpdates;

@end

@protocol NJMappingsViewControllerDelegate

- (NSInteger)numberOfMappings:(NJMappingsViewController *)dvc;
- (NJMapping *)mappingsViewController:(NJMappingsViewController *)dvc
                      mappingForIndex:(NSUInteger)idx;


- (void)mappingsViewController:(NJMappingsViewController *)mvc
          renameMappingAtIndex:(NSInteger)index
                        toName:(NSString *)name;

- (BOOL)mappingsViewController:(NJMappingsViewController *)mvc
       canMoveMappingFromIndex:(NSInteger)fromIdx
                       toIndex:(NSInteger)toIdx;
- (void)mappingsViewController:(NJMappingsViewController *)mvc
          moveMappingFromIndex:(NSInteger)fromIdx
                       toIndex:(NSInteger)toIdx;

- (BOOL)mappingsViewController:(NJMappingsViewController *)mvc
       canRemoveMappingAtIndex:(NSInteger)idx;
- (void)mappingsViewController:(NJMappingsViewController *)mvc
          removeMappingAtIndex:(NSInteger)idx;

- (BOOL)mappingsViewController:(NJMappingsViewController *)mvc
          importMappingFromURL:(NSURL *)url
                       atIndex:(NSInteger)index
                         error:(NSError **)error;
- (void)mappingsViewController:(NJMappingsViewController *)mvc
                    addMapping:(NJMapping *)mapping;

- (void)mappingsViewController:(NJMappingsViewController *)mvc
           choseMappingAtIndex:(NSInteger)idx;

@end
