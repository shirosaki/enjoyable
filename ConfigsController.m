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
    NSMutableArray *_configs;
    Config *manualConfig;
}

- (id)init {
    if ((self = [super init])) {
        _configs = [[NSMutableArray alloc] init];
        _currentConfig = [[Config alloc] initWithName:@"(default)"];
        manualConfig = _currentConfig;
        [_configs addObject:_currentConfig];
    }
    return self;
}

- (Config *)objectForKeyedSubscript:(NSString *)name {
    for (Config *config in _configs)
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
    if (_currentConfig == config)
        return;
    manualConfig = config;
    _currentConfig = config;
    [removeButton setEnabled:_configs[0] != config];
    [targetController loadCurrent];
    [(ApplicationController *)[[NSApplication sharedApplication] delegate] configChanged];
    [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[_configs indexOfObject:config]] byExtendingSelection:NO];
}

- (IBAction)addPressed:(id)sender {
    Config *newConfig = [[Config alloc] initWithName:@"Untitled"];
    [_configs addObject:newConfig];
    [(ApplicationController *)[[NSApplication sharedApplication] delegate] configsChanged];
    [tableView reloadData];
    [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:_configs.count - 1] byExtendingSelection:NO];
    [tableView editColumn:0 row:_configs.count - 1 withEvent:nil select:YES];
}

- (IBAction)removePressed:(id)sender {
    if (tableView.selectedRow == 0)
        return;
    
    Config *toRemove = _configs[tableView.selectedRow];
    [_configs removeObjectAtIndex:tableView.selectedRow];
    
    if (toRemove == _currentConfig)
        _currentConfig = _configs[0];
    if (toRemove == manualConfig)
        manualConfig = _configs[0];
    
    [(ApplicationController *)[[NSApplication sharedApplication] delegate] configsChanged];
    [tableView reloadData];
}

-(void)tableViewSelectionDidChange:(NSNotification *)notify {
    if (tableView.selectedRow >= 0)
        [self activateConfig:_configs[tableView.selectedRow]];
}

- (id)tableView:(NSTableView *)view objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)index {
    return [_configs[index] name];
}

- (void)tableView:(NSTableView *)view setObjectValue:(NSString *)obj forTableColumn:(NSTableColumn *)col row:(NSInteger)index {
    [(Config *)_configs[index] setName:obj];
    [tableView reloadData];
    [(ApplicationController *)[[NSApplication sharedApplication] delegate] configsChanged];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _configs.count;
}

- (BOOL)tableView:(NSTableView *)view shouldEditTableColumn:(NSTableColumn *)column row:(NSInteger)index {
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
    NSMutableArray *ary = [[NSMutableArray alloc] initWithCapacity:_configs.count];
    for (Config *config in _configs)
        [ary addObject:[config serialize]];
    NSUInteger current = _currentConfig ? [_configs indexOfObject:_currentConfig] : 0;
    return @{ @"configurations": ary, @"selected": @(current) };
}

- (void)loadAllFrom:(NSDictionary*) envelope{
    NSArray *storedConfigs = envelope[@"configurations"];
    NSMutableArray* newConfigs = [[NSMutableArray alloc] initWithCapacity:storedConfigs.count];

    // have to do two passes in case config1 refers to config2 via a TargetConfig
    for (NSDictionary *storedConfig in storedConfigs) {
        Config *cfg = [[Config alloc] initWithName:storedConfig[@"name"]];
        [newConfigs addObject:cfg];
    }

    for (unsigned i = 0; i < storedConfigs.count; ++i) {
        NSDictionary *entries = storedConfigs[i][@"entries"];
        Config *config = newConfigs[i];
        for (id key in entries)
            config.entries[key] = [Target targetDeserialize:entries[key]
                                                withConfigs:newConfigs];
    }
    
    if (newConfigs.count) {
        unsigned current = [envelope[@"selected"] unsignedIntValue];
        if (current >= newConfigs.count)
            current = 0;
        _configs = newConfigs;
        [tableView reloadData];
        [(ApplicationController *)[[NSApplication sharedApplication] delegate] configsChanged];
        [self activateConfig:_configs[current]];
    }
}

- (void)exportPressed:(id)sender {
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.allowedFileTypes = @[ @"enjoyable" ];
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        NSError *error;
        NSDictionary *serialization = [_currentConfig serialize];
        NSData *json = [NSJSONSerialization dataWithJSONObject:serialization
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
        if (!error)
            [json writeToURL:panel.URL options:NSDataWritingAtomic error:&error];
        
        if (error)
            [[NSAlert alertWithError:error] runModal];
    }
}

@end
