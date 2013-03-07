//
//  NJOutputMouseButton.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/27/12.
//

#import "NJOutputMouseButton.h"

@implementation NJOutputMouseButton

+ (NSString *)serializationCode {
    return @"mouse button";
}

- (NSDictionary *)serialize {
    return @{ @"type": self.class.serializationCode, @"button": @(_button) };
}

+ (NJOutput *)outputDeserialize:(NSDictionary *)serialization
                  withMappings:(NSArray *)mappings {
    NJOutputMouseButton *output = [[NJOutputMouseButton alloc] init];
    output.button = [serialization[@"button"] intValue];
    return output;
}

- (void)trigger {
    CGFloat height = NSScreen.mainScreen.frame.size.height;
    NSPoint mouseLoc = NSEvent.mouseLocation;
    CGEventType eventType = (_button == kCGMouseButtonLeft) ? kCGEventLeftMouseDown : kCGEventRightMouseDown;
    CGEventRef click = CGEventCreateMouseEvent(NULL,
                                               eventType,
                                               CGPointMake(mouseLoc.x, height - mouseLoc.y),
                                               _button);
    CGEventPost(kCGHIDEventTap, click);
    CFRelease(click);
}

- (void)untrigger {
    CGFloat height = NSScreen.mainScreen.frame.size.height;
    NSPoint mouseLoc = NSEvent.mouseLocation;
    CGEventType eventType = (_button == kCGMouseButtonLeft) ? kCGEventLeftMouseUp : kCGEventRightMouseUp;
    CGEventRef click = CGEventCreateMouseEvent(NULL,
                                               eventType,
                                               CGPointMake(mouseLoc.x, height - mouseLoc.y),
                                               _button);
    CGEventPost(kCGHIDEventTap, click);
    CFRelease(click);
}

@end
