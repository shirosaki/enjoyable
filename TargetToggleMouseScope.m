//
//  TargetToggleMouseScope.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/28/12.
//

#import "TargetToggleMouseScope.h"

#import "ApplicationController.h"
#import "NJInputController.h"

@implementation TargetToggleMouseScope

+ (NSString *)serializationCode {
    return @"mtoggle";
}

- (NSDictionary *)serialize {
    return @{ @"type": @"mtoggle" };
}

+ (Target *)targetDeserialize:(NSDictionary *)serialization
                  withMappings:(NSArray *)mappings {
	TargetToggleMouseScope *target = [[TargetToggleMouseScope alloc] init];
	return target;
}
- (void)trigger {
    // FIXME: It's hacky to get at the controller this way, but it's
    // also hacky to pass it. Shouldn't need to do either.
    ApplicationController *ac = NSApplication.sharedApplication.delegate;
    NJInputController *jc = ac.inputController;
    jc.frontWindowOnly = !jc.frontWindowOnly;
}

@end
