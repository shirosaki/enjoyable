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

- (void)load {
    NSUInteger selected = [NSUserDefaults.standardUserDefaults integerForKey:@"selected"];
    NSArray *storedMappings = [NSUserDefaults.standardUserDefaults arrayForKey:@"mappings"];
    NSMutableArray* newMappings = [[NSMutableArray alloc] initWithCapacity:storedMappings.count];

    // Requires two passes to deal with inter-mapping references. First make
    // an empty mapping for each serialized mapping. Then, deserialize the
    // data pointing to the empty mappings. Then merge that data back into
    // its equivalent empty one, which is the one we finally use.
    for (NSDictionary *storedMapping in storedMappings) {
        NJMapping *mapping = [[NJMapping alloc] initWithName:storedMapping[@"name"]];
        [newMappings addObject:mapping];
    }

    for (unsigned i = 0; i < storedMappings.count; ++i) {
        NJMapping *realMapping = [[NJMapping alloc] initWithSerialization:storedMappings[i]
                                                                 mappings:newMappings];
        [newMappings[i] mergeEntriesFrom:realMapping];
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

- (void)mappingConflictDidResolve:(NSAlert *)alert
                       returnCode:(NSInteger)returnCode
                      contextInfo:(void *)contextInfo {
    NSDictionary *userInfo = CFBridgingRelease(contextInfo);
    NJMapping *oldMapping = userInfo[@"old mapping"];
    NJMapping *newMapping = userInfo[@"new mapping"];
    switch (returnCode) {
        case NSAlertFirstButtonReturn: // Merge
            [oldMapping mergeEntriesFrom:newMapping];
            _currentMapping = nil;
            [self activateMapping:oldMapping];
            [self mappingsChanged];
            break;
        case NSAlertThirdButtonReturn: // New Mapping
            [self.mvc.mappingList beginUpdates];
            [_mappings addObject:newMapping];
            [self.mvc addedMappingAtIndex:_mappings.count - 1 startEditing:NO];
            [self.mvc.mappingList endUpdates];
            [self activateMapping:newMapping];
            [self mappingsChanged];
            break;
        default: // Cancel, other.
            break;
    }
}

- (void)addOrMergeMapping:(NJMapping *)mapping {
    [self addOrMergeMapping:mapping atIndex:-1];
}

- (void)addOrMergeMapping:(NJMapping *)mapping atIndex:(NSInteger)idx {
    NSWindow *window = NSApplication.sharedApplication.keyWindow;
    if (mapping) {
        NJMapping *mergeInto = self[mapping.name];
        if ([mergeInto hasConflictWith:mapping]) {
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
        } else if (mergeInto) {
            [mergeInto mergeEntriesFrom:mapping];
            [self activateMapping:mergeInto];
            [self mappingsChanged];
        } else {
            if (idx == -1)
                idx = _mappings.count - 1;
            [self.mvc.mappingList beginUpdates];
            [_mappings insertObject:mapping atIndex:idx];
            [self.mvc addedMappingAtIndex:idx startEditing:NO];
            [self.mvc.mappingList endUpdates];
            [self activateMapping:mapping];
            [self mappingsChanged];
        }
    }
}

- (NSInteger)numberOfMappings:(NJMappingsViewController *)dvc {
    return _mappings.count;
}

- (NJMapping *)mappingsViewController:(NJMappingsViewController *)dvc
                      mappingForIndex:(NSUInteger)idx {
    return _mappings[idx];
}

- (void)mappingsViewController:(NJMappingsViewController *)mvc
          editedMappingAtIndex:(NSInteger)index {
    [self mappingsChanged];
}

- (BOOL)mappingsViewController:(NJMappingsViewController *)mvc
       canMoveMappingFromIndex:(NSInteger)fromIdx
                       toIndex:(NSInteger)toIdx {
    return fromIdx != toIdx && fromIdx != 0 && toIdx != 0 && toIdx < (NSInteger)_mappings.count;
}

- (void)mappingsViewController:(NJMappingsViewController *)mvc
          moveMappingFromIndex:(NSInteger)fromIdx
                       toIndex:(NSInteger)toIdx {
    [_mappings moveObjectAtIndex:fromIdx toIndex:toIdx];
    [self mappingsChanged];
}

- (BOOL)mappingsViewController:(NJMappingsViewController *)mvc
       canRemoveMappingAtIndex:(NSInteger)idx {
    return idx != 0;
}

- (void)mappingsViewController:(NJMappingsViewController *)mvc
          removeMappingAtIndex:(NSInteger)idx {
    NJMapping *old = self[idx];
    [self.mvc.mappingList beginUpdates];
    [_mappings removeObjectAtIndex:idx];
    [self.mvc removedMappingAtIndex:idx];
    [self.mvc.mappingList endUpdates];
    if (old == _currentMapping)
        [self activateMapping:self[MIN(idx, _mappings.count - 1)]];
    [self mappingsChanged];
}

- (BOOL)mappingsViewController:(NJMappingsViewController *)mvc
          importMappingFromURL:(NSURL *)url
                       atIndex:(NSInteger)index
                         error:(NSError **)error {
    NJMapping *mapping = [NJMapping mappingWithContentsOfURL:url
                                                    mappings:_mappings
                                                       error:error];
    [self addOrMergeMapping:mapping atIndex:index];
    return !!mapping;
}

- (void)mappingsViewController:(NJMappingsViewController *)mvc
                    addMapping:(NJMapping *)mapping {
    [self.mvc.mappingList beginUpdates];
    [_mappings addObject:mapping];
    [self.mvc addedMappingAtIndex:_mappings.count - 1 startEditing:YES];
    [self.mvc.mappingList endUpdates];
    [self activateMapping:mapping];
    [self mappingsChanged];
}

- (void)mappingsViewController:(NJMappingsViewController *)mvc
                  choseMappingAtIndex:(NSInteger)idx {
    [self activateMapping:self[idx]];
}

@end
