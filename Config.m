//
//  Config.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "Config.h"

#import "JSAction.h"

@implementation Config {
    NSMutableDictionary *entries;
}

@synthesize name;
@synthesize entries;

- (id)init {
    if ((self = [super init])) {
        entries = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (Target *)objectForKeyedSubscript:(JSAction *)action {
    return action ? entries[action.uid] : nil;
}

- (void)setObject:(Target *)target forKeyedSubscript:(JSAction *)action {
    if (action) {
        if (target)
            entries[action.uid] = target;
        else
            [entries removeObjectForKey:action.uid];
    }
}

@end
