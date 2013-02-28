//
//  ConfigsController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

@implementation ConfigsController {
    NSMutableArray *configs;
	Config *neutralConfig;
}

@synthesize currentConfig;
@synthesize configs;

- (id)init {
	if ((self = [super init])) {
		configs = [[NSMutableArray alloc] init];
		currentConfig = [[Config alloc] init];
		[currentConfig setName: @"(default)"];
		[configs addObject:currentConfig];
	}
	return self;
}

// TODO: Neutral config stuff is a mess.

-(void) restoreNeutralConfig {
	if(!neutralConfig)
		return;
	[self activateConfig: neutralConfig forApplication: NULL];
}

-(void) activateConfig: (Config*)config forApplication: (ProcessSerialNumber*) psn {
	if(currentConfig == config)
		return;

	if(psn) {
		if(!neutralConfig)
			neutralConfig = currentConfig;
	} else {
		neutralConfig = NULL;
	}
	
	if(currentConfig != NULL) {
		[targetController reset];
	}
	currentConfig = config;
	[removeButton setEnabled:configs[0] != config];
	[targetController load];
	[(ApplicationController *)[[NSApplication sharedApplication] delegate] configChanged];
    [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[configs indexOfObject:config]] byExtendingSelection:NO];
}

- (IBAction)addPressed:(id)sender {
	Config *newConfig = [[Config alloc] init];
    newConfig.name = @"untitled";
	[configs addObject:newConfig];
	[(ApplicationController *)[[NSApplication sharedApplication] delegate] configsChanged];
	[tableView reloadData];
    [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:configs.count - 1] byExtendingSelection:NO];
	[tableView editColumn:0 row:[configs count] - 1 withEvent:nil select:YES];
}

- (IBAction)removePressed:(id)sender {
    if (tableView.selectedRow == 0)
        return;

	Config *current_config = configs[tableView.selectedRow];
	[configs removeObjectAtIndex:tableView.selectedRow];
	
	// remove all "switch to configuration" actions
    for (Config *config in configs) {
		NSMutableDictionary *entries = config.entries;
		for (id key in entries) {
			Target *target = entries[key];
			if ([target isKindOfClass:[TargetConfig class]]
                && [(TargetConfig *)target config] == current_config)
				[entries removeObjectForKey: key];
		}
	}
	[(ApplicationController *)[[NSApplication sharedApplication] delegate] configsChanged];	
	[tableView reloadData];
}

-(void)tableViewSelectionDidChange:(NSNotification *)notify {
    if (tableView.selectedRow >= 0)
        [self activateConfig:configs[tableView.selectedRow] forApplication: NULL];
}
	
- (id)tableView:(NSTableView *)view objectValueForTableColumn:(NSTableColumn *)column row:(int)index {
	return [configs[index] name];
}

- (void)tableView:(NSTableView *)view setObjectValue:obj forTableColumn:(NSTableColumn *)col row:(int)index {
	/* ugly hack so stringification doesn't fail */
	NSString* newName = [(NSString*)obj stringByReplacingOccurrencesOfString: @"~" withString: @""];
	[(Config *)configs[index] setName:newName];
	[targetController refreshConfigsPreservingSelection:YES];
	[tableView reloadData];
	[(ApplicationController *)[[NSApplication sharedApplication] delegate] configsChanged];
}

- (int)numberOfRowsInTableView:(NSTableView*)table {
	return [configs count];
}

- (BOOL)tableView:(NSTableView *)view shouldEditTableColumn:(NSTableColumn *)column row:(int)index {
	return index > 0;
}	

- (Config *)currentConfig {
	return currentConfig;
}

- (Config *)currentNeutralConfig {
	if (neutralConfig)
		return neutralConfig;
	return currentConfig;
}

-(void) save {
    [[NSUserDefaults standardUserDefaults] setObject:[self dumpAll] forKey:@"configurations"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
-(void) load {
	[self loadAllFrom: [[NSUserDefaults standardUserDefaults] objectForKey:@"configurations"]];
}

-(NSDictionary*) dumpAll {
	NSMutableDictionary *envelope = [[NSMutableDictionary alloc] init];
	NSMutableArray* ary = [[NSMutableArray alloc] init];
	for(Config* config in configs) {
		NSMutableDictionary* cfgInfo = [[NSMutableDictionary alloc] init];
		cfgInfo[@"name"] = [config name];
		NSMutableDictionary* cfgEntries = [[NSMutableDictionary alloc] init];
		for(id key in [config entries]) {
			cfgEntries[key] = [[config entries][key]stringify];
		}
		cfgInfo[@"entries"] = cfgEntries;
		[ary addObject: cfgInfo];
	}
	envelope[@"configurationList"] = ary;
	envelope[@"selectedIndex"] = @([configs indexOfObject: [self currentNeutralConfig] ]);
	return envelope;
}
-(void) loadAllFrom: (NSDictionary*) envelope{
	if(envelope == NULL)
		return;
	NSArray* ary = envelope[@"configurationList"];
	
	NSMutableArray* newConfigs = [[NSMutableArray alloc] init];
	// have to do two passes in case config1 refers to config2 via a TargetConfig
	for(int i=0; i<[ary count]; i++) {
		Config* cfg = [[Config alloc] init];
		[cfg setName: ary[i][@"name"]];		
		[newConfigs addObject: cfg];
	}
	for(int i=0; i<[ary count]; i++) {
		NSDictionary* dict = ary[i][@"entries"];
		for(id key in dict) {
			[newConfigs[i] entries][key] = [Target unstringify: dict[key] withConfigList: newConfigs];
		}
	}
	
	configs = newConfigs;
	[tableView reloadData];
	currentConfig = NULL;
	[(ApplicationController *)[[NSApplication sharedApplication] delegate] configsChanged];
	
	int index = [envelope[@"selectedIndex"] intValue];
    if (index < configs.count)
        [self activateConfig: configs[index] forApplication: NULL];
}

-(void) applicationSwitchedTo: (NSString*) name withPsn: (ProcessSerialNumber) psn {
	for(int i=0; i<[configs count]; i++) {
		Config* cfg = configs[i];
		if([[cfg name] isEqualToString: name]) {
			[self activateConfig: cfg forApplication: &psn];
			return;
		}
	}
	[self restoreNeutralConfig];
}

@end
