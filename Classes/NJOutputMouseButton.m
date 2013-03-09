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
}

+ (NSTimeInterval)doubleClickInterval {
    static NSTimeInterval s_doubleClickThreshold;
    if (!s_doubleClickThreshold) {
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

    NSLog(@"%@\n%@", upTime, [NSDate date]);
    if (clickCount >= 3 || [upTime compare:[NSDate date]] == NSOrderedAscending)
        clickCount = 1;
    else
        ++clickCount;
    CGEventSetIntegerValueField(click, kCGMouseEventClickState, clickCount);
    
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
    CGEventSetIntegerValueField(click, kCGMouseEventClickState, clickCount);
    CGEventPost(kCGHIDEventTap, click);
    CFRelease(click);
    upTime = [NJOutputMouseButton dateWithClickInterval];
}

@end
