//
//  NJOutputKeyPress.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "NJOutputKeyPress.h"

#import "NJKeyInputField.h"

@implementation NJOutputKeyPress

+ (NSString *)serializationCode {
    return @"key press";
}

- (NSDictionary *)serialize {
    return _vk != NJKeyInputFieldEmpty
        ? @{ @"type": self.class.serializationCode, @"key": @(_vk) }
        : nil;
}

+ (NJOutput *)outputDeserialize:(NSDictionary *)serialization
                  withMappings:(NSArray *)mappings {
    NJOutputKeyPress *output = [[NJOutputKeyPress alloc] init];
    output.vk = [serialization[@"key"] intValue];
    return output;
}

- (void)trigger {
    CGEventRef keyDown = CGEventCreateKeyboardEvent(NULL, _vk, YES);
    CGEventPost(kCGHIDEventTap, keyDown);
    CFRelease(keyDown);
}

- (void)untrigger {
    CGEventRef keyUp = CGEventCreateKeyboardEvent(NULL, _vk, NO);
    CGEventPost(kCGHIDEventTap, keyUp);
    CFRelease(keyUp);
}

@end
