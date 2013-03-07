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
#import "NJOutputController.h"
#import "NJEvents.h"

#define PB_ROW @"com.yukkurigames.Enjoyable.MappingRow"

@implementation NJMappingsController {
    NSMutableArray *_mappings;
    NJMapping *manualMapping;
    NSString *draggingName;
}

- (id)init {
    if ((self = [super init])) {
        _mappings = [[NSMutableArray alloc] init];
        _currentMapping = [[NJMapping alloc] initWithName:@"(default)"];
        manualMapping = _currentMapping;
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
    popoverActivate.title = _currentMapping.name;
    [self updateInterfaceForCurrentMapping];
    [NSNotificationCenter.defaultCenter
        postNotificationName:NJEventMappingListChanged
        object:_mappings];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id [])buffer
                                    count:(NSUInteger)len {
    return [_mappings countByEnumeratingWithState:state
                                          objects:buffer
                                            count:len];
}

- (void)activateMappingForProcess:(NSString *)processName {
    if ([manualMapping.name.lowercaseString isEqualToString:@"@application"]) {
        manualMapping.name = processName;
        [self mappingsChanged];
    } else {
        NJMapping *oldMapping = manualMapping;
        NJMapping *newMapping = self[processName];
        if (!newMapping)
            newMapping = oldMapping;
        if (newMapping != _currentMapping)
            [self activateMapping:newMapping];
        manualMapping = oldMapping;
    }
}

- (void)updateInterfaceForCurrentMapping {
    NSUInteger selected = [_mappings indexOfObject:_currentMapping];
    [removeButton setEnabled:selected != 0];
    [moveDown setEnabled:selected && selected != _mappings.count - 1];
    [moveUp setEnabled:selected > 1];
    popoverActivate.title = _currentMapping.name;
    [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selected] byExtendingSelection:NO];
    [NSUserDefaults.standardUserDefaults setInteger:selected forKey:@"selected"];
}

- (void)activateMapping:(NJMapping *)mapping {
    if (!mapping)
        mapping = manualMapping;
    if (mapping == _currentMapping)
        return;
    NSLog(@"Switching to mapping %@.", mapping.name);
    manualMapping = mapping;
    _currentMapping = mapping;
    [self updateInterfaceForCurrentMapping];
    [outputController loadCurrent];
    [NSNotificationCenter.defaultCenter postNotificationName:NJEventMappingChanged
                                                      object:_currentMapping];
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

-(void)tableViewSelectionDidChange:(NSNotification *)notify {
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

    // have to do two passes in case mapping1 refers to mapping2 via a NJOutputMapping
    for (NSDictionary *storedMapping in storedMappings) {
        NJMapping *mapping = [[NJMapping alloc] initWithName:storedMapping[@"name"]];
        [newMappings addObject:mapping];
    }

    for (unsigned i = 0; i < storedMappings.count; ++i) {
        NSDictionary *entries = storedMappings[i][@"entries"];
        NJMapping *mapping = newMappings[i];
        for (id key in entries) {
            NJOutput *output = [NJOutput outputDeserialize:entries[key]
                                              withMappings:newMappings];
            if (output)
                mapping.entries[key] = output;
        }
    }
    
    if (newMappings.count) {
        _mappings = newMappings;
        if (selected >= newMappings.count)
            selected = 0;
        [self activateMapping:_mappings[selected]];
        [self mappingsChanged];
    }
}

- (NJMapping *)mappingWithURL:(NSURL *)url error:(NSError **)error {
    NSInputStream *stream = [NSInputStream inputStreamWithURL:url];
    [stream open];
    NSDictionary *serialization = !*error
        ? [NSJSONSerialization JSONObjectWithStream:stream options:0 error:error]
        : nil;
    [stream close];
    
    if (!([serialization isKindOfClass:NSDictionary.class]
          && [serialization[@"name"] isKindOfClass:NSString.class]
          && [serialization[@"entries"] isKindOfClass:NSDictionary.class])) {
        *error = [NSError errorWithDomain:@"Enjoyable"
                                     code:0
                              description:@"This isn't a valid mapping file."];
        return nil;
    }

    NSDictionary *entries = serialization[@"entries"];
    NJMapping *mapping = [[NJMapping alloc] initWithName:serialization[@"name"]];
    for (id key in entries) {
        NSDictionary *value = entries[key];
        if ([key isKindOfClass:NSString.class]) {
            NJOutput *output = [NJOutput outputDeserialize:value
                                              withMappings:_mappings];
            if (output)
                mapping.entries[key] = output;
        }
    }
    return mapping;
}

- (void)addMappingWithContentsOfURL:(NSURL *)url {
    NSWindow *window = popoverActivate.window;
    NSError *error;
    NJMapping *mapping = [NJMapping mappingWithContentsOfURL:url
                                                    mappings:_mappings
                                                       error:&error];
    
    if (mapping && !error) {
        BOOL conflict = NO;
        NJMapping *mergeInto = self[mapping.name];
        for (id key in mapping.entries) {
            if (mergeInto.entries[key]
                && ![mergeInto.entries[key] isEqual:mapping.entries[key]]) {
                conflict = YES;
                break;
            }
        }
        
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
            [mergeInto.entries addEntriesFromDictionary:mapping.entries];
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
    panel.nameFieldStringValue = mapping.name;
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
    NSUInteger idx = [_mappings indexOfObject:_currentMapping];
    if (idx > 1 && idx != NSNotFound) {
        [_mappings exchangeObjectAtIndex:idx withObjectAtIndex:idx - 1];
        [self mappingsChanged];
    }
}

- (IBAction)moveDownPressed:(id)sender {
    NSUInteger idx = [_mappings indexOfObject:_currentMapping];
    if (idx < _mappings.count - 1) {
        [_mappings exchangeObjectAtIndex:idx withObjectAtIndex:idx + 1];
        [self mappingsChanged];
    }
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
    } else {
        return NO;
    }
}

@end
