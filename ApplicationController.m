//
//  ApplicationController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "ApplicationController.h"

#import "NJMapping.h"
#import "NJMappingsController.h"
#import "NJInputController.h"
#import "TargetController.h"
#import "NJEvents.h"

@implementation ApplicationController {
    BOOL active;
}

- (void)didSwitchApplication:(NSNotification *)notification {
    NSRunningApplication *currentApp = notification.userInfo[NSWorkspaceApplicationKey];
    [self.mappingsController activateMappingForProcess:currentApp.localizedName];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [drawer open];
    self.targetController.enabled = NO;
    [self.inputController setup];
    [self.mappingsController load];
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
    self.inputController.translatingEvents = !self.inputController.translatingEvents;
}

- (NSInteger)firstMappingMenuIndex {
    for (NSInteger i = dockMenuBase.numberOfItems - 1; i >= 0; --i)
        if ([dockMenuBase itemAtIndex:i].isSeparatorItem)
            return i + 1;
    return dockMenuBase.numberOfItems;
}

- (void)mappingsChanged {
    NSInteger removeFrom = self.firstMappingMenuIndex;
    while (dockMenuBase.numberOfItems > removeFrom)
        [dockMenuBase removeItemAtIndex:dockMenuBase.numberOfItems - 1];
    int added = 0;
    for (NJMapping *mapping in self.mappingsController.mappings) {
        NSString *keyEquiv = ++added < 10 ? @(added).stringValue : @"";
        [dockMenuBase addItemWithTitle:mapping.name
                                action:@selector(chooseMapping:)
                         keyEquivalent:keyEquiv];
        
    }
    [_targetController refreshMappings];
}

- (void)mappingDidChange:(NSNotification *)note {
    NSInteger firstMapping = self.firstMappingMenuIndex;
    NJMapping *current = note.object;
    NSArray *mappings = self.mappingsController.mappings;
    for (NSUInteger i = 0; i < mappings.count; ++i)
        [dockMenuBase itemAtIndex:i + firstMapping].state = mappings[i] == current;
}

- (void)chooseMapping:(id)sender {
    NSInteger idx = [dockMenuBase indexOfItem:sender] - self.firstMappingMenuIndex;
    NJMapping *chosen = self.mappingsController.mappings[idx];
    [_mappingsController activateMapping:chosen];
}
@end
