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
    NSMutableArray *_joysticks;
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

- (void)expandRecursive:(id <NJActionPathElement>)pathElement {
    if (pathElement) {
        [self expandRecursive:pathElement.base];
        [outlineView expandItem:pathElement];
    }
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

- (void)runTargetForDevice:(IOHIDDeviceRef)device value:(IOHIDValueRef)value {
    Joystick *js = [self findJoystickByRef:device];
    JSAction *mainAction = [js actionForEvent:value];
    [mainAction notifyEvent:value];
    NSArray *children = mainAction.children ? mainAction.children : mainAction ? @[mainAction] : @[];
    for (JSAction *subaction in children) {
        Target *target = configsController.currentConfig[subaction];
        target.magnitude = mainAction.magnitude;
        target.running = subaction.active;
        if (target.running && target.isContinuous)
            [self addRunningTarget:target];
    }
}

- (void)showTargetForDevice:(IOHIDDeviceRef)device value:(IOHIDValueRef)value {
    Joystick *js = [self findJoystickByRef:device];
    JSAction *handler = [js handlerForEvent:value];
    if (!handler)
        return;
    
    [self expandRecursive:handler];
    [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:[outlineView rowForItem:handler]] byExtendingSelection: NO];
    [targetController focusKey];
}

static void input_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDValueRef value) {
    JoystickController *controller = (__bridge JoystickController *)ctx;
    IOHIDDeviceRef device = IOHIDQueueGetDevice(inSender);
    
    if (controller.sendingRealEvents) {
        [controller runTargetForDevice:device value:value];
    } else if ([NSApplication sharedApplication].mainWindow.isVisible) {
        [controller showTargetForDevice:device value:value];
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

- (void)addJoystickForDevice:(IOHIDDeviceRef)device {
    IOHIDDeviceRegisterInputValueCallback(device, input_callback, (__bridge void*)self);
    Joystick *js = [[Joystick alloc] initWithDevice:device];
    js.index = findAvailableIndex(_joysticks, js);
    [_joysticks addObject:js];
    [outlineView reloadData];
}

static void add_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDDeviceRef device) {
    JoystickController *controller = (__bridge JoystickController *)ctx;
    [controller addJoystickForDevice:device];
}

- (Joystick *)findJoystickByRef:(IOHIDDeviceRef)device {
    for (Joystick *js in _joysticks)
        if (js.device == device)
            return js;
    return nil;
}

static void remove_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDDeviceRef device) {
    JoystickController *controller = (__bridge JoystickController *)ctx;
    [controller removeJoystickForDevice:device];
}

- (void)removeJoystickForDevice:(IOHIDDeviceRef)device {
    Joystick *match = [self findJoystickByRef:device];
    IOHIDDeviceRegisterInputValueCallback(device, NULL, NULL);
    if (match) {
        [_joysticks removeObject:match];
        [outlineView reloadData];
    }
    
}

- (void)updateContinuousActions:(NSTimer *)timer {
    self.mouseLoc = [NSEvent mouseLocation];
    for (Target *target in [runningTargets copy]) {
        if (![target update:self]) {
            [runningTargets removeObject:target];
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
         beginSheetModalForWindow:outlineView.window
                    modalDelegate:nil
                   didEndSelector:nil
                      contextInfo:nil];
    }
    
    IOHIDManagerRegisterDeviceMatchingCallback(hidManager, add_callback, (__bridge void *)self);
    IOHIDManagerRegisterDeviceRemovalCallback(hidManager, remove_callback, (__bridge void *)self);
}

- (JSAction *)selectedAction {
    id <NJActionPathElement> item = [outlineView itemAtRow:outlineView.selectedRow];
    return (!item.children && item.base) ? item : nil;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id <NJActionPathElement>)item {
    return item ? item.children.count : _joysticks.count;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id <NJActionPathElement>)item {
    return item ? [[item children] count] > 0: YES;
}

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id <NJActionPathElement>)item {
    return item ? item.children[index] : _joysticks[index];
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(id <NJActionPathElement>)item  {
    return item ? item.name : @"root";
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    [targetController loadCurrent];
}

@end
