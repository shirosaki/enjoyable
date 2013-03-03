//
//  Target.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "Target.h"

#import "TargetKeyboard.h"
#import "TargetConfig.h"
#import "TargetMouseMove.h"
#import "TargetMouseBtn.h"
#import "TargetMouseScroll.h"
#import "TargetToggleMouseScope.h"

@implementation Target {
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
    return [object isKindOfClass:Target.class]
        && [[self serialize] isEqual:[object serialize]];
}

- (NSUInteger)hash {
    return [[self serialize] hash];
}

+ (Target *)targetDeserialize:(NSDictionary *)serialization
                  withMappings:(NSArray *)mappings {
    // Don't crash loading old/bad mappings (but don't load them either).
    if (![serialization isKindOfClass:NSDictionary.class])
        return nil;
    NSString *type = serialization[@"type"];
    for (Class cls in @[TargetKeyboard.class,
                        TargetConfig.class,
                        TargetMouseMove.class,
                        TargetMouseBtn.class,
                        TargetMouseScroll.class,
                        TargetToggleMouseScope.class
         ]) {
        if ([type isEqualToString:cls.serializationCode])
            return [cls targetDeserialize:serialization withMappings:mappings];
    }
    
    return nil;
}

- (void)trigger {
}

- (void)untrigger {
}

- (BOOL)update:(NJInputController *)jc {
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
