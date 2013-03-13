//
//  EnjoyableApplicationDelegate.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "EnjoyableApplicationDelegate.h"

#import "NJMapping.h"
#import "NJMappingsController.h"
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

- (void)applicationWillBecomeActive:(NSNotification *)notification {
    [self restoreToForeground:notification];
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
    statusItem.image = [NSImage imageNamed:@"Status Menu Icon"];
    [NSWorkspace.sharedWorkspace.notificationCenter
        addObserver:self
        selector:@selector(didSwitchApplication:)
        name:NSWorkspaceDidActivateApplicationNotification
        object:nil];
}

- (void)eventTranslationDeactivated:(NSNotification *)note {
    statusItem.image = [NSImage imageNamed:@"Status Menu Icon Disabled"];
    [NSWorkspace.sharedWorkspace.notificationCenter
        removeObserver:self
        name:NSWorkspaceDidActivateApplicationNotification
        object:nil];
}

- (void)mappingDidChange:(NSNotification *)note {
    if (!window.isVisible)
        for (int i = 0; i < 4; ++i)
            [self performSelector:@selector(flashStatusItem)
                       withObject:self
                       afterDelay:0.2 * i];
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
    return dockMenu;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    [self restoreToForeground:sender];
    NSURL *url = [NSURL fileURLWithPath:filename];
    [self.mappingsController addMappingWithContentsOfURL:url];
    return YES;
}

- (void)mappingWasChosen:(NJMapping *)mapping {
    [self.mappingsController activateMapping:mapping];
}

- (void)mappingListShouldOpen {
    [self restoreToForeground:self];
    [self.mappingsController mappingPressed:self];
}


@end
