//
//  NSOutlineView+ItemAccessors.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/16/13.
//
//

#import "NSOutlineView+ItemAccessors.h"

@implementation NSOutlineView (ItemAccessors)

- (void)selectItem:(id)item {
    NSInteger row = [self rowForItem:item];
    if (row >= 0) {
        [self selectRowIndexes:[[NSIndexSet alloc] initWithIndex:row]
          byExtendingSelection:NO];
    } else {
        [self deselectAll:nil];
    }
}

- (id)selectedItem {
    return self.selectedRow >= 0 ? [self itemAtRow:self.selectedRow] : nil;
}

@end
