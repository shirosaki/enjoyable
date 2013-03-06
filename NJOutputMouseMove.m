//
//  NJOutputMouseMove.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/26/12.
//

#import "NJOutputMouseMove.h"

#import "NJDeviceController.h"

@implementation NJOutputMouseMove

-(BOOL) isContinuous {
    return YES;
}

+ (NSString *)serializationCode {
    return @"mouse move";
}

- (NSDictionary *)serialize {
    return @{ @"type": self.class.serializationCode,
              @"axis": @(_axis),
              @"speed": @(_speed),
              };
}

+ (NJOutput *)outputDeserialize:(NSDictionary *)serialization
                  withMappings:(NSArray *)mappings {
	NJOutputMouseMove *output = [[NJOutputMouseMove alloc] init];
    output.axis = [serialization[@"axis"] intValue];
    output.speed = [serialization[@"speed"] floatValue];
    if (!output.speed)
        output.speed = 4;
	return output;
}

- (BOOL)update:(NJDeviceController *)jc {
    if (self.magnitude < 0.05)
        return NO; // dead zone
    
    CGFloat height = NSScreen.mainScreen.frame.size.height;
    
    float dx = 0.f, dy = 0.f;
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
    
    if (jc.frontWindowOnly) {
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
