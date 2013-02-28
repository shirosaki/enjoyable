//
//  TargetKeyboard.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "TargetKeyboard.h"

#import "KeyInputTextView.h"

@implementation TargetKeyboard

@synthesize vk;

+ (NSString *)serializationCode {
    return @"key";
}

- (NSDictionary *)serialize {
    return @{ @"type": @"key", @"key": @(self.vk) };
}

+ (Target *)targetDeserialize:(NSDictionary *)serialization
                  withConfigs:(NSArray *)configs {
	TargetKeyboard *target = [[TargetKeyboard alloc] init];
    target.vk = [serialization[@"key"] intValue];
	return target;
}

-(void) trigger {
	CGEventRef keyDown = CGEventCreateKeyboardEvent(NULL, vk, YES);
	CGEventPost(kCGHIDEventTap, keyDown);
	CFRelease(keyDown);
}

-(void) untrigger {
	CGEventRef keyUp = CGEventCreateKeyboardEvent(NULL, vk, NO);
	CGEventPost(kCGHIDEventTap, keyUp);
	CFRelease(keyUp);
}

- (NSString *)descr {
    return [KeyInputTextView stringForKeyCode:self.vk];
}

@end
