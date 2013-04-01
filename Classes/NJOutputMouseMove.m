//
//  NJOutputMouseMove.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/26/12.
//

#import "NJOutputMouseMove.h"

#import "NJInputController.h"

@implementation NJOutputMouseMove

+ (NSString *)serializationCode {
    return @"mouse move";
}

- (NSDictionary *)serialize {
    return @{ @"type": self.class.serializationCode,
              @"axis": @(_axis),
              @"speed": @(_speed),
              };
}

+ (NJOutput *)outputWithSerialization:(NSDictionary *)serialization {
    NJOutputMouseMove *output = [[NJOutputMouseMove alloc] init];
    output.axis = [serialization[@"axis"] intValue];
    output.speed = [serialization[@"speed"] floatValue];
    if (!output.speed)
        output.speed = 10;
    return output;
}

- (BOOL)isContinuous {
    return YES;
}

#define CLAMP(a, l, h) MIN(h, MAX(a, l))

- (BOOL)update:(NJInputController *)ic {
    if (self.magnitude < 0.05)
        return NO; // dead zone
    
    CGSize size = NSScreen.mainScreen.frame.size;
    
    CGFloat dx = 0, dy = 0;
    switch (_axis) {
        case 0:
            dx = -self.magnitude * _speed;
            break;
        case 1:
            dx = self.magnitude * _speed;
            break;
        case 2:
            dy = -self.magnitude * _speed;
            break;
        case 3:
            dy = self.magnitude * _speed;
            break;
    }
    NSPoint mouseLoc = ic.mouseLoc;
    mouseLoc.x = CLAMP(mouseLoc.x + dx, 0, size.width - 1);
    mouseLoc.y = CLAMP(mouseLoc.y - dy, 0, size.height - 1);
    ic.mouseLoc = mouseLoc;
    
    CGEventRef move = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved,
                                              CGPointMake(mouseLoc.x, size.height - mouseLoc.y),
                                              0);
    CGEventSetIntegerValueField(move, kCGMouseEventDeltaX, (int)dx);
    CGEventSetIntegerValueField(move, kCGMouseEventDeltaY, (int)dy);
    CGEventPost(kCGHIDEventTap, move);

    if (CGEventSourceButtonState(kCGEventSourceStateHIDSystemState, kCGMouseButtonLeft)) {
        CGEventSetType(move, kCGEventLeftMouseDragged);
        CGEventSetIntegerValueField(move, kCGMouseEventButtonNumber, kCGMouseButtonLeft);
        CGEventPost(kCGHIDEventTap, move);
    }
    if (CGEventSourceButtonState(kCGEventSourceStateHIDSystemState, kCGMouseButtonRight)) {
        CGEventSetType(move, kCGEventRightMouseDragged);
        CGEventSetIntegerValueField(move, kCGMouseEventButtonNumber, kCGMouseButtonRight);
        CGEventPost(kCGHIDEventTap, move);
    }
    if (CGEventSourceButtonState(kCGEventSourceStateHIDSystemState, kCGMouseButtonCenter)) {
        CGEventSetType(move, kCGEventOtherMouseDragged);
        CGEventSetIntegerValueField(move, kCGMouseEventButtonNumber, kCGMouseButtonCenter);
        CGEventPost(kCGHIDEventTap, move);
    }

    CFRelease(move);
    return YES;
}

@end
