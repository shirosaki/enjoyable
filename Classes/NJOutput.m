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

+ (NJOutput *)outputWithSerialization:(NSDictionary *)serialization {
    // Don't crash loading old/bad mappings (but don't load them either).
    if (![serialization isKindOfClass:NSDictionary.class])
        return nil;
    NSString *type = serialization[@"type"];
    for (Class cls in @[NJOutputKeyPress.class,
                        NJOutputMapping.class,
                        NJOutputMouseMove.class,
                        NJOutputMouseButton.class,
                        NJOutputMouseScroll.class
         ]) {
        if ([type isEqualToString:cls.serializationCode])
            return [cls outputWithSerialization:serialization];
    }
    
    return nil;
}

- (void)trigger {
}

- (void)untrigger {
}

- (BOOL)update:(NJInputController *)ic {
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

- (void)postLoadProcess:(id <NSFastEnumeration>)allMappings {
}

@end
