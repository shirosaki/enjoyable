//
//  ApplicationController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "ApplicationController.h"

#import "Config.h"
#import "ConfigsController.h"
#import "JoystickController.h"
#import "TargetController.h"

@implementation ApplicationController {
    BOOL active;
}

- (void)didSwitchApplication:(NSNotification *)notification {
    NSRunningApplication *currentApp = notification.userInfo[NSWorkspaceApplicationKey];
    [self.configsController activateConfigForProcess:currentApp.localizedName];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [drawer open];
    self.targetController.enabled = NO;
    [self.jsController setup];
    [self.configsController load];
    [[NSWorkspace sharedWorkspace].notificationCenter
     addObserver:self
     selector:@selector(didSwitchApplication:)
     name:NSWorkspaceDidActivateApplicationNotification
     object:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	[[NSUserDefaults standardUserDefaults] synchronize];
    [[NSWorkspace sharedWorkspace].notificationCenter
     removeObserver:self
     name:NSWorkspaceDidActivateApplicationNotification
     object:nil];
}

- (IBAction)toggleActivity:(id)sender {
    BOOL sendRealEvents = !self.jsController.sendingRealEvents;
    self.jsController.sendingRealEvents = sendRealEvents;
    activeButton.label = sendRealEvents ? @"Stop" : @"Start";
    activeButton.image = [NSImage imageNamed:sendRealEvents ? @"NSStopProgressFreestandingTemplate" : @"NSGoRightTemplate"];
    activeMenuItem.state = sendRealEvents;
}

- (NSInteger)firstConfigMenuIndex {
    NSInteger count = dockMenuBase.numberOfItems;
    for (int i = 0; i < count; ++i)
        if ([dockMenuBase itemAtIndex:i].isSeparatorItem)
            return i + 1;
    return count;
}

- (void)configsChanged {
    NSInteger removeFrom = [self firstConfigMenuIndex];
    while (dockMenuBase.numberOfItems > removeFrom)
        [dockMenuBase removeItemAtIndex:dockMenuBase.numberOfItems - 1];
    for (Config *config in self.configsController.configs)
        [dockMenuBase addItemWithTitle:config.name action:@selector(chooseConfig:) keyEquivalent:@""];
    [_targetController refreshConfigs];
    [self configChanged];
}

- (void)configChanged {
    NSInteger firstConfig = [self firstConfigMenuIndex];
    Config *current = self.configsController.currentConfig;
    NSArray *configs = self.configsController.configs;
    for (int i = 0; i < configs.count; ++i)
        [dockMenuBase itemAtIndex:i + firstConfig].state = configs[i] == current;
}

- (void)chooseConfig:(id)sender {
    NSInteger idx = [dockMenuBase indexOfItem:sender] - [self firstConfigMenuIndex];
    Config *chosen = self.configsController.configs[idx];
    [_configsController activateConfig:chosen];
}
@end
