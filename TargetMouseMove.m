//
//  TargetMouseMove.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/26/12.
//

#import "TargetMouseMove.h"

#import "JoystickController.h"

@implementation TargetMouseMove {
    int sign;
}

-(BOOL) isContinuous {
    return YES;
}

+ (NSString *)serializationCode {
    return @"mmove";
}

- (NSDictionary *)serialize {
    return @{ @"type": @"mmove", @"axis": @(_axis) };
}

+ (Target *)targetDeserialize:(NSDictionary *)serialization
                  withConfigs:(NSArray *)configs {
	TargetMouseMove *target = [[TargetMouseMove alloc] init];
    target.axis = [serialization[@"axis"] intValue];
	return target;
}

- (BOOL)update:(JoystickController *)jc {
    if (fabsf(self.magnitude) < 0.01) {
        sign = 0;
        return NO; // dead zone
    }

    // If the action crossed over High/Low, this target is done.
    if (!sign)
        sign = self.magnitude < 0 ? -1 : 1;
    else if (sign / self.magnitude < 0) {
        sign = 0;
        return NO;
    }
    
    NSRect screenRect = [[NSScreen mainScreen] frame];
    CGFloat height = screenRect.size.height;
    
    // TODO
    float speed = 4.f;
    if ([jc frontWindowOnly])
        speed = 12.f;
    float dx = 0.f, dy = 0.f;
    if (_axis == 0)
        dx = self.magnitude * speed;
    else
        dy = self.magnitude * speed;
    NSPoint mouseLoc = jc.mouseLoc;
    mouseLoc.x += dx;
    mouseLoc.y -= dy;
    jc.mouseLoc = mouseLoc;
    
    CGEventRef move = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved,
                                              CGPointMake(mouseLoc.x, height - mouseLoc.y),
                                              0);
    CGEventSetType(move, kCGEventMouseMoved);
    CGEventSetIntegerValueField(move, kCGMouseEventDeltaX, (int)dx);
    CGEventSetIntegerValueField(move, kCGMouseEventDeltaY, (int)dy);
    
    if ([jc frontWindowOnly]) {
        ProcessSerialNumber psn;
        GetFrontProcess(&psn);
        CGEventPostToPSN(&psn, move);
    }
    else {
        CGEventPost(kCGHIDEventTap, move);
    }
    
    CFRelease(move);
    return YES;
}

@end
