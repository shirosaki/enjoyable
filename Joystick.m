//
//  Joystick.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

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
        
        JSAction *action = NULL;
        
        if(!(type == kIOHIDElementTypeInput_Misc
             || type == kIOHIDElementTypeInput_Axis
             || type == kIOHIDElementTypeInput_Button))
            continue;
        
        if (max - min == 1 || usagePage == kHIDPage_Button || type == kIOHIDElementTypeInput_Button) {
            action = [[JSActionButton alloc] initWithIndex:buttons++ andName:(__bridge NSString *)elName];
            [(JSActionButton*)action setMax:max];
        } else if (usage == kHIDUsage_GD_Hatswitch) {
            action = [[JSActionHat alloc] init];
        } else {
            if (usage >= kHIDUsage_GD_X && usage <= kHIDUsage_GD_Rz) {
                action = [[JSActionAnalog alloc] initWithIndex: axes++];
                [(JSActionAnalog*)action setOffset:(double)-1.0];
                [(JSActionAnalog*)action setScale:(double)2.0/(max - min)];
            } else
                continue;
        }
        
        [action setBase:base];
        [action setUsage:usage];
        [action setCookie:IOHIDElementGetCookie(element)];
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
    return [NSString stringWithFormat:@"%@ #%d", productName, index + 1];
}

- (id)base {
    // FIXME(jfw): This is a hack because actions get joysticks as their base.
    return nil;
}

- (NSString *)stringify {
    return [[NSString alloc] initWithFormat: @"%d~%d~%d", vendorId, productId, index];
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
