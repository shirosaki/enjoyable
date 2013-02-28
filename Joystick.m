//
//  Joystick.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "Joystick.h"

static NSArray *ActionsForElement(IOHIDDeviceRef device, id base) {
    CFArrayRef elements = IOHIDDeviceCopyMatchingElements(device, NULL, kIOHIDOptionsTypeNone);
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:CFArrayGetCount(elements)];
    
    int buttons = 0;
    int axes = 0;
    
    for (int i = 0; i < CFArrayGetCount(elements); i++) {
        IOHIDElementRef element = (IOHIDElementRef)CFArrayGetValueAtIndex(elements, i);
        int type = IOHIDElementGetType(element);
        int usage = IOHIDElementGetUsage(element);
        int usagePage = IOHIDElementGetUsagePage(element);
        int max = IOHIDElementGetPhysicalMax(element);
        int min = IOHIDElementGetPhysicalMin(element);
        CFStringRef elName = IOHIDElementGetName(element);
        
        JSAction *action = nil;
        
        if (!(type == kIOHIDElementTypeInput_Misc
              || type == kIOHIDElementTypeInput_Axis
              || type == kIOHIDElementTypeInput_Button))
             continue;
        
        if (max - min == 1 || usagePage == kHIDPage_Button || type == kIOHIDElementTypeInput_Button) {
            action = [[JSActionButton alloc] initWithName:(__bridge NSString *)elName
                                                      idx:++buttons
                                                      max:max];
        } else if (usage == kHIDUsage_GD_Hatswitch) {
            action = [[JSActionHat alloc] init];
        } else if (usage >= kHIDUsage_GD_X && usage <= kHIDUsage_GD_Rz) {
            // TODO(jfw): Scaling equation doesn't seem right if min != 0.
            action = [[JSActionAnalog alloc] initWithIndex:++axes
                                                    offset:-1.f
                                                     scale:2.f / (max - min)];
        } else {
            continue;
        }
        
        // TODO(jfw): Should be moved into better constructors.
        action.base = base;
        action.cookie = IOHIDElementGetCookie(element);
        [children addObject:action];
    }
    return children;
}

@implementation Joystick

@synthesize vendorId;
@synthesize productId;
@synthesize productName;
@synthesize index;
@synthesize device;
@synthesize children;

- (id)initWithDevice:(IOHIDDeviceRef)dev {
    if ((self = [super init])) {
        self.device = dev;
        self.productName = (__bridge NSString *)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDProductKey));
        self.vendorId = [(__bridge NSNumber *)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDVendorIDKey)) intValue];
        self.productId = [(__bridge NSNumber *)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDProductIDKey)) intValue];
        self.children = ActionsForElement(dev, self);
    }
    return self;
}

- (NSString *)name {
    return [NSString stringWithFormat:@"%@ #%d", productName, index];
}

- (id)base {
    return nil;
}

- (NSString *)uid {
    return [NSString stringWithFormat: @"%d:%d:%d", vendorId, productId, index];
}

- (JSAction *)findActionByCookie:(void *)cookie {
    for (JSAction *child in children)
        if (child.cookie == cookie)
            return child;
    return nil;
}

- (id)handlerForEvent:(IOHIDValueRef) value {
    JSAction *mainAction = [self actionForEvent:value];
    return [mainAction findSubActionForValue:value];
}

- (JSAction *)actionForEvent:(IOHIDValueRef)value {
    IOHIDElementRef elt = IOHIDValueGetElement(value);
    void *cookie = IOHIDElementGetCookie(elt);
    return [self findActionByCookie:cookie];
}

@end
