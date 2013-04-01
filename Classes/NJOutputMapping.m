//
//  NJOutputMapping.m
//  Enjoy
//
//  Created by Sam McCall on 6/05/09.
//

#import "NJOutputMapping.h"

#import "EnjoyableApplicationDelegate.h"
#import "NJMapping.h"

@implementation NJOutputMapping

+ (NSString *)serializationCode {
    return @"mapping";
}

- (NSDictionary *)serialize {
    NSString *name = _mapping ? _mapping.name : self.mappingName;
    return name
        ? @{ @"type": self.class.serializationCode, @"name": name }
        : nil;
}

+ (NJOutputMapping *)outputWithSerialization:(NSDictionary *)serialization {
    NSString *name = serialization[@"name"];
    NJOutputMapping *output = [[NJOutputMapping alloc] init];
    output.mappingName = name;
    return name ? output : nil;
}

- (void)trigger {
    EnjoyableApplicationDelegate *ctrl = (EnjoyableApplicationDelegate *)NSApplication.sharedApplication.delegate;
    if (_mapping) {
        [ctrl.ic activateMapping:_mapping];
        self.mappingName = _mapping.name;
    } else {
        // TODO: Show an error message? Unobtrusively since something
        // is probably running.
    }
}

- (void)postLoadProcess:(id <NSFastEnumeration>)allMappings {
    if (!self.mapping) {
        for (NJMapping *mapping in allMappings) {
            if ([mapping.name isEqualToString:self.mappingName]) {
                self.mapping = mapping;
                break;
            }
        }
    }
}

@end
