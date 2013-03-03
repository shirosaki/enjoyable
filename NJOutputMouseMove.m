//
//  NJOutputMouseMove.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/26/12.
//

#import "NJOutputMouseMove.h"

#import "NJInputController.h"

@implementation NJOutputMouseMove {
    int sign;
}

-(BOOL) isContinuous {
    return YES;
}

+ (NSString *)serializationCode {
    return @"mouse move";
}

- (NSDictionary *)serialize {
    return @{ @"type": @"mouse move", @"axis": @(_axis) };
}

+ (NJOutput *)outputDeserialize:(NSDictionary *)serialization
                  withMappings:(NSArray *)mappings {
	NJOutputMouseMove *output = [[NJOutputMouseMove alloc] init];
    output.axis = [serialization[@"axis"] intValue];
	return output;
}

- (BOOL)update:(NJInputController *)jc {
    if (fabsf(self.magnitude) < 0.01) {
        sign = 0;
        return NO; // dead zone
    }

    // If the input crossed over High/Low, this output is done.
    if (!sign)
        sign = self.magnitude < 0 ? -1 : 1;
    else if (sign / self.magnitude < 0) {
        sign = 0;
        return NO;
    }
    
    CGFloat height = NSScreen.mainScreen.frame.size.height;
    
    // TODO
    float speed = 4.f;
    if (jc.frontWindowOnly)
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
