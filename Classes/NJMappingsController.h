//
//  NJMappingsController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class NJMapping;
@class NJOutputController;

#import "NJMappingsViewController.h"

@interface NJMappingsController : NSObject <NSFastEnumeration,
                                            NJMappingsViewControllerDelegate>

@property (nonatomic, readonly) NJMapping *currentMapping;
@property (nonatomic, strong) IBOutlet NJMappingsViewController *mvc;

- (NJMapping *)objectForKeyedSubscript:(NSString *)name;
- (NJMapping *)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)activateMapping:(NJMapping *)mapping;
- (void)activateMappingForProcess:(NSRunningApplication *)app;
- (void)addOrMergeMapping:(NJMapping *)mapping;
- (void)save;
- (void)load;

@end
