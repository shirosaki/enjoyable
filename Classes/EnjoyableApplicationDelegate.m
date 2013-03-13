//
//  EnjoyableApplicationDelegate.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import <Sparkle/Sparkle.h>

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
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"hidden in status item"]
        && NSRunningApplication.currentApplication.wasLaunchedAsLoginItemOrResume)
        [self transformIntoElement:nil];
    else
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
    [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"hidden in status item"];
}

- (void)applicationWillBecomeActive:(NSNotification *)notification {
    if (window.isVisible)
        [self restoreToForeground:notification];
}

- (void)transformIntoElement:(id)sender {
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToUIElementApplication);
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"hidden in status item"];
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

- (void)loginItemPromptDidEnd:(NSWindow *)sheet
                   returnCode:(int)returnCode
                  contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertDefaultReturn) {
        [NSRunningApplication.currentApplication addToLoginItems];
        // If we're going to automatically start, don't bug the user
        // about automatic updates next boot - they probably want it,
        // and if they don't they probably want a prompt for it less.
        SUUpdater.sharedUpdater.automaticallyChecksForUpdates = YES;
    }
}

- (void)loginItemPromptDidDismiss:(NSWindow *)sheet
                       returnCode:(int)returnCode
                      contextInfo:(void *)contextInfo {
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"explained login items"];
    [window performClose:sheet];
}

- (BOOL)windowShouldClose:(NSWindow *)sender {
    if (sender != window
        || NSRunningApplication.currentApplication.isLoginItem
        || [NSUserDefaults.standardUserDefaults boolForKey:@"explained login items"])
        return YES;
    NSBeginAlertSheet(
        NSLocalizedString(@"login items prompt", @"alert prompt for adding to login items"),
        NSLocalizedString(@"login items add button", @"button to add to login items"),
        NSLocalizedString(@"login items don't add button", @"button to not add to login items"),
        nil, window, self,
        @selector(loginItemPromptDidEnd:returnCode:contextInfo:),
        @selector(loginItemPromptDidDismiss:returnCode:contextInfo:),
        NULL,
        NSLocalizedString(@"login items explanation", @"a brief explanation of login items")
        );
    for (int i = 0; i < 10; ++i)
        [self performSelector:@selector(flashStatusItem)
                   withObject:self
                   afterDelay:0.5 * i];
    return NO;
}


@end
