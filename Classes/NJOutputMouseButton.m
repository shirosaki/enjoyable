//
//  NJOutputMouseButton.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/27/12.
//

#import "NJOutputMouseButton.h"

@implementation NJOutputMouseButton {
    NSDate *upTime;
    int clickCount;
    NSPoint clickPosition;
}

+ (NSTimeInterval)doubleClickInterval {
    static NSTimeInterval s_doubleClickThreshold;
    if (s_doubleClickThreshold == 0) {
        s_doubleClickThreshold = [[NSUserDefaults.standardUserDefaults
                                 objectForKey:@"com.apple.mouse.doubleClickThreshold"] floatValue];
        if (s_doubleClickThreshold <= 0)
            s_doubleClickThreshold = 1.0;
    }
    return s_doubleClickThreshold;
}

+ (NSDate *)dateWithClickInterval {
    return [[NSDate alloc] initWithTimeIntervalSinceNow:self.doubleClickInterval];
}

+ (NSString *)serializationCode {
    return @"mouse button";
}

- (NSDictionary *)serialize {
    return @{ @"type": self.class.serializationCode, @"button": @(_button) };
}

+ (NJOutput *)outputWithSerialization:(NSDictionary *)serialization {
    NJOutputMouseButton *output = [[NJOutputMouseButton alloc] init];
    output.button = [serialization[@"button"] intValue];
    return output;
}

- (void)trigger {
    CGFloat height = ((NSScreen*)NSScreen.screens[0]).frame.size.height;
    NSPoint mouseLoc = NSEvent.mouseLocation;
    CGEventType eventType = _button == kCGMouseButtonLeft ? kCGEventLeftMouseDown
                          : _button == kCGMouseButtonRight ? kCGEventRightMouseDown
                          : kCGEventOtherMouseDown;
    CGEventRef click = CGEventCreateMouseEvent(NULL,
                                               eventType,
                                               CGPointMake(mouseLoc.x, height - mouseLoc.y),
                                               _button);

    if (clickCount >= 3 || [upTime compare:[NSDate date]] == NSOrderedAscending
        || !CGPointEqualToPoint(mouseLoc, clickPosition))
        clickCount = 1;
    else
        ++clickCount;
    CGEventSetIntegerValueField(click, kCGMouseEventClickState, clickCount);
    CGEventPost(kCGHIDEventTap, click);
    CFRelease(click);
    clickPosition = mouseLoc;
}

- (void)untrigger {
    upTime = [NJOutputMouseButton dateWithClickInterval];
    NSPoint mouseLoc = NSEvent.mouseLocation;
    CGFloat height = ((NSScreen*)NSScreen.screens[0]).frame.size.height;
    CGEventType eventType = _button == kCGMouseButtonLeft ? kCGEventLeftMouseUp
                          : _button == kCGMouseButtonRight ? kCGEventRightMouseUp
                          : kCGEventOtherMouseUp;
    CGEventRef click = CGEventCreateMouseEvent(NULL,
                                               eventType,
                                               CGPointMake(mouseLoc.x, height - mouseLoc.y),
                                               _button);
    CGEventSetIntegerValueField(click, kCGMouseEventClickState, clickCount);
    CGEventPost(kCGHIDEventTap, click);
    CFRelease(click);
}

@end
