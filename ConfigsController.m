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

- (void)tableView:(NSTableView *)view setObjectValue:(NSString *)obj forTableColumn:(NSTableColumn *)col row:(int)index {
    [(Config *)configs[index] setName:obj];
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

- (void)save {
    NSLog(@"Saving defaults.");
    [[NSUserDefaults standardUserDefaults] setObject:[self dumpAll] forKey:@"configurations"];
}

- (void)load {
    [self loadAllFrom:[[NSUserDefaults standardUserDefaults] objectForKey:@"configurations"]];
}

- (NSDictionary *)dumpAll {
    NSMutableArray *ary = [[NSMutableArray alloc] initWithCapacity:configs.count];
    for (Config *config in configs) {
        NSMutableDictionary* cfgEntries = [[NSMutableDictionary alloc] initWithCapacity:config.entries.count];
        for (id key in config.entries)
            cfgEntries[key] = [config.entries[key] serialize];
        [ary addObject:@{ @"name": config.name,
                          @"entries": cfgEntries,
                        }];
    }
    NSUInteger current = currentConfig ? [configs indexOfObject:currentConfig] : 0;
    return @{ @"configurationList": ary,
              @"selectedConfiguration": @(current) };
}

- (void)loadAllFrom:(NSDictionary*) envelope{
    NSArray *storedConfigs = envelope[@"configurationList"];
    NSMutableArray* newConfigs = [[NSMutableArray alloc] initWithCapacity:storedConfigs.count];

    // have to do two passes in case config1 refers to config2 via a TargetConfig
    for (NSDictionary *storedConfig in storedConfigs) {
        Config *cfg = [[Config alloc] init];
        cfg.name = storedConfig[@"name"];
        [newConfigs addObject:cfg];
    }

    for (int i = 0; i < storedConfigs.count; ++i) {
        NSDictionary *entries = storedConfigs[i][@"entries"];
        Config *config = newConfigs[i];
        for (id key in entries)
            config.entries[key] = [Target targetDeserialize:entries[key]
                                                withConfigs:newConfigs];
    }
    
    if (newConfigs.count) {
        int current = [envelope[@"selectedConfiguration"] unsignedIntValue];
        if (current >= newConfigs.count)
            current = 0;
        configs = newConfigs;
        [tableView reloadData];
        [(ApplicationController *)[[NSApplication sharedApplication] delegate] configsChanged];
        [self activateConfig:configs[current]];
    }
}

@end
