//
//  TargetMouseBtn.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TargetMouseBtn.h"

@implementation TargetMouseBtn

@synthesize button;

+ (NSString *)serializationCode {
    return @"mbtn";
}

- (NSDictionary *)serialize {
    return @{ @"type": @"mbtn", @"button": @(self.button) };
}

+ (Target *)targetDeserialize:(NSDictionary *)serialization
                  withConfigs:(NSArray *)configs {
	TargetMouseBtn *target = [[TargetMouseBtn alloc] init];
    target.button = [serialization[@"button"] intValue];
	return target;
}

-(void) trigger {
    NSRect screenRect = [[NSScreen mainScreen] frame];
    NSInteger height = screenRect.size.height;
    NSPoint mouseLoc = [NSEvent mouseLocation];
    CGEventType eventType = (button == kCGMouseButtonLeft) ? kCGEventLeftMouseDown : kCGEventRightMouseDown;
    CGEventRef click = CGEventCreateMouseEvent(NULL,
                                               eventType,
                                               CGPointMake(mouseLoc.x, height - mouseLoc.y),
                                               button);
    CGEventPost(kCGHIDEventTap, click);
    CFRelease(click);
}

-(void) untrigger {
    NSRect screenRect = [[NSScreen mainScreen] frame];
    NSInteger height = screenRect.size.height;
    NSPoint mouseLoc = [NSEvent mouseLocation];
    CGEventType eventType = (button == kCGMouseButtonLeft) ? kCGEventLeftMouseUp : kCGEventRightMouseUp;
    CGEventRef click = CGEventCreateMouseEvent(NULL,
                                               eventType,
                                               CGPointMake(mouseLoc.x, height - mouseLoc.y),
                                               button);
    CGEventPost(kCGHIDEventTap, click);
    CFRelease(click);
}

@end
