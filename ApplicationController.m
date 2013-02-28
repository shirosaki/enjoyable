//
//  ApplicationController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

@implementation ApplicationController {
    BOOL active;
}

@synthesize jsController;
@synthesize targetController;
@synthesize configsController;

- (void)didSwitchApplication:(NSNotification *)notification {
    NSRunningApplication *currentApp = notification.userInfo[NSWorkspaceApplicationKey];
    [self.configsController activateConfigForProcess:currentApp.localizedName];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [drawer open];
    self.targetController.enabled = NO;
    self.active = NO;
    [self.jsController setup];
    [self.configsController load];
    [[NSWorkspace sharedWorkspace].notificationCenter
     addObserver:self
     selector:@selector(didSwitchApplication:)
     name:NSWorkspaceDidActivateApplicationNotification
     object:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // TODO: Save immediately / shortly after changing and then enable
    // sudden termination support.
    [configsController save];
    [[NSWorkspace sharedWorkspace].notificationCenter
     removeObserver:self
     name:NSWorkspaceDidActivateApplicationNotification
     object:nil];
}

// TODO: Active state should probably be in the ConfigsController or
// JoystickController, not here.

- (BOOL)active {
    return active;
}

- (void)setActive:(BOOL)newActive {
    activeButton.label = newActive ? @"Stop" : @"Start";
    activeButton.image = [NSImage imageNamed:newActive ? @"NSStopProgressFreestandingTemplate" : @"NSGoRightTemplate"];
    activeMenuItem.state = newActive;
    active = newActive;
}

- (IBAction)toggleActivity:(id)sender {
    self.active = !self.active;
}

- (NSUInteger)firstConfigMenuIndex {
    NSUInteger count = dockMenuBase.numberOfItems;
    for (int i = 0; i < count; ++i)
        if ([dockMenuBase itemAtIndex:i].isSeparatorItem)
            return i + 1;
    return count;
}

- (void)configsChanged {
    NSUInteger removeFrom = [self firstConfigMenuIndex];
    while (dockMenuBase.numberOfItems > removeFrom)
        [dockMenuBase removeItemAtIndex:dockMenuBase.numberOfItems - 1];
    for (Config *config in self.configsController.configs)
        [dockMenuBase addItemWithTitle:config.name action:@selector(chooseConfig:) keyEquivalent:@""];
    [self configChanged];
}

- (void)configChanged {
    NSUInteger firstConfig = [self firstConfigMenuIndex];
    Config *current = self.configsController.currentConfig;
    NSArray *configs = self.configsController.configs;
    for (int i = 0; i < configs.count; ++i)
        [dockMenuBase itemAtIndex:i + firstConfig].state = configs[i] == current;
}

- (void)chooseConfig:(id)sender {
    int idx = [dockMenuBase indexOfItem:sender] - [self firstConfigMenuIndex];
    Config *chosen = self.configsController.configs[idx];
    [configsController activateConfig:chosen];
}
@end
