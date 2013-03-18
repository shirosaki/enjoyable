//
//  NJMappingsController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "NJMappingsController.h"

#import "NJMapping.h"
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
    NSUInteger idx = [_mappings indexOfObjectIdenticalTo:_currentMapping];
    [NSNotificationCenter.defaultCenter
         postNotificationName:NJEventMappingChanged
                       object:self
                     userInfo:@{ NJMappingKey : _currentMapping,
                                 NJMappingIndexKey: @(idx) }];
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
        // FIXME: Hack to trigger updates in the rest of the UI.
        _currentMapping = nil;
        NJMapping *manual = _manualMapping;
        [self activateMapping:existing];
        _manualMapping = manual;
    }
}

- (void)renameMapping:(NJMapping *)mapping to:(NSString *)name {
    mapping.name = name;
    if (mapping == _currentMapping) {
        // FIXME: Hack to trigger updates in the rest of the UI.
        _currentMapping = nil;
        NJMapping *manual = _manualMapping;
        [self activateMapping:mapping];
        _manualMapping = manual;        
    }
    [self mappingsChanged];
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

@end
