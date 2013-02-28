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

@synthesize magnitude;

// TODO: Should just be NSCoding? Or like a dictionary?
+(Target*) unstringify: (NSString*) str withConfigList: (NSArray*) configs {
    NSArray* components = [str componentsSeparatedByString:@"~"];
    NSParameterAssert([components count]);
    NSString* typeTag = components[0];
    if([typeTag isEqualToString:@"key"])
        return [TargetKeyboard unstringifyImpl:components];
    if([typeTag isEqualToString:@"cfg"])
        return [TargetConfig unstringifyImpl:components withConfigList:configs];
    if([typeTag isEqualToString:@"mmove"])
        return [TargetMouseMove unstringifyImpl:components];
    if([typeTag isEqualToString:@"mbtn"])
        return [TargetMouseBtn unstringifyImpl:components];
    if([typeTag isEqualToString:@"mscroll"])
        return [TargetMouseScroll unstringifyImpl:components];
    if([typeTag isEqualToString:@"mtoggle"])
        return [TargetToggleMouseScope unstringifyImpl:components];
    
    NSParameterAssert(NO);
    return NULL;
}

- (NSString *)stringify {
    [self doesNotRecognizeSelector:_cmd];
    return NULL;
}

- (void)trigger {
}

- (void)untrigger {
}

- (BOOL)update:(JoystickController *)jc {
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
