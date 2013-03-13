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

static NSArray *InputsForElement(IOHIDDeviceRef device, id base) {
    CFArrayRef elements = IOHIDDeviceCopyMatchingElements(device, NULL, kIOHIDOptionsTypeNone);
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:CFArrayGetCount(elements)];
    
    int buttons = 0;
    int axes = 0;
    int hats = 0;
    
    for (int i = 0; i < CFArrayGetCount(elements); i++) {
        IOHIDElementRef element = (IOHIDElementRef)CFArrayGetValueAtIndex(elements, i);
        int type = IOHIDElementGetType(element);
        unsigned usage = IOHIDElementGetUsage(element);
        unsigned usagePage = IOHIDElementGetUsagePage(element);
        long max = IOHIDElementGetPhysicalMax(element);
        long min = IOHIDElementGetPhysicalMin(element);
        CFStringRef elName = IOHIDElementGetName(element);
        
        NJInput *input = nil;
        
        if (!(type == kIOHIDElementTypeInput_Misc
              || type == kIOHIDElementTypeInput_Axis
              || type == kIOHIDElementTypeInput_Button))
             continue;
        
        if (max - min == 1 || usagePage == kHIDPage_Button || type == kIOHIDElementTypeInput_Button) {
            input = [[NJInputButton alloc] initWithName:(__bridge NSString *)elName
                                                    idx:++buttons
                                                    max:max];
        } else if (usage == kHIDUsage_GD_Hatswitch) {
            input = [[NJInputHat alloc] initWithIndex:++hats];
        } else if (usage >= kHIDUsage_GD_X && usage <= kHIDUsage_GD_Rz) {
            input = [[NJInputAnalog alloc] initWithIndex:++axes
                                                  rawMin:min
                                                  rawMax:max];
        } else {
            continue;
        }
        
        // TODO(jfw): Should be moved into better constructors.
        input.base = base;
        input.cookie = IOHIDElementGetCookie(element);
        [children addObject:input];
    }

    CFRelease(elements);
    return children;
}

@implementation NJDevice {
    int vendorId;
    int productId;
}

- (id)initWithDevice:(IOHIDDeviceRef)dev {
    if ((self = [super initWithName:nil did:nil base:nil])) {
        self.device = dev;
        self.productName = (__bridge NSString *)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDProductKey));
        vendorId = [(__bridge NSNumber *)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDVendorIDKey)) intValue];
        productId = [(__bridge NSNumber *)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDProductIDKey)) intValue];
        self.children = InputsForElement(dev, self);
    }
    return self;
}

- (NSString *)name {
    return [NSString stringWithFormat:@"%@ #%d", _productName, _index];
}

- (id)base {
    return nil;
}

- (NSString *)uid {
    return [NSString stringWithFormat: @"%d:%d:%d", vendorId, productId, _index];
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
