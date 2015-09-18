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
    if (output.speed == 0)
        output.speed = 10;
    return output;
}

- (BOOL)isContinuous {
    return YES;
}

static CGFloat pointRectSquaredDistance(NSPoint p, NSRect r) {
    CGFloat dx = p.x - MAX(MIN(p.x, r.origin.x + r.size.width), r.origin.x);
    CGFloat dy = p.y - MAX(MIN(p.y, r.origin.y + r.size.height), r.origin.y);
    return dx * dx + dy * dy;
}

#define CLAMP(a, l, h) MIN(h, MAX(a, l))

- (BOOL)update:(NJInputController *)ic {
    if (self.magnitude < 0.05)
        return NO; // dead zone
    
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
    mouseLoc.x = mouseLoc.x + dx;
    mouseLoc.y = mouseLoc.y - dy;
    bool inScreen = false;
    for (NSScreen *screen in NSScreen.screens) {
        if (NSMouseInRect(mouseLoc, screen.frame, NO)) {
            inScreen = true;
            break;
        }
    }
    if (!inScreen) {
        NSScreen *nearestScreen;
        if (NSScreen.screens.count == 0) {
            nearestScreen = NSScreen.screens[0];
        } else {
            CGFloat minDistance = 0;
            for (NSScreen *screen in NSScreen.screens) {
                CGFloat d = pointRectSquaredDistance(mouseLoc, screen.frame);
                if (minDistance == 0 || d < minDistance) {
                    minDistance = d;
                    nearestScreen = screen;
                }
            }
        }
        NSRect frame = nearestScreen.frame;
        mouseLoc.x = CLAMP(mouseLoc.x, NSMinX(frame), NSMaxX(frame) - 1);
        mouseLoc.y = CLAMP(mouseLoc.y, NSMinY(frame) + 1, NSMaxY(frame));
    }
    ic.mouseLoc = mouseLoc;
    
    CGFloat height = ((NSScreen*)NSScreen.screens[0]).frame.size.height;
    CGEventRef move = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved,
                                              CGPointMake(mouseLoc.x, height - mouseLoc.y),
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
