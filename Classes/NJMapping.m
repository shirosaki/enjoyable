//
//  NJMapping.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "NJMapping.h"

#import "NJInput.h"
#import "NJOutput.h"

@implementation NJMapping {
    NSMutableDictionary *_entries;
}

// Extra checks during initialization because the data is often loaded
// from untrusted serializations.

- (id)init {
    if ((self = [super init])) {
        self.name = NSLocalizedString(@"Untitled", @"name for new mappings");
        _entries = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initWithName:(NSString *)name {
    if ((self = [self init])) {
        if ([name isKindOfClass:NSString.class])
            self.name = name;
    }
    return self;
}

- (id)initWithSerialization:(NSDictionary *)serialization {
    if ((self = [self initWithName:serialization[@"name"]])) {
        NSDictionary *entries = serialization[@"entries"];
        if ([entries isKindOfClass:NSDictionary.class]) {
            for (id key in entries) {
                if ([key isKindOfClass:NSString.class]) {
                    NJOutput *output = [NJOutput outputWithSerialization:entries[key]];
                    if (output)
                        _entries[key] = output;
                }
            }
        }
    }
    return self;
}

- (NJOutput *)objectForKeyedSubscript:(NJInput *)input {
    return input ? _entries[input.uid] : nil;
}

- (void)setObject:(NJOutput *)output forKeyedSubscript:(NJInput *)input {
    if (input) {
        if (output)
            _entries[input.uid] = output;
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

- (BOOL)writeToURL:(NSURL *)url error:(NSError **)error {
    [NSProcessInfo.processInfo disableSuddenTermination];
    NSDictionary *serialization = [self serialize];
    NSData *json = [NSJSONSerialization dataWithJSONObject:serialization
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:error];
    BOOL success = json && [json writeToURL:url options:NSDataWritingAtomic error:error];
    [NSProcessInfo.processInfo enableSuddenTermination];
    return success;
}

- (NSUInteger)count {
    return _entries.count;
}

- (BOOL)hasConflictWith:(NJMapping *)other {
    if (other.count < self.count)
        return [other hasConflictWith:self];
    for (NSString *uid in _entries) {
        NJOutput *output = other->_entries[uid];
        if (output && ![output isEqual:_entries[uid]])
            return YES;
    }
    return NO;
}

+ (id)mappingWithContentsOfURL:(NSURL *)url error:(NSError **)error {
    NSInputStream *stream = [NSInputStream inputStreamWithURL:url];
    [stream open];
    NSDictionary *serialization = stream && !*error
        ? [NSJSONSerialization JSONObjectWithStream:stream
                                            options:(NSJSONReadingOptions)0
                                              error:error]
        : nil;
    [stream close];
    
    if (!serialization && error)
        return nil;
    
    if (!([serialization isKindOfClass:NSDictionary.class]
          && [serialization[@"name"] isKindOfClass:NSString.class]
          && [serialization[@"entries"] isKindOfClass:NSDictionary.class])) {
        *error = [NSError errorWithDomain:@"Enjoyable"
                                     code:0
                              description:NSLocalizedString(@"invalid mapping file",
                                                            @"error when imported file was JSON but not a mapping")];
        return nil;
    }
    
    return [[NJMapping alloc] initWithSerialization:serialization];
}

- (void)mergeEntriesFrom:(NJMapping *)other {
    if (other)
        [_entries addEntriesFromDictionary:other->_entries];
}

- (void)postLoadProcess:(id <NSFastEnumeration>)allMappings {
    for (NJOutput *o in _entries.allValues)
        [o postLoadProcess:allMappings];
}


@end
