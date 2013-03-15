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
    NJHIDManager *_hidManager;
    NSTimer *_continuousOutputsTick;
    NSMutableArray *_continousOutputs;
    NSMutableArray *_devices;
    NSMutableArray *_expanded;
}

#define EXPANDED_MEMORY_MAX_SIZE 100
#define NSSTR(e) ((NSString *)CFSTR(e))

- (id)init {
    if ((self = [super init])) {
        _devices = [[NSMutableArray alloc] initWithCapacity:16];
        _continousOutputs = [[NSMutableArray alloc] initWithCapacity:32];
        
        NSArray *expanded = [NSUserDefaults.standardUserDefaults objectForKey:@"expanded rows"];
        if (![expanded isKindOfClass:NSArray.class])
            expanded = @[];
        _expanded = [[NSMutableArray alloc] initWithCapacity:MAX(16, _expanded.count)];
        [_expanded addObjectsFromArray:expanded];
        
        _hidManager = [[NJHIDManager alloc] initWithCriteria:@[
                       @{ NSSTR(kIOHIDDeviceUsagePageKey) : @(kHIDPage_GenericDesktop),
                       NSSTR(kIOHIDDeviceUsageKey) : @(kHIDUsage_GD_Joystick) },
                       @{ NSSTR(kIOHIDDeviceUsagePageKey) : @(kHIDPage_GenericDesktop),
                       NSSTR(kIOHIDDeviceUsageKey) : @(kHIDUsage_GD_GamePad) },
                       @{ NSSTR(kIOHIDDeviceUsagePageKey) : @(kHIDPage_GenericDesktop),
                       NSSTR(kIOHIDDeviceUsageKey) : @(kHIDUsage_GD_MultiAxisController) }
                       ]
                                                    delegate:self];

        [NSNotificationCenter.defaultCenter
             addObserver:self
             selector:@selector(startHid)
             name:NSApplicationDidFinishLaunchingNotification
             object:nil];
        
        // The HID manager uses 5-10ms per second doing basically
        // nothing if a noisy device is plugged in (the % of that
        // spent in input_callback is negligible, so it's not
        // something we can make faster). I don't really think that's
        // acceptable, CPU/power wise. So if simulation is disabled
        // and the window is closed, just switch off the HID manager
        // entirely. This probably also has some marginal benefits for
        // compatibility with other applications that want exclusive
        // grabs.
        [NSNotificationCenter.defaultCenter
            addObserver:self
            selector:@selector(stopHidIfDisabled:)
            name:NSApplicationDidResignActiveNotification
            object:nil];
        [NSNotificationCenter.defaultCenter
            addObserver:self
            selector:@selector(startHid)
            name:NSApplicationDidBecomeActiveNotification
            object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [_continuousOutputsTick invalidate];
}

- (void)expandRecursive:(NJInputPathElement *)pathElement {
    if (pathElement) {
        [self expandRecursive:pathElement.parent];
        [outlineView expandItem:pathElement];
    }
}

- (id)elementForUID:(NSString *)uid {
    for (NJDevice *dev in _devices) {
        id item = [dev elementForUID:uid];
        if (item)
            return item;
    }
    return nil;
}

- (void)expandRecursiveByUID:(NSString *)uid {
    [self expandRecursive:[self elementForUID:uid]];
}

- (void)addRunningOutput:(NJOutput *)output {
    // Axis events will trigger every small movement, don't keep
    // re-adding them or they trigger multiple times each time.
    if (![_continousOutputs containsObject:output])
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
    if (!self.simulatingEvents)
        [outputController focusKey];
}

- (void)hidManager:(NJHIDManager *)manager
      valueChanged:(IOHIDValueRef)value
        fromDevice:(IOHIDDeviceRef)device {
    if (self.simulatingEvents
        && !NSApplication.sharedApplication.isActive) {
        [self runOutputForDevice:device value:value];
    } else {
        [self showOutputForDevice:device value:value];
    }
}

static int findAvailableIndex(NSArray *list, NJDevice *dev) {
    for (int index = 1; ; index++) {
        BOOL available = YES;
        for (NJDevice *used in list) {
            if ([used.productName isEqualToString:dev.productName]
                && used.index == index) {
                available = NO;
                break;
            }
        }
        if (available)
            return index;
    }
}

- (void)hidManager:(NJHIDManager *)manager deviceAdded:(IOHIDDeviceRef)device {
    NJDevice *match = [[NJDevice alloc] initWithDevice:device];
    match.index = findAvailableIndex(_devices, match);
    [_devices addObject:match];
    [outlineView reloadData];
    [self reexpandAll];
    hidSleepingPrompt.hidden = YES;
    connectDevicePrompt.hidden = !!_devices.count;
}

- (NJDevice *)findDeviceByRef:(IOHIDDeviceRef)device {
    for (NJDevice *dev in _devices)
        if (dev.device == device)
            return dev;
    return nil;
}

- (void)hidManager:(NJHIDManager *)manager deviceRemoved:(IOHIDDeviceRef)device {
    NJDevice *match = [self findDeviceByRef:device];
    IOHIDDeviceRegisterInputValueCallback(device, NULL, NULL);
    if (match) {
        [_devices removeObject:match];
        [outlineView reloadData];
        connectDevicePrompt.hidden = !!_devices.count;
        hidSleepingPrompt.hidden = YES;
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

- (void)hidManager:(NJHIDManager *)manager didError:(NSError *)error {
    // Since the error shows the window, it can trigger another attempt
    // to re-open the HID manager, which will also probably fail and error,
    // so don't bother repeating ourselves.
    if (!outlineView.window.attachedSheet) {
        [NSApplication.sharedApplication activateIgnoringOtherApps:YES];
        [outlineView.window makeKeyAndOrderFront:nil];
        [outlineView.window presentError:error
                          modalForWindow:outlineView.window
                                delegate:nil
                      didPresentSelector:nil
                             contextInfo:nil];
    }
    self.simulatingEvents = NO;
    if (manager.running)
        [self hidManagerDidStart:manager];
    else
        [self hidManagerDidStop:manager];
}

- (void)hidManagerDidStart:(NJHIDManager *)manager {
    hidSleepingPrompt.hidden = YES;
    connectDevicePrompt.hidden = !!_devices.count;
}

- (void)hidManagerDidStop:(NJHIDManager *)manager {
    [_devices removeAllObjects];
    [outlineView reloadData];
    hidSleepingPrompt.hidden = NO;
    connectDevicePrompt.hidden = YES;
}

- (void)startHid {
    [_hidManager start];
}

- (void)stopHid {
    [_hidManager stop];
}

- (NJInput *)selectedInput {
    NJInputPathElement *item = [outlineView itemAtRow:outlineView.selectedRow];
    return (NJInput *)((!item.children && item.parent) ? item : nil);
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(NJInputPathElement *)item {
    return item ? item.children.count : _devices.count;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(NJInputPathElement *)item {
    return item ? [[item children] count] > 0: YES;
}

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(NJInputPathElement *)item {
    return item ? item.children[index] : _devices[index];
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(NJInputPathElement *)item  {
    return item ? item.name : @"root";
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NJInputPathElement *item = [outlineView itemAtRow:outlineView.selectedRow];
    if (item)
        [NSUserDefaults.standardUserDefaults setObject:item.uid
                                                forKey:@"selected input"];
    [outputController loadCurrent];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
        isGroupItem:(NJInputPathElement *)item {
    return [item isKindOfClass:NJDevice.class];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView_
   shouldSelectItem:(NJInputPathElement *)item {
    return ![self outlineView:outlineView_ isGroupItem:item];
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification {
    NJInputPathElement *item = notification.userInfo[@"NSObject"];
    NSString *uid = item.uid;
    if (![_expanded containsObject:uid])
        [_expanded addObject:uid];
    while (_expanded.count > EXPANDED_MEMORY_MAX_SIZE)
        [_expanded removeObjectAtIndex:0];
    [NSUserDefaults.standardUserDefaults setObject:_expanded
                                            forKey:@"expanded rows"];
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification {
    NJInputPathElement *item = notification.userInfo[@"NSObject"];
    [_expanded removeObject:item.uid];
    [NSUserDefaults.standardUserDefaults setObject:_expanded
                                            forKey:@"expanded rows"];
}

- (void)setSimulatingEvents:(BOOL)simulatingEvents {
    if (simulatingEvents != _simulatingEvents) {
        _simulatingEvents = simulatingEvents;
        NSInteger state = simulatingEvents ? NSOnState : NSOffState;
        simulatingEventsButton.state = state;
        NSString *name = simulatingEvents
            ? NJEventSimulationStarted
            : NJEventSimulationStopped;
        [NSNotificationCenter.defaultCenter postNotificationName:name
                                                          object:self];

        if (!simulatingEvents && !NSApplication.sharedApplication.isActive)
            [self stopHid];
        else
            [self startHid];
    }
}

- (void)reexpandAll {
    for (NSString *uid in [_expanded copy])
        [self expandRecursiveByUID:uid];
    if (outlineView.selectedRow == -1) {
        NSString *selectedUid = [NSUserDefaults.standardUserDefaults objectForKey:@"selected input"];
        id item = [self elementForUID:selectedUid];
        NSInteger row = [outlineView rowForItem:item];
        if (row >= 0)
            [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    }
}

- (void)stopHidIfDisabled:(NSNotification *)application {
    if (!self.simulatingEvents)
        [self stopHid];
}

- (IBAction)simulatingEventsChanged:(NSButton *)sender {
    self.simulatingEvents = sender.state == NSOnState;
}

@end
