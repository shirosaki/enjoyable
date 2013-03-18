//
//  NJMappingsController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "NJMappingsController.h"

#import "NJMapping.h"
#import "NJMappingsController.h"
#import "NJOutput.h"
#import "NJEvents.h"

#define PB_ROW @"com.yukkurigames.Enjoyable.MappingRow"

@implementation NJMappingsController {
    NSMutableArray *_mappings;
    NJMapping *_manualMapping;
}

- (id)init {
    if ((self = [super init])) {
        _mappings = [[NSMutableArray alloc] init];
        _currentMapping = [[NJMapping alloc] initWithName:
                           NSLocalizedString(@"(default)", @"default name for first the mapping")];
        _manualMapping = _currentMapping;
        [_mappings addObject:_currentMapping];
    }
    return self;
}

- (NJMapping *)objectForKeyedSubscript:(NSString *)name {
    for (NJMapping *mapping in _mappings)
        if ([name isEqualToString:mapping.name])
            return mapping;
    return nil;
}

- (NJMapping *)objectAtIndexedSubscript:(NSUInteger)idx {
    return idx < _mappings.count ? _mappings[idx] : nil;
}

- (void)mappingsSet {
    [self postLoadProcess];
    [NSNotificationCenter.defaultCenter
        postNotificationName:NJEventMappingListChanged
                      object:self
                    userInfo:@{ NJMappingListKey: _mappings,
                                NJMappingKey: _currentMapping }];
    [self.mvc changedActiveMappingToIndex:[_mappings indexOfObjectIdenticalTo:_currentMapping]];
}

- (void)mappingsChanged {
    [self save];
    [self mappingsSet];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id [])buffer
                                    count:(NSUInteger)len {
    return [_mappings countByEnumeratingWithState:state
                                          objects:buffer
                                            count:len];
}

- (void)activateMappingForProcess:(NSRunningApplication *)app {
    NJMapping *oldMapping = _manualMapping;
    NSArray *names = app.possibleMappingNames;
    BOOL found = NO;
    for (NSString *name in names) {
        NJMapping *mapping = self[name];
        if (mapping) {
            [self activateMapping:mapping];
            found = YES;
            break;
        }
    }

    if (!found) {
        [self activateMapping:oldMapping];
        if ([oldMapping.name.lowercaseString isEqualToString:@"@application"]
            || [oldMapping.name.lowercaseString isEqualToString:
                NSLocalizedString(@"@Application", nil).lowercaseString]) {
            oldMapping.name = app.bestMappingName;
            [self mappingsChanged];
        }
    }
    _manualMapping = oldMapping;
}

- (void)activateMapping:(NJMapping *)mapping {
    if (!mapping)
        mapping = _manualMapping;
    if (mapping == _currentMapping)
        return;
    NSLog(@"Switching to mapping %@.", mapping.name);
    _manualMapping = mapping;
    _currentMapping = mapping;
    [self.mvc changedActiveMappingToIndex:[_mappings indexOfObjectIdenticalTo:_currentMapping]];
    [NSNotificationCenter.defaultCenter
         postNotificationName:NJEventMappingChanged
                       object:self
                     userInfo:@{ NJMappingKey : _currentMapping }];
}

- (void)save {
    NSLog(@"Saving mappings to defaults.");
    NSMutableArray *ary = [[NSMutableArray alloc] initWithCapacity:_mappings.count];
    for (NJMapping *mapping in _mappings)
        [ary addObject:[mapping serialize]];
    [NSUserDefaults.standardUserDefaults setObject:ary forKey:@"mappings"];
}

- (void)postLoadProcess {
    for (NJMapping *mapping in self)
        [mapping postLoadProcess:self];
}

- (void)load {
    NSUInteger selected = [NSUserDefaults.standardUserDefaults integerForKey:@"selected"];
    NSArray *storedMappings = [NSUserDefaults.standardUserDefaults arrayForKey:@"mappings"];
    NSMutableArray* newMappings = [[NSMutableArray alloc] initWithCapacity:storedMappings.count];

    for (unsigned i = 0; i < storedMappings.count; ++i) {
        NJMapping *mapping = [[NJMapping alloc] initWithSerialization:storedMappings[i]];
        [newMappings addObject:mapping];
    }
    
    
    if (newMappings.count) {
        _mappings = newMappings;
        if (selected >= newMappings.count)
            selected = 0;
        [self.mvc reloadData];
        [self activateMapping:_mappings[selected]];
        [self mappingsSet];
    }
}

- (NSInteger)indexOfMapping:(NJMapping *)mapping {
    return [_mappings indexOfObjectIdenticalTo:mapping];
}

- (void)mergeMapping:(NJMapping *)mapping intoMapping:(NJMapping *)existing {
    [existing mergeEntriesFrom:mapping];
    [self mappingsChanged];
    if (existing == _currentMapping) {
        // FIXME: Hack to trigger updates when renaming.
        _currentMapping = nil;
        NJMapping *manual = _manualMapping;
        [self activateMapping:existing];
        _manualMapping = manual;
    }
}

- (void)addMapping:(NJMapping *)mapping {
    [self insertMapping:mapping atIndex:_mappings.count];
}

- (void)insertMapping:(NJMapping *)mapping atIndex:(NSInteger)idx {
    [_mappings insertObject:mapping atIndex:idx];
    [self mappingsChanged];    
}

- (void)removeMappingAtIndex:(NSInteger)idx {
    NSInteger currentIdx = [self indexOfMapping:_currentMapping];
    [_mappings removeObjectAtIndex:idx];
    [self activateMapping:self[MIN(currentIdx, _mappings.count - 1)]];
    [self mappingsChanged];
}

- (void)moveMoveMappingFromIndex:(NSInteger)fromIdx toIndex:(NSInteger)toIdx {
    [_mappings moveObjectAtIndex:fromIdx toIndex:toIdx];
    [self mappingsChanged];
}

- (NSUInteger)count {
    return _mappings.count;
}

- (void)mappingConflictDidResolve:(NSAlert *)alert
                       returnCode:(NSInteger)returnCode
                      contextInfo:(void *)contextInfo {
    NSDictionary *userInfo = CFBridgingRelease(contextInfo);
    NJMapping *oldMapping = userInfo[@"old mapping"];
    NJMapping *newMapping = userInfo[@"new mapping"];
    [alert.window orderOut:nil];
    switch (returnCode) {
        case NSAlertFirstButtonReturn: // Merge
            [self mergeMapping:newMapping intoMapping:oldMapping];
            [self activateMapping:oldMapping];
            break;
        case NSAlertThirdButtonReturn: // New Mapping
            [self.mvc.mappingList beginUpdates];
            [self addMapping:newMapping];
            [self.mvc addedMappingAtIndex:_mappings.count - 1 startEditing:YES];
            [self.mvc.mappingList endUpdates];
            [self activateMapping:newMapping];
            break;
        default: // Cancel, other.
            break;
    }
}

- (void)promptForMapping:(NJMapping *)mapping atIndex:(NSInteger)idx {
    NSWindow *window = NSApplication.sharedApplication.keyWindow;
    NJMapping *mergeInto = self[mapping.name];
    NSAlert *conflictAlert = [[NSAlert alloc] init];
    conflictAlert.messageText = NSLocalizedString(@"import conflict prompt", @"Title of import conflict alert");
    conflictAlert.informativeText =
    [NSString stringWithFormat:NSLocalizedString(@"import conflict in %@", @"Explanation of import conflict"),
                               mapping.name];
    [conflictAlert addButtonWithTitle:NSLocalizedString(@"import and merge", @"button to merge imported mappings")];
    [conflictAlert addButtonWithTitle:NSLocalizedString(@"cancel import", @"button to cancel import")];
    [conflictAlert addButtonWithTitle:NSLocalizedString(@"import new mapping", @"button to import as new mapping")];
    [conflictAlert beginSheetModalForWindow:window
                              modalDelegate:self
                             didEndSelector:@selector(mappingConflictDidResolve:returnCode:contextInfo:)
                                contextInfo:(void *)CFBridgingRetain(@{ @"old mapping": mergeInto,
                                                                        @"new mapping": mapping })];
}

- (NSInteger)numberOfMappings:(NJMappingsViewController *)mvc {
    return self.count;
}

- (NJMapping *)mappingsViewController:(NJMappingsViewController *)mvc
                      mappingForIndex:(NSUInteger)idx {
    return self[idx];
}

- (void)mappingsViewController:(NJMappingsViewController *)mvc
          editedMappingAtIndex:(NSInteger)index {
    [self mappingsChanged];
}

- (BOOL)mappingsViewController:(NJMappingsViewController *)mvc
       canMoveMappingFromIndex:(NSInteger)fromIdx
                       toIndex:(NSInteger)toIdx {
    return fromIdx != toIdx && fromIdx != 0 && toIdx != 0;
}

- (void)mappingsViewController:(NJMappingsViewController *)mvc
          moveMappingFromIndex:(NSInteger)fromIdx
                       toIndex:(NSInteger)toIdx {
    [mvc.mappingList beginUpdates];
    [mvc.mappingList moveRowAtIndex:fromIdx toIndex:toIdx];
    [self moveMoveMappingFromIndex:fromIdx toIndex:toIdx];
    [mvc.mappingList endUpdates];
}

- (BOOL)mappingsViewController:(NJMappingsViewController *)mvc
       canRemoveMappingAtIndex:(NSInteger)idx {
    return idx != 0;
}

- (void)mappingsViewController:(NJMappingsViewController *)mvc
          removeMappingAtIndex:(NSInteger)idx {
    [mvc.mappingList beginUpdates];
    [mvc removedMappingAtIndex:idx];
    [self removeMappingAtIndex:idx];
    [mvc.mappingList endUpdates];
}

- (BOOL)mappingsViewController:(NJMappingsViewController *)mvc
          importMappingFromURL:(NSURL *)url
                       atIndex:(NSInteger)index
                         error:(NSError **)error {
    NJMapping *mapping = [NJMapping mappingWithContentsOfURL:url
                                                       error:error];
    if ([self[mapping.name] hasConflictWith:mapping]) {
        [self promptForMapping:mapping atIndex:index];
    } else if (self[mapping.name]) {
        [self[mapping.name] mergeEntriesFrom:mapping];
    } else if (mapping) {
        [self insertMapping:mapping atIndex:index];
    }
    return !!mapping;
}

- (void)mappingsViewController:(NJMappingsViewController *)mvc
                    addMapping:(NJMapping *)mapping {
    [mvc.mappingList beginUpdates];
    [mvc addedMappingAtIndex:_mappings.count startEditing:YES];
    [self addMapping:mapping];
    [mvc.mappingList endUpdates];
    [self activateMapping:mapping];
}

- (void)mappingsViewController:(NJMappingsViewController *)mvc
                  choseMappingAtIndex:(NSInteger)idx {
    [self activateMapping:self[idx]];
}

@end
