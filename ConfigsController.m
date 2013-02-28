//
//  ConfigsController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "ConfigsController.h"

#import "ApplicationController.h"
#import "Config.h"
#import "ConfigsController.h"
#import "Target.h"
#import "TargetController.h"

@implementation ConfigsController {
    NSMutableArray *configs;
	Config *manualConfig;
}

@synthesize currentConfig;
@synthesize configs;

- (id)init {
	if ((self = [super init])) {
		configs = [[NSMutableArray alloc] init];
        currentConfig = [[Config alloc] init];
        currentConfig.name = @"(default)";
        manualConfig = currentConfig;
		[configs addObject:currentConfig];
	}
	return self;
}

- (Config *)objectForKeyedSubscript:(NSString *)name {
    for (Config *config in configs)
        if ([name isEqualToString:config.name])
            return config;
    return nil;
}

- (void)activateConfigForProcess:(NSString *)processName {
    Config *oldConfig = manualConfig;
    [self activateConfig:self[processName]];
    manualConfig = oldConfig;
}

- (void)activateConfig:(Config *)config {
    if (!config)
        config = manualConfig;
	if (currentConfig == config)
		return;
    manualConfig = config;
	currentConfig = config;
    [targetController reset];
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

	Config *toRemove = configs[tableView.selectedRow];
	[configs removeObjectAtIndex:tableView.selectedRow];
    
    if (toRemove == currentConfig)
        currentConfig = configs[0];
    if (toRemove == manualConfig)
        manualConfig = configs[0];
	
	[(ApplicationController *)[[NSApplication sharedApplication] delegate] configsChanged];	
	[tableView reloadData];
}

-(void)tableViewSelectionDidChange:(NSNotification *)notify {
    if (tableView.selectedRow >= 0)
        [self activateConfig:configs[tableView.selectedRow]];
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
	
    if (newConfigs.count) {
        configs = newConfigs;
        [tableView reloadData];
        currentConfig = configs[0];
        manualConfig = configs[0];
        [(ApplicationController *)[[NSApplication sharedApplication] delegate] configsChanged];
    }
}

@end
