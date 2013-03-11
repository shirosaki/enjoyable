//
//  NJDeviceController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "NJDeviceController.h"

#import "NJMapping.h"
#import "NJMappingsController.h"
#import "NJDevice.h"
#import "NJInput.h"
#import "NJOutput.h"
#import "NJOutputController.h"
#import "NJEvents.h"

@implementation NJDeviceController {
    IOHIDManagerRef _hidManager;
    NSTimer *_continuousOutputsTick;
    NSMutableArray *_continousOutputs;
    NSMutableArray *_devices;
}

- (id)init {
    if ((self = [super init])) {
        _devices = [[NSMutableArray alloc] initWithCapacity:16];
        _continousOutputs = [[NSMutableArray alloc] initWithCapacity:32];
        [NSNotificationCenter.defaultCenter
            addObserver:self
            selector:@selector(setup)
            name:NSApplicationDidFinishLaunchingNotification
            object:nil];
    }
    return self;
}

- (void)dealloc {
    [_continuousOutputsTick invalidate];
    IOHIDManagerClose(_hidManager, kIOHIDOptionsTypeNone);
    CFRelease(_hidManager);
}

- (void)expandRecursive:(id <NJInputPathElement>)pathElement {
    if (pathElement) {
        [self expandRecursive:pathElement.base];
        [outlineView expandItem:pathElement];
    }
}

- (void)addRunningOutput:(NJOutput *)output {
    [_continousOutputs addObject:output];
    if (!_continuousOutputsTick) {
        _continuousOutputsTick = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0
                                                           target:self
                                                         selector:@selector(updateContinuousOutputs:)
                                                         userInfo:nil
                                                          repeats:YES];
    }
}

- (void)runOutputForDevice:(IOHIDDeviceRef)device value:(IOHIDValueRef)value {
    NJDevice *dev = [self findDeviceByRef:device];
    NJInput *mainInput = [dev inputForEvent:value];
    [mainInput notifyEvent:value];
    NSArray *children = mainInput.children ? mainInput.children : mainInput ? @[mainInput] : @[];
    for (NJInput *subInput in children) {
        NJOutput *output = mappingsController.currentMapping[subInput];
        output.magnitude = subInput.magnitude;
        output.running = subInput.active;
        if ((output.running || output.magnitude) && output.isContinuous)
            [self addRunningOutput:output];
    }
}

- (void)showOutputForDevice:(IOHIDDeviceRef)device value:(IOHIDValueRef)value {
    NJDevice *dev = [self findDeviceByRef:device];
    NJInput *handler = [dev handlerForEvent:value];
    if (!handler)
        return;
    
    [self expandRecursive:handler];
    [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:[outlineView rowForItem:handler]]
             byExtendingSelection: NO];
    [outputController focusKey];
}

static void input_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDValueRef value) {
    NJDeviceController *controller = (__bridge NJDeviceController *)ctx;
    IOHIDDeviceRef device = IOHIDQueueGetDevice(inSender);
    
    if (controller.translatingEvents) {
        [controller runOutputForDevice:device value:value];
    } else if ([NSApplication sharedApplication].mainWindow.isVisible) {
        [controller showOutputForDevice:device value:value];
    }
}

static int findAvailableIndex(NSArray *list, NJDevice *dev) {
    for (int index = 1; ; index++) {
        BOOL available = YES;
        for (NJDevice *used in list) {
            if ([used.productName isEqualToString:dev.productName] && used.index == index) {
                available = NO;
                break;
            }
        }
        if (available)
            return index;
    }
}

- (void)addDeviceForDevice:(IOHIDDeviceRef)device {
    IOHIDDeviceRegisterInputValueCallback(device, input_callback, (__bridge void *)self);
    NJDevice *dev = [[NJDevice alloc] initWithDevice:device];
    dev.index = findAvailableIndex(_devices, dev);
    [_devices addObject:dev];
    [outlineView reloadData];
    connectDevicePrompt.hidden = !!_devices.count;
}

static void add_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDDeviceRef device) {
    NJDeviceController *controller = (__bridge NJDeviceController *)ctx;
    [controller addDeviceForDevice:device];
}

- (NJDevice *)findDeviceByRef:(IOHIDDeviceRef)device {
    for (NJDevice *dev in _devices)
        if (dev.device == device)
            return dev;
    return nil;
}

static void remove_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDDeviceRef device) {
    NJDeviceController *controller = (__bridge NJDeviceController *)ctx;
    [controller removeDeviceForDevice:device];
}

- (void)removeDeviceForDevice:(IOHIDDeviceRef)device {
    NJDevice *match = [self findDeviceByRef:device];
    IOHIDDeviceRegisterInputValueCallback(device, NULL, NULL);
    if (match) {
        [_devices removeObject:match];
        [outlineView reloadData];
        connectDevicePrompt.hidden = !!_devices.count;
    }
    if (_devices.count == 1)
        [outlineView expandItem:_devices[0]];
}

- (void)updateContinuousOutputs:(NSTimer *)timer {
    self.mouseLoc = [NSEvent mouseLocation];
    for (NJOutput *output in [_continousOutputs copy]) {
        if (![output update:self]) {
            [_continousOutputs removeObject:output];
        }
    }
    if (!_continousOutputs.count) {
        [_continuousOutputsTick invalidate];
        _continuousOutputsTick = nil;
    }
}

#define NSSTR(e) ((NSString *)CFSTR(e))

- (void)setup {
    _hidManager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
    NSArray *criteria = @[ @{ NSSTR(kIOHIDDeviceUsagePageKey) : @(kHIDPage_GenericDesktop),
                              NSSTR(kIOHIDDeviceUsageKey) : @(kHIDUsage_GD_Joystick) },
                           @{ NSSTR(kIOHIDDeviceUsagePageKey) : @(kHIDPage_GenericDesktop),
                              NSSTR(kIOHIDDeviceUsageKey) : @(kHIDUsage_GD_GamePad) },
                           @{ NSSTR(kIOHIDDeviceUsagePageKey) : @(kHIDPage_GenericDesktop),
                              NSSTR(kIOHIDDeviceUsageKey) : @(kHIDUsage_GD_MultiAxisController) }
                           ];
    IOHIDManagerSetDeviceMatchingMultiple(_hidManager, (__bridge CFArrayRef)criteria);
    
    IOHIDManagerScheduleWithRunLoop(_hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOReturn ret = IOHIDManagerOpen(_hidManager, kIOHIDOptionsTypeNone);
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
    
    IOHIDManagerRegisterDeviceMatchingCallback(_hidManager, add_callback, (__bridge void *)self);
    IOHIDManagerRegisterDeviceRemovalCallback(_hidManager, remove_callback, (__bridge void *)self);
}

- (NJInput *)selectedInput {
    id <NJInputPathElement> item = [outlineView itemAtRow:outlineView.selectedRow];
    return (!item.children && item.base) ? item : nil;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id <NJInputPathElement>)item {
    return item ? item.children.count : _devices.count;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id <NJInputPathElement>)item {
    return item ? [[item children] count] > 0: YES;
}

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id <NJInputPathElement>)item {
    return item ? item.children[index] : _devices[index];
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(id <NJInputPathElement>)item  {
    return item ? item.name : @"root";
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    [outputController loadCurrent];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
        isGroupItem:(id <NJInputPathElement>)item {
    return [item isKindOfClass:NJDevice.class];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView_
   shouldSelectItem:(id <NJInputPathElement>)item {
    return ![self outlineView:outlineView_ isGroupItem:item];
}

- (void)setTranslatingEvents:(BOOL)translatingEvents {
    if (translatingEvents != _translatingEvents) {
        _translatingEvents = translatingEvents;
        NSInteger state = translatingEvents ? NSOnState : NSOffState;
        translatingEventsButton.state = state;
        NSString *name = translatingEvents
            ? NJEventTranslationActivated
            : NJEventTranslationDeactivated;
        [NSNotificationCenter.defaultCenter postNotificationName:name
                                                          object:self];
    }
}

- (IBAction)translatingEventsChanged:(NSButton *)sender {
    self.translatingEvents = sender.state == NSOnState;
}

@end
