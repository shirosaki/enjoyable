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
    NSInteger mappingsMenuIndex;
}

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
        selector:@selector(eventTranslationActivated:)
        name:NJEventTranslationActivated
        object:nil];
    [NSNotificationCenter.defaultCenter
        addObserver:self
        selector:@selector(eventTranslationDeactivated:)
        name:NJEventTranslationDeactivated
        object:nil];

    mappingsMenuIndex = dockMenuBase.numberOfItems;
    while (![dockMenuBase itemAtIndex:mappingsMenuIndex - 1].isSeparatorItem)
        --mappingsMenuIndex;
    
    self.outputController.enabled = NO;
    [self.inputController setup];
    [self.mappingsController load];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	[NSUserDefaults.standardUserDefaults synchronize];
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

- (IBAction)toggleActivity:(id)sender {
    self.inputController.translatingEvents = !self.inputController.translatingEvents;
}

- (void)mappingsChanged {
    NSInteger removeFrom = mappingsMenuIndex;
    while (dockMenuBase.numberOfItems > removeFrom)
        [dockMenuBase removeItemAtIndex:dockMenuBase.numberOfItems - 1];
    int added = 0;
    for (NJMapping *mapping in self.mappingsController) {
        NSString *keyEquiv = ++added < 10 ? @(added).stringValue : @"";
        [dockMenuBase addItemWithTitle:mapping.name
                                action:@selector(chooseMapping:)
                         keyEquivalent:keyEquiv];
        
    }
    [_outputController refreshMappings];
}

- (void)mappingDidChange:(NSNotification *)note {
    NJMapping *current = note.object;
    NSArray *mappings = self.mappingsController.mappings;
    for (NSUInteger i = 0; i < mappings.count; ++i)
        [dockMenuBase itemAtIndex:i + mappingsMenuIndex].state = mappings[i] == current;
}

- (void)chooseMapping:(id)sender {
    NSInteger idx = [dockMenuBase indexOfItem:sender] - mappingsMenuIndex;
    NJMapping *chosen = self.mappingsController[idx];
    [_mappingsController activateMapping:chosen];
}

@end
