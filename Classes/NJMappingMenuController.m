//
//  NJMappingMenuController.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/11/13.
//
//

#import "NJMappingMenuController.h"

#import "NJEvents.h"
#import "NJMapping.h"

#define MAXIMUM_MAPPINGS_IN_MENU 15

@implementation NJMappingMenuController

- (id)init {
    if ((self = [super init])) {
        NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
        [center addObserver:self
                   selector:@selector(mappingsListDidChange:)
                       name:NJEventMappingListChanged
                     object:nil];
        [center addObserver:self
                   selector:@selector(mappingDidChange:)
                       name:NJEventMappingChanged
                     object:nil];
        [center addObserver:self
                   selector:@selector(eventSimulationStarted:)
                       name:NJEventSimulationStarted
                     object:nil];
        [center addObserver:self
                   selector:@selector(eventSimulationStopped:)
                       name:NJEventSimulationStopped
                     object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)_mappingWasChosen:(NSMenuItem *)sender {
    NJMapping *mapping = sender.representedObject;
    [self.delegate mappingWasChosen:mapping];
}

- (void)_mappingListWasChosen:(NSMenuItem *)sender {
    [self.delegate mappingListShouldOpen];
}

- (void)mappingsListDidChange:(NSNotification *)note {
    NSArray *mappings = note.userInfo[NJMappingListKey];
    NJMapping *currentMapping = note.userInfo[NJMappingKey];
    NSMenuItem *toRemove;
    while (self.menu.numberOfItems > self.firstMappingIndex
           && (toRemove = [self.menu itemAtIndex:self.firstMappingIndex])
           && ([toRemove.representedObject isKindOfClass:NJMapping.class]
               || toRemove.representedObject == self.class))
        [self.menu removeItemAtIndex:self.firstMappingIndex];    
    
    int added = 0;
    NSUInteger index = self.firstMappingIndex;
    for (NJMapping *mapping in mappings) {
        NSString *keyEquiv = (++added < 10 && self.hasKeyEquivalents)
            ? @(added).stringValue
            : @"";
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:mapping.name
                                                      action:@selector(_mappingWasChosen:)
                                               keyEquivalent:keyEquiv];
        item.representedObject = mapping;
        item.state = mapping == currentMapping;
        item.target = self;
        [self.menu insertItem:item atIndex:index++];
        if (added == MAXIMUM_MAPPINGS_IN_MENU
            && mappings.count > MAXIMUM_MAPPINGS_IN_MENU + 1) {
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"mapping overflow %lu",
                                                                         @"menu item when mappings list overflows"),
                             mappings.count - MAXIMUM_MAPPINGS_IN_MENU];
            NSMenuItem *end = [[NSMenuItem alloc] initWithTitle:msg
                                                         action:@selector(_mappingListWasChosen:)
                                                  keyEquivalent:@""];
            // There must be a represented object here so the item gets
            // removed correctly when the menus are regenerated.
            end.representedObject = self.class;
            end.target = self;
            [self.menu insertItem:end atIndex:index];
            break;
        }
    }
}

- (void)mappingDidChange:(NSNotification *)note {
    NJMapping *mapping = note.userInfo[NJMappingKey];
    for (NSMenuItem *item in self.menu.itemArray)
        if ([item.representedObject isKindOfClass:NJMapping.class])
            item.state = mapping == item.representedObject;
}

- (void)eventSimulationStarted:(NSNotification *)note {
    self.eventSimulationToggle.title = NSLocalizedString(@"Disable",
                                                          @"menu item text to disable event simulation");
}

- (void)eventSimulationStopped:(NSNotification *)note {
    self.eventSimulationToggle.title = NSLocalizedString(@"Enable",
                                                          @"menu item text to enable event simulation");
}

@end
