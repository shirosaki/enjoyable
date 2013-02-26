//
//  ApplicationController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

@implementation ApplicationController {
    BOOL active;
}

@synthesize jsController, targetController, configsController;

- (void)didSwitchApplication:(NSNotification *)notification {
    NSRunningApplication *currentApp = notification.userInfo[NSWorkspaceApplicationKey];
	ProcessSerialNumber psn;
    OSStatus err;
    if ((err = GetProcessForPID(currentApp.processIdentifier, &psn)) == noErr) {
        [self->configsController applicationSwitchedTo:currentApp.localizedName withPsn:psn];
    } else {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
        NSLog(@"Error getting PSN for %@: %@", currentApp.localizedName, error);
    }
}

-(void) applicationDidFinishLaunching:(NSNotification*) notification {
	[jsController setup];
	[drawer open];
	[targetController setEnabled: NO];
    self.active = NO;
	[configsController load];
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver:self
     selector:@selector(didSwitchApplication:)
     name:NSWorkspaceDidActivateApplicationNotification
     object:nil];
}

-(void) applicationWillTerminate: (NSNotification *)aNotification {
	[configsController save];
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     removeObserver:self
     name:NSWorkspaceDidActivateApplicationNotification
     object:nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
					 hasVisibleWindows:(BOOL)flag
{	
	[mainWindow makeKeyAndOrderFront:self];
	return YES;
}

- (BOOL)active {
    return active;
}

- (void)setActive:(BOOL)newActive {
	[activeButton setLabel:newActive ? @"Stop" : @"Start"];
    NSImage *buttonImage = [NSImage imageNamed:newActive ? @"NSStopProgressFreestandingTemplate" : @"NSGoRightTemplate"];
	[activeButton setImage:buttonImage];
	[activeMenuItem setState:newActive];
	active = newActive;
}

- (IBAction)toggleActivity:(id)sender {
    self.active = !self.active;
}

-(void) configsChanged {
	while([dockMenuBase numberOfItems] > 2)
		[dockMenuBase removeItemAtIndex: ([dockMenuBase numberOfItems] - 1)];

	for(Config* config in [configsController configs]) {
		[dockMenuBase addItemWithTitle:[config name] action:@selector(chooseConfig:) keyEquivalent:@""];
	}
	[self configChanged];
}
-(void) configChanged {
	Config* current = [configsController currentConfig];
	NSArray* configs = [configsController configs];
	for(int i=0; i<[configs count]; i++)
		[[dockMenuBase itemAtIndex: (2+i)] setState: (configs[i] == current)];
}

-(void) chooseConfig: (id) sender {
	[configsController activateConfig: [configsController configs][([dockMenuBase indexOfItem: sender]-2)] forApplication: NULL];
}
@end
