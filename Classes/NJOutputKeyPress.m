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
    return _keyCode != NJKeyInputFieldEmpty
        ? @{ @"type": self.class.serializationCode, @"key": @(_keyCode) }
        : nil;
}

+ (NJOutput *)outputDeserialize:(NSDictionary *)serialization
                  withMappings:(NSArray *)mappings {
    NJOutputKeyPress *output = [[NJOutputKeyPress alloc] init];
    output.keyCode = [serialization[@"key"] intValue];
    return output;
}

- (void)trigger {
    if (_keyCode != NJKeyInputFieldEmpty) {
        CGEventRef keyDown = CGEventCreateKeyboardEvent(NULL, _keyCode, YES);
        CGEventPost(kCGHIDEventTap, keyDown);
        CFRelease(keyDown);
    }
}

- (void)untrigger {
    if (_keyCode != NJKeyInputFieldEmpty) {
        CGEventRef keyUp = CGEventCreateKeyboardEvent(NULL, _keyCode, NO);
        CGEventPost(kCGHIDEventTap, keyUp);
        CFRelease(keyUp);
    }
}

@end
