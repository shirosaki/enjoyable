//
//  NJDevice.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "NJDevice.h"

#import "NJInput.h"
#import "NJInputAnalog.h"
#import "NJInputHat.h"
#import "NJInputButton.h"

static NSArray *InputsForElement(IOHIDDeviceRef device, id parent) {
    CFArrayRef elements = IOHIDDeviceCopyMatchingElements(device, NULL, kIOHIDOptionsTypeNone);
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:CFArrayGetCount(elements)];
    
    int buttons = 0;
    int axes = 0;
    int hats = 0;
    
    for (CFIndex i = 0; i < CFArrayGetCount(elements); i++) {
        IOHIDElementRef element = (IOHIDElementRef)CFArrayGetValueAtIndex(elements, i);
        IOHIDElementType type = IOHIDElementGetType(element);
        uint32_t usage = IOHIDElementGetUsage(element);
        uint32_t usagePage = IOHIDElementGetUsagePage(element);
        CFIndex max = IOHIDElementGetPhysicalMax(element);
        CFIndex min = IOHIDElementGetPhysicalMin(element);
        
        NJInput *input = nil;
        
        if (!(type == kIOHIDElementTypeInput_Misc
              || type == kIOHIDElementTypeInput_Axis
              || type == kIOHIDElementTypeInput_Button))
             continue;
        
        if (max - min == 1
            || usagePage == kHIDPage_Button
            || type == kIOHIDElementTypeInput_Button) {
            input = [[NJInputButton alloc] initWithElement:element
                                                     index:++buttons
                                                    parent:parent];
        } else if (usage == kHIDUsage_GD_Hatswitch) {
            input = [[NJInputHat alloc] initWithElement:element
                                                  index:++hats
                                                 parent:parent];
        } else if (usage >= kHIDUsage_GD_X && usage <= kHIDUsage_GD_Rz) {
            input = [[NJInputAnalog alloc] initWithElement:element
                                                     index:++axes
                                                    parent:parent];
        } else {
            continue;
        }
        
        [children addObject:input];
    }

    CFRelease(elements);
    return children;
}

@implementation NJDevice {
    int _vendorId;
    int _productId;
}

- (id)initWithDevice:(IOHIDDeviceRef)dev {
    NSString *name = (__bridge NSString *)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDProductKey));
    if ((self = [super initWithName:name eid:nil parent:nil])) {
        self.device = dev;
        _vendorId = [(__bridge NSNumber *)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDVendorIDKey)) intValue];
        _productId = [(__bridge NSNumber *)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDProductIDKey)) intValue];
        self.children = InputsForElement(dev, self);
        self.index = 1;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:NJDevice.class]
        && [[(NJDevice *)object name] isEqualToString:self.name];
}

- (NSString *)name {
    return [NSString stringWithFormat:@"%@ #%d", super.name, _index];
}

- (NSString *)uid {
    return [NSString stringWithFormat:@"%d:%d:%d", _vendorId, _productId, _index];
}

- (NJInput *)findInputByCookie:(IOHIDElementCookie)cookie {
    for (NJInput *child in self.children)
        if (child.cookie == cookie)
            return child;
    return nil;
}

- (NJInput *)handlerForEvent:(IOHIDValueRef)value {
    NJInput *mainInput = [self inputForEvent:value];
    return [mainInput findSubInputForValue:value];
}

- (NJInput *)inputForEvent:(IOHIDValueRef)value {
    IOHIDElementRef elt = IOHIDValueGetElement(value);
    IOHIDElementCookie cookie = IOHIDElementGetCookie(elt);
    return [self findInputByCookie:cookie];
}

@end
