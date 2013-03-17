//
//  NSMenu+RepresentedObjectAccessors.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/4/13.
//
//

#import "NSMenu+RepresentedObjectAccessors.h"

@implementation NSMenu (RepresentedObjectAccessors)

- (NSMenuItem *)itemWithRepresentedObject:(id)object {
    for (NSMenuItem *item in self.itemArray)
        if ([item.representedObject isEqual:object])
            return item;
    return nil;
}

- (NSMenuItem *)itemWithIdenticalRepresentedObject:(id)object {
    for (NSMenuItem *item in self.itemArray)
        if (item.representedObject == object)
            return item;
    return nil;
}

- (NSMenuItem *)lastItem {
    return self.itemArray.lastObject;
}

- (void)removeLastItem {
    if (self.numberOfItems)
        [self removeItemAtIndex:self.numberOfItems - 1];
}

@end

@implementation NSPopUpButton (RepresentedObjectAccessors)

- (NSMenuItem *)itemWithRepresentedObject:(id)object {
    return [self.menu itemWithRepresentedObject:object];
}

- (NSMenuItem *)itemWithIdenticalRepresentedObject:(id)object {
    return [self.menu itemWithIdenticalRepresentedObject:object];
}

- (void)selectItemWithRepresentedObject:(id)object {
    [self selectItemAtIndex:[self indexOfItemWithRepresentedObject:object]];
}

- (void)selectItemWithIdenticalRepresentedObject:(id)object {
    NSMenuItem *item = [self.menu itemWithIdenticalRepresentedObject:object];
    [self selectItem:item];
}


@end
