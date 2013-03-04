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

- (void)didSwitchApplication:(NSNotification *)notification {
    NSRunningApplication *currentApp = notification.userInfo[NSWorkspaceApplicationKey];
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

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	[NSUserDefaults.standardUserDefaults synchronize];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)eventTranslationActivated:(NSNotification *)note {
    [NSWorkspace.sharedWorkspace.notificationCenter
        addObserver:self
        selector:@selector(didSwitchApplication:)
        name:NSWorkspaceDidActivateApplicationNotification
        object:nil];
    NSLog(@"Listening for application changes.");
}

- (void)eventTranslationDeactivated:(NSNotification *)note {
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
        NSMenuItem *item = [dockMenuBase addItemWithTitle:mapping.name
                                                   action:@selector(chooseMapping:)
                                            keyEquivalent:keyEquiv];
        item.representedObject = mapping;
    }
    [_outputController refreshMappings];
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
