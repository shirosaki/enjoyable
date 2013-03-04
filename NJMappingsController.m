//
//  NJMappingsController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "NJMappingsController.h"

#import "EnjoyableApplicationDelegate.h"
#import "NJMapping.h"
#import "NJMappingsController.h"
#import "NJOutput.h"
#import "NJOutputController.h"
#import "NJEvents.h"

@implementation NJMappingsController {
    NSMutableArray *_mappings;
    NJMapping *manualMapping;
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

- (NJMapping *)objectForKeyedSubscript:(NSString *)name {
    for (NJMapping *mapping in _mappings)
        if ([name isEqualToString:mapping.name])
            return mapping;
    return nil;
}

- (NJMapping *)objectAtIndexedSubscript:(NSUInteger)idx {
    return idx < _mappings.count ? _mappings[idx] : nil;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id [])buffer
                                    count:(NSUInteger)len {
    return [_mappings countByEnumeratingWithState:state
                                          objects:buffer
                                            count:len];
}


- (void)activateMappingForProcess:(NSString *)processName {
    NJMapping *oldMapping = manualMapping;
    NJMapping *newMapping = self[processName];
    if (!newMapping)
        newMapping = oldMapping;
    if (newMapping != _currentMapping)
        [self activateMapping:newMapping];
    manualMapping = oldMapping;
}

- (void)activateMapping:(NJMapping *)mapping {
    if (!mapping)
        mapping = manualMapping;
    NSLog(@"Switching to mapping %@.", mapping.name);
    manualMapping = mapping;
    _currentMapping = mapping;
    [removeButton setEnabled:_mappings[0] != mapping];
    [outputController loadCurrent];
    popoverActivate.title = _currentMapping.name;
    [NSNotificationCenter.defaultCenter postNotificationName:NJEventMappingChanged
                                                      object:_currentMapping];
    [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[_mappings indexOfObject:mapping]] byExtendingSelection:NO];
}

- (IBAction)addPressed:(id)sender {
    NJMapping *newMapping = [[NJMapping alloc] initWithName:@"Untitled"];
    [_mappings addObject:newMapping];
    [(EnjoyableApplicationDelegate *)NSApplication.sharedApplication.delegate mappingsChanged];
    [tableView reloadData];
    [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:_mappings.count - 1] byExtendingSelection:NO];
    [tableView editColumn:0 row:_mappings.count - 1 withEvent:nil select:YES];
    [self activateMapping:newMapping];
}

- (IBAction)removePressed:(id)sender {
    if (tableView.selectedRow == 0)
        return;
    
    [_mappings removeObjectAtIndex:tableView.selectedRow];
    [tableView reloadData];
    [(EnjoyableApplicationDelegate *)NSApplication.sharedApplication.delegate mappingsChanged];
    [self activateMapping:_mappings[0]];
    [self save];
}

-(void)tableViewSelectionDidChange:(NSNotification *)notify {
    if (tableView.selectedRow >= 0)
        [self activateMapping:_mappings[tableView.selectedRow]];
}

- (id)tableView:(NSTableView *)view objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)index {
    return self[index].name;
}

- (void)tableView:(NSTableView *)view
   setObjectValue:(NSString *)obj
   forTableColumn:(NSTableColumn *)col
              row:(NSInteger)index {
    self[index].name = obj;
    [self save];
    [tableView reloadData];
    [(EnjoyableApplicationDelegate *)NSApplication.sharedApplication.delegate mappingsChanged];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _mappings.count;
}

- (BOOL)tableView:(NSTableView *)view shouldEditTableColumn:(NSTableColumn *)column row:(NSInteger)index {
    return index > 0;
}

- (void)save {
    NSLog(@"Saving mappings to defaults.");
    [NSUserDefaults.standardUserDefaults setValuesForKeysWithDictionary:[self dumpAll]];
}

- (void)load {
    [self loadAllFrom:NSUserDefaults.standardUserDefaults.dictionaryRepresentation];
}

- (NSDictionary *)dumpAll {
    NSMutableArray *ary = [[NSMutableArray alloc] initWithCapacity:_mappings.count];
    for (NJMapping *mapping in _mappings)
        [ary addObject:[mapping serialize]];
    NSUInteger current = _currentMapping ? [_mappings indexOfObject:_currentMapping] : 0;
    return @{ @"mappings": ary, @"selected": @(current) };
}

- (void)loadAllFrom:(NSDictionary*)envelope {
    NSArray *storedMappings = envelope[@"mappings"];
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
        unsigned current = [envelope[@"selected"] unsignedIntValue];
        if (current >= newMappings.count)
            current = 0;
        _mappings = newMappings;
        [tableView reloadData];
        [(EnjoyableApplicationDelegate *)NSApplication.sharedApplication.delegate mappingsChanged];
        [self activateMapping:_mappings[current]];
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

- (void)importPressed:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowedFileTypes = @[ @"enjoyable", @"json", @"txt" ];
    NSWindow *window = NSApplication.sharedApplication.keyWindow;
    [panel beginSheetModalForWindow:window
                  completionHandler:^(NSInteger result) {
                      if (result != NSFileHandlingPanelOKButton)
                          return;

                      [panel close];
                      NSError *error;
                      NJMapping *mapping = [self mappingWithURL:panel.URL error:&error];
                      
                      if (!error) {
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
                              [tableView reloadData];
                          }
                          
                          [self save];
                          [(EnjoyableApplicationDelegate *)NSApplication.sharedApplication.delegate mappingsChanged];
                          [self activateMapping:mapping];
                          [outputController loadCurrent];
                          
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
                      NSDictionary *serialization = [mapping serialize];
                      NSData *json = [NSJSONSerialization dataWithJSONObject:serialization
                                                                     options:NSJSONWritingPrettyPrinted
                                                                       error:&error];
                      if (!error)
                          [json writeToURL:panel.URL options:NSDataWritingAtomic error:&error];
                      
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
    [popover showRelativeToRect:popoverActivate.bounds ofView:popoverActivate preferredEdge:NSMinXEdge];
}

- (void)popoverWillShow:(NSNotification *)notification {
    popoverActivate.state = NSOnState;
}

- (void)popoverWillClose:(NSNotification *)notification {
    popoverActivate.state = NSOffState;
}

@end
