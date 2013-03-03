//
//  Config.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "Config.h"

#import "NJInput.h"

@implementation Config

- (id)initWithName:(NSString *)name {
    if ((self = [super init])) {
        self.name = name ? name : @"Untitled";
        _entries = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (Target *)objectForKeyedSubscript:(NJInput *)input {
    return input ? _entries[input.uid] : nil;
}

- (void)setObject:(Target *)target forKeyedSubscript:(NJInput *)input {
    if (input) {
        if (target)
            _entries[input.uid] = target;
        else
            [_entries removeObjectForKey:input.uid];
    }
}

- (NSDictionary *)serialize {
    NSMutableDictionary* cfgEntries = [[NSMutableDictionary alloc] initWithCapacity:_entries.count];
    for (id key in _entries) {
        id serialized = [_entries[key] serialize];
        if (serialized)
            cfgEntries[key] = serialized;
    }
    return @{ @"name": _name, @"entries": cfgEntries };
}

@end
