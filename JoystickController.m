//
//  JoystickController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "JoystickController.h"

#import "Config.h"
#import "ConfigsController.h"
#import "Joystick.h"
#import "JSAction.h"
#import "Target.h"
#import "TargetController.h"

@implementation JoystickController {
    IOHIDManagerRef hidManager;
    NSTimer *continuousTimer;
    NSMutableArray *runningTargets;
}

- (id)init {
    if ((self = [super init])) {
        _joysticks = [[NSMutableArray alloc] initWithCapacity:16];
        runningTargets = [[NSMutableArray alloc] initWithCapacity:32];
    }
    return self;
}

- (void)dealloc {
    [continuousTimer invalidate];
    IOHIDManagerClose(hidManager, kIOHIDOptionsTypeNone);
    CFRelease(hidManager);
}

- (void)expandRecursive:(id)handler {
    if ([handler base])
        [self expandRecursive:[handler base]];
    [outlineView expandItem:handler];
}

- (void)addRunningTarget:(Target *)target {
    if (![runningTargets containsObject:target]) {
        [runningTargets addObject:target];
    }
    if (!continuousTimer) {
        continuousTimer = [NSTimer scheduledTimerWithTimeInterval:1.f/60.f
                                                           target:self
                                                         selector:@selector(updateContinuousActions:)
                                                         userInfo:nil
                                                          repeats:YES];
        NSLog(@"Scheduled continuous target timer.");
    }
}

static void input_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDValueRef value) {
    JoystickController *controller = (__bridge JoystickController *)ctx;
    IOHIDDeviceRef device = IOHIDQueueGetDevice(inSender);
    
    Joystick *js = [controller findJoystickByRef:device];
    if (controller.sendingRealEvents) {
        JSAction *mainAction = [js actionForEvent:value];
        [mainAction notifyEvent:value];
        NSArray *children = mainAction.children ? mainAction.children : mainAction ? @[mainAction] : @[];
        for (JSAction *subaction in children) {
            Target *target = controller.currentConfig[subaction];
            target.magnitude = mainAction.magnitude;
            target.running = subaction.active;
            if (target.running && target.isContinuous)
                [controller addRunningTarget:target];
        }
    } else if ([NSApplication sharedApplication].isActive
               && [NSApplication sharedApplication].mainWindow.isVisible) {
        JSAction *handler = [js handlerForEvent:value];
        if (!handler)
            return;
        
        [controller expandRecursive:handler];
        [controller->outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:[controller->outlineView rowForItem:handler]] byExtendingSelection: NO];
        [controller->targetController focusKey];
    }
}

static int findAvailableIndex(NSArray *list, Joystick *js) {
    for (int index = 1; ; index++) {
        BOOL available = YES;
        for (Joystick *used in list) {
            if ([used.productName isEqualToString:js.productName] && used.index == index) {
                available = NO;
                break;
            }
        }
        if (available)
            return index;
    }
}

static void add_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDDeviceRef device) {
    JoystickController *controller = (__bridge JoystickController *)ctx;
    IOHIDDeviceRegisterInputValueCallback(device, input_callback, (__bridge void*)controller);
    Joystick *js = [[Joystick alloc] initWithDevice:device];
    js.index = findAvailableIndex(controller.joysticks, js);
    [[controller joysticks] addObject:js];
    [controller->outlineView reloadData];
}

- (Joystick *)findJoystickByRef:(IOHIDDeviceRef)device {
    for (Joystick *js in _joysticks)
        if (js.device == device)
            return js;
    return nil;
}

static void remove_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDDeviceRef device) {
    JoystickController *controller = (__bridge JoystickController *)ctx;
    Joystick *match = [controller findJoystickByRef:device];
    IOHIDDeviceRegisterInputValueCallback(device, NULL, NULL);
    if (match) {
        [controller.joysticks removeObject:match];
        [controller->outlineView reloadData];
    }
}

- (void)updateContinuousActions:(NSTimer *)timer {
    self.mouseLoc = [NSEvent mouseLocation];
    for (Target *target in [runningTargets copy]) {
        if (![target update:self]) {
            [runningTargets removeObject:target];
            NSLog(@"Removing action, now running %lu.", runningTargets.count);
        }
    }
    if (!runningTargets.count) {
        [continuousTimer invalidate];
        continuousTimer = nil;
        NSLog(@"Unscheduled continuous target timer.");
    }
}

#define NSSTR(e) ((NSString *)CFSTR(e))

- (void)setup {
    hidManager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
    NSArray *criteria = @[ @{ NSSTR(kIOHIDDeviceUsagePageKey) : @(kHIDPage_GenericDesktop),
                              NSSTR(kIOHIDDeviceUsageKey) : @(kHIDUsage_GD_Joystick) },
                           @{ NSSTR(kIOHIDDeviceUsagePageKey) : @(kHIDPage_GenericDesktop),
                              NSSTR(kIOHIDDeviceUsageKey) : @(kHIDUsage_GD_GamePad) },
                           @{ NSSTR(kIOHIDDeviceUsagePageKey) : @(kHIDPage_GenericDesktop),
                              NSSTR(kIOHIDDeviceUsageKey) : @(kHIDUsage_GD_MultiAxisController) }
                           ];
    IOHIDManagerSetDeviceMatchingMultiple(hidManager, (__bridge CFArrayRef)criteria);
    
    IOHIDManagerScheduleWithRunLoop(hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOReturn ret = IOHIDManagerOpen(hidManager, kIOHIDOptionsTypeNone);
    if (ret != kIOReturnSuccess) {
        [[NSAlert alertWithMessageText:@"Input devices are unavailable"
                         defaultButton:nil
                       alternateButton:nil
                           otherButton:nil
             informativeTextWithFormat:@"Error 0x%08x occured trying to access your devices. "
                                       @"Input may not be correctly detected or mapped.",
                                       ret]
         runModal];
    }
    
    IOHIDManagerRegisterDeviceMatchingCallback(hidManager, add_callback, (__bridge void *)self);
    IOHIDManagerRegisterDeviceRemovalCallback(hidManager, remove_callback, (__bridge void *)self);
}

- (Config *)currentConfig {
    return configsController.currentConfig;
}

- (JSAction *)selectedAction {
    id item = [outlineView itemAtRow:outlineView.selectedRow];
    return [item children] ? nil : item;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return item ? [[item children] count] : _joysticks.count;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return item ? [[item children] count] > 0: YES;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
    return item ? [item children][index] : _joysticks[index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item  {
    if(item == nil)
        return @"root";
    return [item name];
}

- (void)outlineViewSelectionDidChange: (NSNotification*) notification {
    [targetController reset];
    [targetController load];
}

@end
