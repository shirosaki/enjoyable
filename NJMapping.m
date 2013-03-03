//
//  NJMapping.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "NJMapping.h"

#import "NJInput.h"

@implementation NJMapping

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
    NSMutableDictionary *entries = [[NSMutableDictionary alloc] initWithCapacity:_entries.count];
    for (id key in _entries) {
        id serialized = [_entries[key] serialize];
        if (serialized)
            entries[key] = serialized;
    }
    return @{ @"name": _name, @"entries": entries };
}

@end
