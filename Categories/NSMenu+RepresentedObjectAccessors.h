//
//  NSMenu+RepresentedObjectAccessors.h
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/4/13.
//
//

#import <Cocoa/Cocoa.h>

@interface NSMenu (RepresentedObjectAccessors)
    // Helpers for using represented objects in menu items.

- (NSMenuItem *)itemWithRepresentedObject:(id)object;
- (NSMenuItem *)itemWithIdenticalRepresentedObject:(id)object;
    // Returns the first menu item in the receiver that has a given
    // represented object.

- (NSMenuItem *)lastItem;
    // Return the last menu item in the receiver, or nil if the menu
    // has no items.

- (void)removeLastItem;
    // Removes the last menu item in the receiver, if there is one.
    //
    // After and if it removes the menu item, this method posts an
    // NSMenuDidRemoveItemNotification.

@end

@interface NSPopUpButton (RepresentedObjectAccessors)

- (NSMenuItem *)itemWithRepresentedObject:(id)object;
- (NSMenuItem *)itemWithIdenticalRepresentedObject:(id)object;
    // Returns the first item in the receiver's menu that has a given
    // represented object.

- (void)selectItemWithRepresentedObject:(id)object;
- (void)selectItemWithIdenticalRepresentedObject:(id)object;
    // Selects the first item in the receiver's menu that has a give
    // represented object.

@end
