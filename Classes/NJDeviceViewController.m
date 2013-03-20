//
//  NJDeviceViewController.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/16/13.
//
//

#import "NJDeviceViewController.h"

#import "NJInputPathElement.h"

@implementation NJDeviceViewController {
    NSMutableArray *_expanded;
}

- (id)init {
    if ((self = [super init])) {
        NSArray *expanded = [NSUserDefaults.standardUserDefaults objectForKey:@"expanded rows"];
        if (![expanded isKindOfClass:NSArray.class])
            expanded = @[];
        _expanded = [[NSMutableArray alloc] initWithCapacity:MAX(16, _expanded.count)];
        [_expanded addObjectsFromArray:expanded];
    }
    return self;
}

- (void)expandRecursive:(NJInputPathElement *)pathElement {
    if (pathElement) {
        [self expandRecursive:pathElement.parent];
        [self.inputsTree expandItem:pathElement];
    }
}

- (void)expandRecursiveByUID:(NSString *)uid {
    [self expandRecursive:[self.delegate deviceViewController:self elementForUID:uid]];
}

- (void)reexpandAll {
    for (NSString *uid in [_expanded copy])
        [self expandRecursiveByUID:uid];
    if (self.inputsTree.selectedRow == -1) {
        NSString *selectedUid = [NSUserDefaults.standardUserDefaults objectForKey:@"selected input"];
        id item = [self.delegate deviceViewController:self elementForUID:selectedUid];
        [self.inputsTree selectItem:item];
    }
}

- (void)addedDevice:(NJDevice *)device atIndex:(NSUInteger)idx {
    [self.inputsTree beginUpdates];
    [self.inputsTree insertItemsAtIndexes:[[NSIndexSet alloc] initWithIndex:idx]
                                  inParent:nil
                             withAnimation:NSTableViewAnimationEffectFade];
    [self reexpandAll];
    [self.inputsTree endUpdates];
    self.noDevicesNotice.hidden = YES;
}

- (void)removedDeviceAtIndex:(NSUInteger)idx {
    BOOL anyDevices = !![self.delegate numberOfDevicesInDeviceList:self];
    [self.inputsTree beginUpdates];
    [self.inputsTree removeItemsAtIndexes:[[NSIndexSet alloc] initWithIndex:idx]
                                  inParent:nil
                             withAnimation:NSTableViewAnimationEffectFade];
    [self.inputsTree endUpdates];
    self.noDevicesNotice.hidden = anyDevices || !self.hidStoppedNotice.isHidden;
}

- (void)hidStarted {
    self.noDevicesNotice.hidden = !![self.delegate numberOfDevicesInDeviceList:self];
    self.hidStoppedNotice.hidden = YES;
}

- (void)hidStopped {
    self.noDevicesNotice.hidden = YES;
    self.hidStoppedNotice.hidden = NO;
    [self.inputsTree reloadData];
}

- (void)expandAndSelectItem:(NJInputPathElement *)item {
    [self expandRecursive:item];
    NSInteger row = [self.inputsTree rowForItem:item];
    if (row >= 0) {
        [self.inputsTree selectRowIndexes:[[NSIndexSet alloc] initWithIndex:row]
                      byExtendingSelection:NO];
        [self.inputsTree scrollRowToVisible:row];
    }
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(NJInputPathElement *)item {
    if (item)
        return item.children.count;
    else
        return [self.delegate numberOfDevicesInDeviceList:self];

}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(NJInputPathElement *)item {
    return item ? item.children.count > 0: YES;
}

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(NJInputPathElement *)item {
    if (item)
        return item.children[index];
    else
        return [self.delegate deviceViewController:self deviceForIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(NJInputPathElement *)item  {
    return item ? item.name : @"root";
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NSOutlineView *outlineView = notification.object;
    NJInputPathElement *item = outlineView.selectedItem;
    if (item) {
        [NSUserDefaults.standardUserDefaults setObject:item.uid
                                                forKey:@"selected input"];
        if (!item.children)
            [self.delegate deviceViewController:self
                               didSelectHandler:item];
        else if (!item.parent)
            [self.delegate deviceViewController:self
                               didSelectDevice:item];
        else
            [self.delegate deviceViewController:self
                                didSelectBranch:item];
    } else {
        [self.delegate deviceViewControllerDidSelectNothing:self];
    }
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification {
    NSString *uid = [notification.userInfo[@"NSObject"] uid];
    if (![_expanded containsObject:uid]) {
        [_expanded addObject:uid];
        [NSUserDefaults.standardUserDefaults setObject:_expanded forKey:@"expanded rows"];
    }
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification {
    [_expanded removeObject:[notification.userInfo[@"NSObject"] uid]];
    [NSUserDefaults.standardUserDefaults setObject:_expanded forKey:@"expanded rows"];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
        isGroupItem:(NJInputPathElement *)item {
    return !item.parent;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   shouldSelectItem:(NJInputPathElement *)item {
    return ![self outlineView:outlineView isGroupItem:item];
}

- (NJInput *)selectedHandler {
    NJInputPathElement *element = self.inputsTree.selectedItem;
    return element.children ? nil : (NJInput *)element;
}

@end
