//
//  TargetConfig.m
//  Enjoy
//
//  Created by Sam McCall on 6/05/09.
//

#import "TargetConfig.h"

#import "ApplicationController.h"
#import "Config.h"
#import "ConfigsController.h"

@implementation TargetConfig

+ (NSString *)serializationCode {
    return @"cfg";
}

- (NSDictionary *)serialize {
    return _config
        ? @{ @"type": @"cfg", @"name": _config.name }
        : nil;
}

+ (TargetConfig *)targetDeserialize:(NSDictionary *)serialization
                        withConfigs:(NSArray *)configs {
    NSString *name = serialization[@"name"];
    TargetConfig *target = [[TargetConfig alloc] init];
    for (Config *config in configs) {
        if ([config.name isEqualToString:name]) {
            target.config = config;
            return target;
        }
    }
    return nil;
}

- (void)trigger {
    ApplicationController *ctrl = NSApplication.sharedApplication.delegate;
    [ctrl.configsController activateConfig:_config];
}

@end
