//
//  ApplicationController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "ApplicationController.h"

#import "Config.h"
#import "ConfigsController.h"
#import "NJInputController.h"
#import "TargetController.h"
#import "NJEvents.h"

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
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	[NSUserDefaults.standardUserDefaults synchronize];
}

- (void)eventTranslationActivated:(NSNotification *)note {
    activeButton.image = [NSImage imageNamed:@"NSStopProgressFreestandingTemplate"];
    activeMenuItem.state = [note.object translatingEvents];
    [NSWorkspace.sharedWorkspace.notificationCenter
     addObserver:self
     selector:@selector(didSwitchApplication:)
     name:NSWorkspaceDidActivateApplicationNotification
     object:nil];
    NSLog(@"Listening for application changes.");
}

- (void)eventTranslationDeactivated:(NSNotification *)note {
    activeButton.image = [NSImage imageNamed:@"NSGoRightTemplate"];
    activeMenuItem.state = [note.object translatingEvents];
    [NSWorkspace.sharedWorkspace.notificationCenter
     removeObserver:self
     name:NSWorkspaceDidActivateApplicationNotification
     object:nil];
    NSLog(@"Ignoring application changes.");
}

- (IBAction)toggleActivity:(id)sender {
    self.jsController.translatingEvents = !self.jsController.translatingEvents;
}

- (NSInteger)firstConfigMenuIndex {
    for (NSInteger i = dockMenuBase.numberOfItems - 1; i >= 0; --i)
        if ([dockMenuBase itemAtIndex:i].isSeparatorItem)
            return i + 1;
    return dockMenuBase.numberOfItems;
}

- (void)configsChanged {
    NSInteger removeFrom = self.firstConfigMenuIndex;
    while (dockMenuBase.numberOfItems > removeFrom)
        [dockMenuBase removeItemAtIndex:dockMenuBase.numberOfItems - 1];
    int added = 0;
    for (Config *config in self.configsController.configs) {
        NSString *keyEquiv = ++added < 10 ? @(added).stringValue : @"";
        [dockMenuBase addItemWithTitle:config.name
                                action:@selector(chooseConfig:)
                         keyEquivalent:keyEquiv];
        
    }
    [_targetController refreshConfigs];
}

- (void)mappingDidChange:(NSNotification *)note {
    NSInteger firstConfig = self.firstConfigMenuIndex;
    Config *current = note.object;
    NSArray *configs = self.configsController.configs;
    for (NSUInteger i = 0; i < configs.count; ++i)
        [dockMenuBase itemAtIndex:i + firstConfig].state = configs[i] == current;
}

- (void)chooseConfig:(id)sender {
    NSInteger idx = [dockMenuBase indexOfItem:sender] - self.firstConfigMenuIndex;
    Config *chosen = self.configsController.configs[idx];
    [_configsController activateConfig:chosen];
}
@end
