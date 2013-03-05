//
//  NJOutputSwitchMouseMode.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/28/12.
//

#import "NJOutputSwitchMouseMode.h"

#import "EnjoyableApplicationDelegate.h"
#import "NJDeviceController.h"

@implementation NJOutputSwitchMouseMode

+ (NSString *)serializationCode {
    return @"switch mouse mode";
}

- (NSDictionary *)serialize {
    return @{ @"type": self.class.serializationCode };
}

+ (NJOutput *)outputDeserialize:(NSDictionary *)serialization
                  withMappings:(NSArray *)mappings {
    return [[NJOutputSwitchMouseMode alloc] init];
}
- (void)trigger {
    // FIXME: It's hacky to get at the controller this way, but it's
    // also hacky to pass it. Shouldn't need to do either.
    EnjoyableApplicationDelegate *ac = NSApplication.sharedApplication.delegate;
    NJDeviceController *jc = ac.inputController;
    jc.frontWindowOnly = !jc.frontWindowOnly;
}

@end
