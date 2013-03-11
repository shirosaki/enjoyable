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

@implementation EnjoyableApplicationDelegate {
    NSStatusItem *statusItem;
}

- (void)didSwitchApplication:(NSNotification *)note {
    NSRunningApplication *activeApp = note.userInfo[NSWorkspaceApplicationKey];
    if (activeApp)
        [self.mappingsController activateMappingForProcess:activeApp];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
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

    [self.mappingsController load];

    statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:36];
    statusItem.image = [NSImage imageNamed:@"Status Menu Icon Disabled"];
    statusItem.highlightMode = YES;
    statusItem.menu = statusItemMenu;
    statusItem.target = self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [window makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag {
    [self restoreToForeground:theApplication];
    return NO;
}

- (void)restoreToForeground:(id)sender {
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    [NSApplication.sharedApplication activateIgnoringOtherApps:YES];
    [window makeKeyAndOrderFront:sender];
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(transformIntoElement:)
                                               object:self];
}

- (void)transformIntoElement:(id)sender {
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToUIElementApplication);
}

- (void)flashStatusItem {
    if ([statusItem.image.name isEqualToString:@"Status Menu Icon"]) {
        statusItem.image = [NSImage imageNamed:@"Status Menu Icon Disabled"];
    } else {
        statusItem.image = [NSImage imageNamed:@"Status Menu Icon"];
    }
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    [theApplication hide:theApplication];
    // If we turn into a UIElement right away, the application cancels
    // the deactivation events. The dock icon disappears, but an
    // unresponsive menu bar remains until the user clicks somewhere.
    // So delay just long enough to be past the end handling that.
    [self performSelector:@selector(transformIntoElement:) withObject:self afterDelay:0.001];
    return NO;
}

- (void)eventTranslationActivated:(NSNotification *)note {
    [dockMenu itemAtIndex:0].state = NSOnState;
    [statusItemMenu itemAtIndex:0].state = NSOnState;
    statusItem.image = [NSImage imageNamed:@"Status Menu Icon"];
    [NSWorkspace.sharedWorkspace.notificationCenter
        addObserver:self
        selector:@selector(didSwitchApplication:)
        name:NSWorkspaceDidActivateApplicationNotification
        object:nil];
}

- (void)eventTranslationDeactivated:(NSNotification *)note {
    [dockMenu itemAtIndex:0].state = NSOffState;
    [statusItemMenu itemAtIndex:0].state = NSOffState;
    statusItem.image = [NSImage imageNamed:@"Status Menu Icon Disabled"];
    [NSWorkspace.sharedWorkspace.notificationCenter
        removeObserver:self
        name:NSWorkspaceDidActivateApplicationNotification
        object:nil];
}

- (void)restoreWindowAndShowMappings:(id)sender {
    [self restoreToForeground:sender];
    [self.mappingsController mappingPressed:sender];
}

- (void)addMappings:(NSArray *)mappings
             toMenu:(NSMenu *)menu
           withKeys:(BOOL)withKeys
            atIndex:(NSInteger)index {
    static const NSUInteger MAXIMUM_ITEMS = 15;
    int added = 0;
    for (NJMapping *mapping in mappings) {
        NSString *keyEquiv = (++added < 10 && withKeys) ? @(added).stringValue : @"";
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:mapping.name
                                                      action:@selector(chooseMapping:)
                                               keyEquivalent:keyEquiv];
        item.representedObject = mapping;
        item.state = mapping == self.mappingsController.currentMapping;
        [menu insertItem:item atIndex:index++];
        if (added == MAXIMUM_ITEMS && self.mappingsController.mappings.count > MAXIMUM_ITEMS + 1) {
            NSString *msg = [NSString stringWithFormat:@"(and %lu more…)",
                             self.mappingsController.mappings.count - MAXIMUM_ITEMS];
            NSMenuItem *end = [[NSMenuItem alloc] initWithTitle:msg
                                                         action:@selector(restoreWindowAndShowMappings:)
                                                  keyEquivalent:@""];
            // There must be a represented object here so the item gets
            // removed correctly when the menus are regenerated.
            end.representedObject = mappings;
            end.target = self;
            [menu insertItem:end atIndex:index++];
            break;
        }
    }    
}

- (void)mappingListDidChange:(NSNotification *)note {
    NSArray *mappings = note.userInfo[@"mappings"];
    while (mappingsMenu.lastItem.representedObject)
        [mappingsMenu removeLastItem];
    [self addMappings:mappings
               toMenu:mappingsMenu
             withKeys:YES
              atIndex:mappingsMenu.numberOfItems];
    while ([statusItemMenu itemAtIndex:2].representedObject)
        [statusItemMenu removeItemAtIndex:2];
    [self addMappings:mappings toMenu:statusItemMenu withKeys:NO atIndex:2];
}

- (void)mappingDidChange:(NSNotification *)note {
    NJMapping *current = note.userInfo[@"mapping"];
    for (NSMenuItem *item in mappingsMenu.itemArray)
        if (item.representedObject)
            item.state = item.representedObject == current;
    for (NSMenuItem *item in statusItemMenu.itemArray)
        if (item.representedObject)
            item.state = item.representedObject == current;
    
    if (!window.isVisible)
        for (int i = 0; i < 4; ++i)
            [self performSelector:@selector(flashStatusItem)
                       withObject:self
                       afterDelay:0.2 * i];
}

- (void)chooseMapping:(NSMenuItem *)sender {
    NJMapping *chosen = sender.representedObject;
    [self.mappingsController activateMapping:chosen];
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
    while (dockMenu.lastItem.representedObject)
        [dockMenu removeLastItem];
    [self addMappings:self.mappingsController.mappings
               toMenu:dockMenu
             withKeys:NO
              atIndex:dockMenu.numberOfItems];
    return dockMenu;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    [self restoreToForeground:sender];
    NSURL *url = [NSURL fileURLWithPath:filename];
    [self.mappingsController addMappingWithContentsOfURL:url];
    return YES;
}


@end
