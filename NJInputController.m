//
//  NJInputController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "NJInputController.h"

#import "Config.h"
#import "ConfigsController.h"
#import "NJDevice.h"
#import "NJInput.h"
#import "Target.h"
#import "TargetController.h"
#import "NJEvents.h"

@implementation NJInputController {
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

- (void)expandRecursive:(id <NJInputPathElement>)pathElement {
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
                                                         selector:@selector(updateContinuousInputs:)
                                                         userInfo:nil
                                                          repeats:YES];
        NSLog(@"Scheduled continuous target timer.");
    }
}

- (void)runTargetForDevice:(IOHIDDeviceRef)device value:(IOHIDValueRef)value {
    NJDevice *js = [self findJoystickByRef:device];
    NJInput *mainInput = [js inputForEvent:value];
    [mainInput notifyEvent:value];
    NSArray *children = mainInput.children ? mainInput.children : mainInput ? @[mainInput] : @[];
    for (NJInput *subInput in children) {
        Target *target = configsController.currentConfig[subInput];
        target.magnitude = mainInput.magnitude;
        target.running = subInput.active;
        if (target.running && target.isContinuous)
            [self addRunningTarget:target];
    }
}

- (void)showTargetForDevice:(IOHIDDeviceRef)device value:(IOHIDValueRef)value {
    NJDevice *js = [self findJoystickByRef:device];
    NJInput *handler = [js handlerForEvent:value];
    if (!handler)
        return;
    
    [self expandRecursive:handler];
    [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:[outlineView rowForItem:handler]] byExtendingSelection: NO];
    [targetController focusKey];
}

static void input_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDValueRef value) {
    NJInputController *controller = (__bridge NJInputController *)ctx;
    IOHIDDeviceRef device = IOHIDQueueGetDevice(inSender);
    
    if (controller.translatingEvents) {
        [controller runTargetForDevice:device value:value];
    } else if ([NSApplication sharedApplication].mainWindow.isVisible) {
        [controller showTargetForDevice:device value:value];
    }
}

static int findAvailableIndex(NSArray *list, NJDevice *js) {
    for (int index = 1; ; index++) {
        BOOL available = YES;
        for (NJDevice *used in list) {
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
    NJDevice *js = [[NJDevice alloc] initWithDevice:device];
    js.index = findAvailableIndex(_joysticks, js);
    [_joysticks addObject:js];
    [outlineView reloadData];
}

static void add_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDDeviceRef device) {
    NJInputController *controller = (__bridge NJInputController *)ctx;
    [controller addJoystickForDevice:device];
}

- (NJDevice *)findJoystickByRef:(IOHIDDeviceRef)device {
    for (NJDevice *js in _joysticks)
        if (js.device == device)
            return js;
    return nil;
}

static void remove_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDDeviceRef device) {
    NJInputController *controller = (__bridge NJInputController *)ctx;
    [controller removeJoystickForDevice:device];
}

- (void)removeJoystickForDevice:(IOHIDDeviceRef)device {
    NJDevice *match = [self findJoystickByRef:device];
    IOHIDDeviceRegisterInputValueCallback(device, NULL, NULL);
    if (match) {
        [_joysticks removeObject:match];
        [outlineView reloadData];
    }
    
}

- (void)updateContinuousInputs:(NSTimer *)timer {
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

- (NJInput *)selectedInput {
    id <NJInputPathElement> item = [outlineView itemAtRow:outlineView.selectedRow];
    return (!item.children && item.base) ? item : nil;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id <NJInputPathElement>)item {
    return item ? item.children.count : _joysticks.count;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id <NJInputPathElement>)item {
    return item ? [[item children] count] > 0: YES;
}

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id <NJInputPathElement>)item {
    return item ? item.children[index] : _joysticks[index];
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(id <NJInputPathElement>)item  {
    return item ? item.name : @"root";
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    
    [targetController loadCurrent];
}

- (void)setTranslatingEvents:(BOOL)translatingEvents {
    if (translatingEvents != _translatingEvents) {
        _translatingEvents = translatingEvents;
        NSString *name = translatingEvents
            ? NJEventTranslationActivated
            : NJEventTranslationDeactivated;
        [NSNotificationCenter.defaultCenter postNotificationName:name
                                                          object:self];
    }
}

@end
