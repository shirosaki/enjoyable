//
//  NJHIDManager.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/13/13.
//
//

#import "NJHIDManager.h"

@implementation NJHIDManager {
    NSArray *_criteria;
    IOHIDManagerRef _manager;
}

- (id)initWithCriteria:(NSArray *)criteria
              delegate:(id <NJHIDManagerDelegate>)delegate
{
    if ((self = [super init])) {
        self.criteria = criteria;
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

static void input_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDValueRef value) {
    NJHIDManager *self = (__bridge NJHIDManager *)ctx;
    IOHIDDeviceRef device = IOHIDQueueGetDevice(inSender);
    [self.delegate hidManager:self valueChanged:value fromDevice:device];
}

static void add_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDDeviceRef device) {
    NJHIDManager *self = (__bridge NJHIDManager *)ctx;
    [self.delegate hidManager:self deviceAdded:device];
    IOHIDDeviceRegisterInputValueCallback(device, input_callback, ctx);
}

static void remove_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDDeviceRef device) {
    NJHIDManager *self = (__bridge NJHIDManager *)ctx;
    [self.delegate hidManager:self deviceRemoved:device];
}

- (void)start {
    if (self.running)
        return;
    IOHIDManagerRef manager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
    IOHIDManagerSetDeviceMatchingMultiple(manager, (__bridge CFArrayRef)self.criteria);
    IOReturn ret = IOHIDManagerOpen(manager, kIOHIDOptionsTypeNone);
    if (ret != kIOReturnSuccess) {
        NSError *error = [NSError errorWithDomain:NSMachErrorDomain code:ret userInfo:nil];
        IOHIDManagerClose(manager, kIOHIDOptionsTypeNone);
        CFRelease(manager);
        [self.delegate hidManager:self didError:error];
        NSLog(@"Error starting HID manager: %@.", error);
    } else {
        _manager = manager;
        IOHIDManagerScheduleWithRunLoop(_manager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        IOHIDManagerRegisterDeviceMatchingCallback(_manager, add_callback, (__bridge void *)self);
        IOHIDManagerRegisterDeviceRemovalCallback(_manager, remove_callback, (__bridge void *)self);
        [self.delegate hidManagerDidStart:self];
        NSLog(@"Started HID manager.");
    }
}

- (void)stop {
    if (!self.running)
        return;
    IOHIDManagerUnscheduleFromRunLoop(_manager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOHIDManagerClose(_manager, kIOHIDOptionsTypeNone);
    CFRelease(_manager);
    _manager = NULL;
    [self.delegate hidManagerDidStop:self];
    NSLog(@"Stopped HID manager.");
}

- (BOOL)running {
    return !!_manager;
}

- (NSArray *)criteria {
    return _criteria;
}

- (void)setCriteria:(NSArray *)criteria {
    if (!criteria)
        criteria = @[];
    if (![criteria isEqualToArray:_criteria]) {
        BOOL running = !!_manager;
        [self stop];
        _criteria = [criteria copy];
        if (running)
            [self start];
    }    
}

@end
