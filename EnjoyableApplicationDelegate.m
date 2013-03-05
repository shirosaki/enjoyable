//
//  EnjoyableApplicationDelegate.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "EnjoyableApplicationDelegate.h"

#import "NJMapping.h"
#import "NJMappingsController.h"
#import "NJDeviceController.h"
#import "NJOutputController.h"
#import "NJEvents.h"

@implementation EnjoyableApplicationDelegate

- (void)didSwitchApplication:(NSNotification *)note {
    NSRunningApplication *currentApp = note.userInfo[NSWorkspaceApplicationKey];
    [self.mappingsController activateMappingForProcess:currentApp.localizedName];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSNotificationCenter.defaultCenter
        addObserver:self
        selector:@selector(mappingDidChange:)
        name:NJEventMappingChanged
        object:nil];
    [NSNotificationCenter.defaultCenter
        addObserver:self
        selector:@selector(mappingListDidChange:)
        name:NJEventMappingListChanged
        object:nil];
    [NSNotificationCenter.defaultCenter
        addObserver:self
        selector:@selector(eventTranslationActivated:)
        name:NJEventTranslationActivated
        object:nil];
    [NSNotificationCenter.defaultCenter
        addObserver:self
        selector:@selector(eventTranslationDeactivated:)
        name:NJEventTranslationDeactivated
        object:nil];

    [self.inputController setup];
    [self.mappingsController load];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [window makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag {
    [window makeKeyAndOrderFront:nil];
    return NO;
}

- (void)eventTranslationActivated:(NSNotification *)note {
    [NSProcessInfo.processInfo disableAutomaticTermination:@"Input translation is active."];
    [NSWorkspace.sharedWorkspace.notificationCenter
        addObserver:self
        selector:@selector(didSwitchApplication:)
        name:NSWorkspaceDidActivateApplicationNotification
        object:nil];
    NSLog(@"Listening for application changes.");
}

- (void)eventTranslationDeactivated:(NSNotification *)note {
    [NSProcessInfo.processInfo enableAutomaticTermination:@"Input translation is active."];
    [NSWorkspace.sharedWorkspace.notificationCenter
        removeObserver:self
        name:NSWorkspaceDidActivateApplicationNotification
        object:nil];
    NSLog(@"Ignoring application changes.");
}

- (void)mappingListDidChange:(NSNotification *)note {
    NSArray *mappings = note.object;
    while (dockMenuBase.lastItem.representedObject)
        [dockMenuBase removeLastItem];
    int added = 0;
    for (NJMapping *mapping in mappings) {
        NSString *keyEquiv = ++added < 10 ? @(added).stringValue : @"";
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:mapping.name
                                                      action:@selector(chooseMapping:)
                                               keyEquivalent:keyEquiv];
        item.representedObject = mapping;
        item.state = mapping == self.mappingsController.currentMapping;
        [dockMenuBase addItem:item];
    }
}

- (void)mappingDidChange:(NSNotification *)note {
    NJMapping *current = note.object;
    for (NSMenuItem *item in dockMenuBase.itemArray)
        if (item.representedObject)
            item.state = item.representedObject == current;
}

- (void)chooseMapping:(NSMenuItem *)sender {
    NJMapping *chosen = sender.representedObject;
    [self.mappingsController activateMapping:chosen];
}

@end
