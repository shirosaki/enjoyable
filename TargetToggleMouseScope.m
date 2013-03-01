//
//  TargetToggleMouseScope.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/28/12.
//

#import "TargetToggleMouseScope.h"

#import "ApplicationController.h"
#import "JoystickController.h"

@implementation TargetToggleMouseScope

+ (NSString *)serializationCode {
    return @"mtoggle";
}

- (NSDictionary *)serialize {
    return @{ @"type": @"mtoggle" };
}

+ (Target *)targetDeserialize:(NSDictionary *)serialization
                  withConfigs:(NSArray *)configs {
	TargetToggleMouseScope *target = [[TargetToggleMouseScope alloc] init];
	return target;
}
- (void)trigger {
    // FIXME: It's hacky to get at the controller this way, but it's
    // also hacky to pass it. Shouldn't need to do either.
    ApplicationController *ac = [NSApplication sharedApplication].delegate;
    JoystickController *jc = ac.jsController;
    [jc setFrontWindowOnly: ![jc frontWindowOnly]];
}

@end
