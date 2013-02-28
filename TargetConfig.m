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

- (NSString *)stringify {
    return [[NSString alloc] initWithFormat: @"cfg~%@", self.config.name];
}

+ (TargetConfig *)unstringifyImpl:(NSArray *)comps withConfigList:(NSArray *)configs {
    NSString *name = comps[1];
    TargetConfig *target = [[TargetConfig alloc] init];
    for (Config *config in configs) {
        if ([config.name isEqualToString:name]) {
            target.config = config;
            return target;
        }
    }
    NSLog(@"Warning: couldn't find matching config to restore from: %@", name);
    return nil;
}

- (void)trigger {
    [[(ApplicationController *)[[NSApplication sharedApplication] delegate] configsController] activateConfig:self.config];
}

@end
