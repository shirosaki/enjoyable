//
//  NJOutput.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "NJOutput.h"

#import "NJOutputKeyPress.h"
#import "NJOutputMapping.h"
#import "NJOutputMouseMove.h"
#import "NJOutputMouseButton.h"
#import "NJOutputMouseScroll.h"
#import "NJOutputSwitchMouseMode.h"

@implementation NJOutput {
    BOOL running;
}

+ (NSString *)serializationCode {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSDictionary *)serialize {
    [self doesNotRecognizeSelector:_cmd];
    return nil;    
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:NJOutput.class]
        && [[self serialize] isEqual:[object serialize]];
}

- (NSUInteger)hash {
    return [[self serialize] hash];
}

+ (NJOutput *)outputDeserialize:(NSDictionary *)serialization
                  withMappings:(NSArray *)mappings {
    // Don't crash loading old/bad mappings (but don't load them either).
    if (![serialization isKindOfClass:NSDictionary.class])
        return nil;
    NSString *type = serialization[@"type"];
    for (Class cls in @[NJOutputKeyPress.class,
                        NJOutputMapping.class,
                        NJOutputMouseMove.class,
                        NJOutputMouseButton.class,
                        NJOutputMouseScroll.class,
                        NJOutputSwitchMouseMode.class
         ]) {
        if ([type isEqualToString:cls.serializationCode])
            return [cls outputDeserialize:serialization withMappings:mappings];
    }
    
    return nil;
}

- (void)trigger {
}

- (void)untrigger {
}

- (BOOL)update:(NJDeviceController *)jc {
    return NO;
}

- (BOOL)isContinuous {
    return NO;
}

- (BOOL)running {
    return running;
}

- (void)setRunning:(BOOL)newRunning {
    if (running != newRunning) {
        running = newRunning;
        if (running)
            [self trigger];
        else
            [self untrigger];
    }
}


@end
