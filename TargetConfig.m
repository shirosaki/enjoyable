//
//  TargetConfig.m
//  Enjoy
//
//  Created by Sam McCall on 6/05/09.
//

#import "TargetConfig.h"

#import "ApplicationController.h"
#import "NJMapping.h"
#import "NJMappingsController.h"

@implementation TargetConfig

+ (NSString *)serializationCode {
    return @"mapping";
}

- (NSDictionary *)serialize {
    return _mapping
        ? @{ @"type": @"mapping", @"name": _mapping.name }
        : nil;
}

+ (TargetConfig *)targetDeserialize:(NSDictionary *)serialization
                        withMappings:(NSArray *)mappings {
    NSString *name = serialization[@"name"];
    TargetConfig *target = [[TargetConfig alloc] init];
    for (NJMapping *mapping in mappings) {
        if ([mapping.name isEqualToString:name]) {
            target.mapping = mapping;
            return target;
        }
    }
    return nil;
}

- (void)trigger {
    ApplicationController *ctrl = NSApplication.sharedApplication.delegate;
    [ctrl.mappingsController activateMapping:_mapping];
}

@end
