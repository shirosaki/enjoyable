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
        _currentMapping = [[NJMapping alloc] initWithName:@"(default)"];
        _manualMapping = _currentMapping;
        [_mappings addObject:_currentMapping];
    }
    return self;
}

- (void)awakeFromNib {
    [tableView registerForDraggedTypes:@[PB_ROW, NSURLPboardType]];
    [tableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
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

- (void)mappingsChanged {
    [self save];
    [tableView reloadData];
    [self updateInterfaceForCurrentMapping];
    [NSNotificationCenter.defaultCenter
        postNotificationName:NJEventMappingListChanged
                      object:self
                    userInfo:@{ NJMappingListKey: _mappings,
                                NJMappingKey: _currentMapping }];
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
        if ([oldMapping.name.lowercaseString isEqualToString:@"@application"]) {
            oldMapping.name = app.bestMappingName;
            [self mappingsChanged];
        }
    }
    _manualMapping = oldMapping;
}

- (void)updateInterfaceForCurrentMapping {
    NSUInteger selected = [_mappings indexOfObject:_currentMapping];
    removeButton.enabled = selected != 0;
    moveUp.enabled = selected > 1;
    moveDown.enabled = selected && selected != _mappings.count - 1;
    popoverActivate.title = _currentMapping.name;
    [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selected] byExtendingSelection:NO];
    [NSUserDefaults.standardUserDefaults setInteger:selected forKey:@"selected"];
}

- (void)activateMapping:(NJMapping *)mapping {
    if (!mapping)
        mapping = _manualMapping;
    if (mapping == _currentMapping)
        return;
    NSLog(@"Switching to mapping %@.", mapping.name);
    _manualMapping = mapping;
    _currentMapping = mapping;
    [self updateInterfaceForCurrentMapping];
    [NSNotificationCenter.defaultCenter
         postNotificationName:NJEventMappingChanged
                       object:self
                     userInfo:@{ NJMappingKey : _currentMapping }];
}

- (IBAction)addPressed:(id)sender {
    NJMapping *newMapping = [[NJMapping alloc] initWithName:@"Untitled"];
    [_mappings addObject:newMapping];
    [self activateMapping:newMapping];
    [self mappingsChanged];
    [tableView editColumn:0 row:_mappings.count - 1 withEvent:nil select:YES];
}

- (IBAction)removePressed:(id)sender {
    if (tableView.selectedRow == 0)
        return;
    
    NSInteger selectedRow = tableView.selectedRow;
    [_mappings removeObjectAtIndex:selectedRow];
    [self activateMapping:_mappings[MIN(selectedRow, _mappings.count - 1)]];
    [self mappingsChanged];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notify {
    [self activateMapping:self[tableView.selectedRow]];
}

- (id)tableView:(NSTableView *)view objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)index {
    return self[index].name;
}

- (void)tableView:(NSTableView *)view
   setObjectValue:(NSString *)obj
   forTableColumn:(NSTableColumn *)col
              row:(NSInteger)index {
    self[index].name = obj;
    [self mappingsChanged];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _mappings.count;
}

- (BOOL)tableView:(NSTableView *)view shouldEditTableColumn:(NSTableColumn *)column row:(NSInteger)index {
    return YES;
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
    NSArray *mappings = [NSUserDefaults.standardUserDefaults arrayForKey:@"mappings"];
    [self loadAllFrom:mappings andActivate:selected];
}

- (void)loadAllFrom:(NSArray *)storedMappings andActivate:(NSUInteger)selected {
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
        [self activateMapping:_mappings[selected]];
        [self mappingsChanged];
    }
}

- (void)addMappingWithContentsOfURL:(NSURL *)url {
    NSWindow *window = popoverActivate.window;
    NSError *error;
    NJMapping *mapping = [NJMapping mappingWithContentsOfURL:url
                                                    mappings:_mappings
                                                       error:&error];
    
    if (mapping && !error) {
        NJMapping *mergeInto = self[mapping.name];
        BOOL conflict = [mergeInto hasConflictWith:mapping];
        
        if (conflict) {
            NSAlert *conflictAlert = [[NSAlert alloc] init];
            conflictAlert.messageText = @"Replace existing mappings?";
            conflictAlert.informativeText =
            [NSString stringWithFormat:
             @"This file contains inputs you've already mapped in \"%@\". Do you "
             @"want to merge them and replace your existing mappings, or import this "
             @"as a separate mapping?", mapping.name];
            [conflictAlert addButtonWithTitle:@"Merge"];
            [conflictAlert addButtonWithTitle:@"Cancel"];
            [conflictAlert addButtonWithTitle:@"New Mapping"];
            NSInteger res = [conflictAlert runModal];
            if (res == NSAlertSecondButtonReturn)
                return;
            else if (res == NSAlertThirdButtonReturn)
                mergeInto = nil;
        }
        
        if (mergeInto) {
            [mergeInto mergeEntriesFrom:mapping];
            mapping = mergeInto;
        } else {
            [_mappings addObject:mapping];
        }
        
        [self activateMapping:mapping];
        [self mappingsChanged];
        
        if (conflict && !mergeInto) {
            [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:_mappings.count - 1] byExtendingSelection:NO];
            [tableView editColumn:0 row:_mappings.count - 1 withEvent:nil select:YES];
        }
    }
    
    if (error) {
        [window presentError:error
              modalForWindow:window
                    delegate:nil
          didPresentSelector:nil
                 contextInfo:nil];
    }
}

- (void)importPressed:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowedFileTypes = @[ @"enjoyable", @"json", @"txt" ];
    NSWindow *window = NSApplication.sharedApplication.keyWindow;
    [panel beginSheetModalForWindow:window
                  completionHandler:^(NSInteger result) {
                      if (result != NSFileHandlingPanelOKButton)
                          return;
                      [panel close];
                      [self addMappingWithContentsOfURL:panel.URL];
                  }];
    
}

- (void)exportPressed:(id)sender {
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.allowedFileTypes = @[ @"enjoyable" ];
    NJMapping *mapping = _currentMapping;
    panel.nameFieldStringValue = [mapping.name stringByFixingPathComponent];
    NSWindow *window = NSApplication.sharedApplication.keyWindow;
    [panel beginSheetModalForWindow:window
                  completionHandler:^(NSInteger result) {
                      if (result != NSFileHandlingPanelOKButton)
                          return;
                      [panel close];
                      NSError *error;
                      [mapping writeToURL:panel.URL error:&error];
                      if (error) {
                          [window presentError:error
                                modalForWindow:window
                                      delegate:nil
                            didPresentSelector:nil
                                   contextInfo:nil];
                      }
                  }];
}

- (IBAction)mappingPressed:(id)sender {
    [popover showRelativeToRect:popoverActivate.bounds
                         ofView:popoverActivate
                  preferredEdge:NSMinXEdge];
}

- (void)popoverWillShow:(NSNotification *)notification {
    popoverActivate.state = NSOnState;
}

- (void)popoverWillClose:(NSNotification *)notification {
    popoverActivate.state = NSOffState;
}

- (IBAction)moveUpPressed:(id)sender {
    if ([_mappings moveFirstwards:_currentMapping upTo:1])
        [self mappingsChanged];
}

- (IBAction)moveDownPressed:(id)sender {
    if ([_mappings moveLastwards:_currentMapping])
        [self mappingsChanged];
}

- (BOOL)tableView:(NSTableView *)tableView_
       acceptDrop:(id <NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)dropOperation {
    NSPasteboard *pboard = [info draggingPasteboard];
    if ([pboard.types containsObject:PB_ROW]) {
        NSString *value = [pboard stringForType:PB_ROW];
        NSUInteger srcRow = [value intValue];
        [_mappings moveObjectAtIndex:srcRow toIndex:row];
        [self mappingsChanged];
        return YES;
    } else if ([pboard.types containsObject:NSURLPboardType]) {
        NSURL *url = [NSURL URLFromPasteboard:pboard];
        NSError *error;
        NJMapping *mapping = [NJMapping mappingWithContentsOfURL:url
                                                        mappings:_mappings
                                                           error:&error];
        if (error) {
            [tableView_ presentError:error];
            return NO;
        } else {
            [_mappings insertObject:mapping atIndex:row];
            [self mappingsChanged];
            return YES;
        }
    } else {
        return NO;
    }
}

- (NSDragOperation)tableView:(NSTableView *)tableView_
                validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    NSPasteboard *pboard = [info draggingPasteboard];
    if ([pboard.types containsObject:PB_ROW]) {
        [tableView_ setDropRow:MAX(1, row) dropOperation:NSTableViewDropAbove];
        return NSDragOperationMove;
    } else if ([pboard.types containsObject:NSURLPboardType]) {
        NSURL *url = [NSURL URLFromPasteboard:pboard];
        if ([url.pathExtension isEqualToString:@"enjoyable"]) {
            [tableView_ setDropRow:MAX(1, row) dropOperation:NSTableViewDropAbove];
            return NSDragOperationCopy;
        } else {
            return NSDragOperationNone;
        }
    } else {
        return NSDragOperationNone;
    }
}

- (NSArray *)tableView:(NSTableView *)tableView_
namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination
forDraggedRowsWithIndexes:(NSIndexSet *)indexSet {
    NJMapping *toSave = self[indexSet.firstIndex];
    NSString *filename = [[toSave.name stringByFixingPathComponent]
                          stringByAppendingPathExtension:@"enjoyable"];
    NSURL *dst = [dropDestination URLByAppendingPathComponent:filename];
    dst = [NSFileManager.defaultManager generateUniqueURLWithBase:dst];     
    NSError *error;
    if (![toSave writeToURL:dst error:&error]) {
        [tableView_ presentError:error];
        return @[];
    } else {
        return @[dst.lastPathComponent];
    }
}

- (BOOL)tableView:(NSTableView *)tableView_
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
     toPasteboard:(NSPasteboard *)pboard {
    if (rowIndexes.count == 1 && rowIndexes.firstIndex != 0) {
        [pboard declareTypes:@[PB_ROW, NSFilesPromisePboardType] owner:nil];
        [pboard setString:@(rowIndexes.firstIndex).stringValue forType:PB_ROW];
        [pboard setPropertyList:@[@"enjoyable"] forType:NSFilesPromisePboardType];
        return YES;
    } else if (rowIndexes.count == 1 && rowIndexes.firstIndex == 0) {
        [pboard declareTypes:@[NSFilesPromisePboardType] owner:nil];
        [pboard setPropertyList:@[@"enjoyable"] forType:NSFilesPromisePboardType];
        return YES;
    } else {
        return NO;
    }
}

@end
