//
//  Config.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "Config.h"

@implementation Config

@synthesize protect, name, entries;

- (id)init {
    if ((self = [super init])) {
        entries = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setTarget:(Target *)target forAction:(JSAction *)jsa {
    entries[[jsa stringify]] = target;
}

- (Target *)getTargetForAction:(JSAction *)jsa {
    return entries[[jsa stringify]];
}

@end
