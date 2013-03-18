//
//  NJMappingsController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class NJMapping;

@interface NJMappingsController : NSObject <NSFastEnumeration>

@property (nonatomic, readonly) NJMapping *currentMapping;
@property (nonatomic, readonly) NSUInteger count;

- (NJMapping *)objectForKeyedSubscript:(NSString *)name;
- (NJMapping *)objectAtIndexedSubscript:(NSUInteger)idx;
- (NSInteger)indexOfMapping:(NJMapping *)mapping;

- (void)addMapping:(NJMapping *)mapping;
- (void)insertMapping:(NJMapping *)mapping atIndex:(NSInteger)idx;
- (void)removeMappingAtIndex:(NSInteger)idx;
- (void)mergeMapping:(NJMapping *)mapping intoMapping:(NJMapping *)existing;
- (void)moveMoveMappingFromIndex:(NSInteger)fromIdx toIndex:(NSInteger)toIdx;
- (void)renameMapping:(NJMapping *)mapping to:(NSString *)name;

- (void)activateMapping:(NJMapping *)mapping;
- (void)activateMappingForProcess:(NSRunningApplication *)app;

- (void)save;
- (void)load;

@end
