//
//  NJMappingsViewController.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/17/13.
//
//

#import "NJMappingsViewController.h"

#import "NJMapping.h"

#define PB_ROW @"com.yukkurigames.Enjoyable.MappingRow"


@implementation NJMappingsViewController

- (void)awakeFromNib {
    [self.mappingList registerForDraggedTypes:@[PB_ROW, NSURLPboardType]];
    [self.mappingList setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
}

- (IBAction)addClicked:(id)sender {
    NJMapping *newMapping = [[NJMapping alloc] init];
    [self.delegate mappingsViewController:self addMapping:newMapping];
}

- (IBAction)removeClicked:(id)sender {
    [self.delegate mappingsViewController:self
                     removeMappingAtIndex:self.mappingList.selectedRow];
}

- (IBAction)moveUpClicked:(id)sender {
    NSInteger fromIdx = self.mappingList.selectedRow;
    NSInteger toIdx = fromIdx - 1;
    [self.delegate mappingsViewController:self
                     moveMappingFromIndex:fromIdx
                                  toIndex:toIdx];
    [self.mappingList scrollRowToVisible:toIdx];
    [self.mappingList selectRowIndexes:[[NSIndexSet alloc] initWithIndex:toIdx]
                  byExtendingSelection:NO];
}

- (IBAction)moveDownClicked:(id)sender {
    NSInteger fromIdx = self.mappingList.selectedRow;
    NSInteger toIdx = fromIdx + 1;
    [self.delegate mappingsViewController:self
                     moveMappingFromIndex:fromIdx
                                  toIndex:toIdx];
    [self.mappingList scrollRowToVisible:toIdx];
    [self.mappingList selectRowIndexes:[[NSIndexSet alloc] initWithIndex:toIdx]
                  byExtendingSelection:NO];
}

- (IBAction)mappingTriggerClicked:(id)sender {
    [self.mappingListPopover showRelativeToRect:self.mappingListTrigger.bounds
                                         ofView:self.mappingListTrigger
                                  preferredEdge:NSMinXEdge];
    self.mappingListTrigger.state = NSOnState;
}

- (void)popoverWillShow:(NSNotification *)notification {
    self.mappingListTrigger.state = NSOnState;
}

- (void)popoverWillClose:(NSNotification *)notification {
    self.mappingListTrigger.state = NSOffState;
}

- (void)beginUpdates {
    [self.mappingList beginUpdates];
}

- (void)endUpdates {
    [self.mappingList endUpdates];
    [self changedActiveMappingToIndex:self.mappingList.selectedRow];
}

- (void)addedMappingAtIndex:(NSInteger)index startEditing:(BOOL)startEditing {
    [self.mappingList abortEditing];
    [self.mappingList insertRowsAtIndexes:[[NSIndexSet alloc] initWithIndex:index]
                            withAnimation:startEditing ? 0 : NSTableViewAnimationSlideLeft];
    if (startEditing) {
        [self.mappingListTrigger performClick:self];
        [self.mappingList editColumn:0 row:index withEvent:nil select:YES];
        [self.mappingList scrollRowToVisible:index];
    }
}

- (void)removedMappingAtIndex:(NSInteger)index {
    [self.mappingList abortEditing];
    [self.mappingList removeRowsAtIndexes:[[NSIndexSet alloc] initWithIndex:index]
                            withAnimation:NSTableViewAnimationEffectFade];
}

- (void)changedActiveMappingToIndex:(NSInteger)index {
    NJMapping *mapping = [self.delegate mappingsViewController:self
                                               mappingForIndex:index];
    self.removeMapping.enabled = [self.delegate mappingsViewController:self
                                               canRemoveMappingAtIndex:index];
    self.moveUp.enabled = [self.delegate mappingsViewController:self
                                        canMoveMappingFromIndex:index toIndex:index - 1];
    self.moveDown.enabled = [self.delegate mappingsViewController:self
                                          canMoveMappingFromIndex:index toIndex:index + 1];
    self.mappingListTrigger.title = mapping.name;
    [self.mappingList selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [self.mappingList scrollRowToVisible:index];
    [NSUserDefaults.standardUserDefaults setInteger:index forKey:@"selected"];
   
}

- (void)tableViewSelectionDidChange:(NSNotification *)note {
    [self.mappingList abortEditing];
    NSTableView *tableView = note.object;
    [self.delegate mappingsViewController:self
                      choseMappingAtIndex:tableView.selectedRow];
}

- (id)tableView:(NSTableView *)view objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)index {
    return [self.delegate mappingsViewController:self
                                 mappingForIndex:index].name;
}

- (void)tableView:(NSTableView *)view
   setObjectValue:(NSString *)obj
   forTableColumn:(NSTableColumn *)col
              row:(NSInteger)index {
    [self.delegate mappingsViewController:self
                     renameMappingAtIndex:index
                                   toName:obj];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.delegate numberOfMappings:self];
}

- (BOOL)tableView:(NSTableView *)tableView
       acceptDrop:(id <NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)dropOperation {
    NSPasteboard *pboard = [info draggingPasteboard];
    if ([pboard.types containsObject:PB_ROW]) {
        NSString *value = [pboard stringForType:PB_ROW];
        NSInteger srcRow = [value intValue];
        row -= srcRow < row;
        [self.delegate mappingsViewController:self
                         moveMappingFromIndex:srcRow
                                      toIndex:row];
        return YES;
    } else if ([pboard.types containsObject:NSURLPboardType]) {
        NSURL *url = [NSURL URLFromPasteboard:pboard];
        NSError *error;
        if (![self.delegate mappingsViewController:self
                              importMappingFromURL:url
                                           atIndex:row
                                             error:&error]) {
            [tableView presentError:error];
            return NO;
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

- (NSDragOperation)tableView:(NSTableView *)tableView
                validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    NSPasteboard *pboard = [info draggingPasteboard];
    if ([pboard.types containsObject:PB_ROW]) {
        [tableView setDropRow:MAX(1, row) dropOperation:NSTableViewDropAbove];
        return NSDragOperationMove;
    } else if ([pboard.types containsObject:NSURLPboardType]) {
        NSURL *url = [NSURL URLFromPasteboard:pboard];
        if ([url.pathExtension isEqualToString:@"enjoyable"]) {
            [tableView setDropRow:MAX(1, row) dropOperation:NSTableViewDropAbove];
            return NSDragOperationCopy;
        } else {
            return NSDragOperationNone;
        }
    } else {
        return NSDragOperationNone;
    }
}

- (NSArray *)tableView:(NSTableView *)tableView
namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination
forDraggedRowsWithIndexes:(NSIndexSet *)indexSet {
    NJMapping *toSave = [self.delegate mappingsViewController:self
                                              mappingForIndex:indexSet.firstIndex];
    NSString *filename = [[toSave.name stringByFixingPathComponent]
                          stringByAppendingPathExtension:@"enjoyable"];
    NSURL *dst = [dropDestination URLByAppendingPathComponent:filename];
    dst = [NSFileManager.defaultManager generateUniqueURLWithBase:dst];
    NSError *error;
    if (![toSave writeToURL:dst error:&error]) {
        [tableView presentError:error];
        return @[];
    } else {
        return @[dst.lastPathComponent];
    }
}

- (BOOL)tableView:(NSTableView *)tableView
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

- (void)reloadData {
    [self.mappingList reloadData];
}

@end

