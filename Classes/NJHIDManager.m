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

static void _input(void *ctx, IOReturn inResult, void *inSender, IOHIDValueRef value) {
    NJHIDManager *self = (__bridge NJHIDManager *)ctx;
    [self.delegate HIDManager:self valueChanged:value];
}

static void _add(void *ctx, IOReturn inResult, void *inSender, IOHIDDeviceRef device) {
    NJHIDManager *self = (__bridge NJHIDManager *)ctx;
    [self.delegate HIDManager:self deviceAdded:device];
    IOHIDDeviceRegisterInputValueCallback(device, _input, ctx);
}

static void _remove(void *ctx, IOReturn inResult, void *inSender, IOHIDDeviceRef device) {
    NJHIDManager *self = (__bridge NJHIDManager *)ctx;
    [self.delegate HIDManager:self deviceRemoved:device];
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
        [self.delegate HIDManager:self didError:error];
        NSLog(@"Error starting HID manager: %@.", error);
    } else {
        _manager = manager;
        IOHIDManagerScheduleWithRunLoop(_manager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        IOHIDManagerRegisterDeviceMatchingCallback(_manager, _add, (__bridge void *)self);
        IOHIDManagerRegisterDeviceRemovalCallback(_manager, _remove, (__bridge void *)self);
        [self.delegate HIDManagerDidStart:self];
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
    [self.delegate HIDManagerDidStop:self];
    NSLog(@"Stopped HID manager.");
}

- (BOOL)running {
    return !!_manager;
}

- (void)setRunning:(BOOL)running {
    if (running)
        [self start];
    else
        [self stop];
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
