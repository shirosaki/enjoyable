//
//  NSOutlineView+ItemAccessors.h
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/16/13.
//
//

#import <Cocoa/Cocoa.h>

@interface NSOutlineView (ItemAccessors)

- (void)selectItem:(id)item;
- (id)selectedItem;

@end
