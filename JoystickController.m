//
//  JoystickController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "JoystickController.h"

@implementation JoystickController

@synthesize joysticks, runningTargets, selectedAction, frontWindowOnly;

-(id) init {
	if(self=[super init]) {
		joysticks = [[NSMutableArray alloc]init];
        runningTargets = [[NSMutableArray alloc]init];
		programmaticallySelecting = NO;
        mouseLoc.x = mouseLoc.y = 0;
	}
	return self;
}

-(void) dealloc {
	for(int i=0; i<[joysticks count]; i++) {
		[joysticks[i] invalidate];
	}
	IOHIDManagerClose(hidManager, kIOHIDOptionsTypeNone);
	CFRelease(hidManager);
}

static NSMutableDictionary* create_criterion( UInt32 inUsagePage, UInt32 inUsage )
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	dict[(NSString*)CFSTR(kIOHIDDeviceUsagePageKey)] = @(inUsagePage);
	dict[(NSString*)CFSTR(kIOHIDDeviceUsageKey)] = @(inUsage);
	return dict;
} 

-(void) expandRecursive: (id) handler {
	if([handler base])
		[self expandRecursive: [handler base]];
	[outlineView expandItem: handler];
}

static void timer_callback(CFRunLoopTimerRef timer, void *ctx) {
    JoystickController *jc = (__bridge JoystickController *)ctx;
    jc->mouseLoc = [NSEvent mouseLocation];
    for (Target *target in [jc runningTargets]) {
        [target update: jc];
    }
}

static void input_callback(void *ctx, IOReturn inResult, void *inSender, IOHIDValueRef value) {
	JoystickController *controller = (__bridge JoystickController *)ctx;
	IOHIDDeviceRef device = IOHIDQueueGetDevice(inSender);
	
	Joystick *js = [controller findJoystickByRef:device];
	if([(ApplicationController *)[[NSApplication sharedApplication] delegate] active]) {
		JSAction* mainAction = [js actionForEvent: value];
		if(!mainAction)
			return;
		
		[mainAction notifyEvent: value];
		NSArray* children = [mainAction children];
		if(!children)
			children = @[mainAction];
		for(id subaction in children) {
			Target* target = [[controller->configsController currentConfig] getTargetForAction:subaction];
			if(!target)
				continue;
			/* target application? doesn't seem to be any need since we are only active when it's in front */
			/* might be required for some strange actions */
            if ([target running] != [subaction active]) {
                if ([subaction active]) {
                    [target trigger: controller];
                }
                else {
                    [target untrigger: controller];
                }
                [target setRunning: [subaction active]];
            }
            
            if ([mainAction isKindOfClass: [JSActionAnalog class]]) {
                double realValue = [(JSActionAnalog*)mainAction getRealValue: IOHIDValueGetIntegerValue(value)];
                [target setInputValue: realValue];
            
                // Add to list of running targets
                if ([target isContinuous] && [target running]) {
                    if (![controller.runningTargets containsObject:target]) {
                        [[controller runningTargets] addObject: target];
                    }
                }
            }
		}
	} else if([[NSApplication sharedApplication] isActive] && [[[NSApplication sharedApplication]mainWindow]isVisible]) {
		// joysticks not active, use it to select stuff
		id handler = [js handlerForEvent: value];
		if(!handler)
			return;
	
		[controller expandRecursive: handler];
		controller->programmaticallySelecting = YES;
		[controller->outlineView selectRowIndexes: [NSIndexSet indexSetWithIndex: [controller->outlineView rowForItem: handler]] byExtendingSelection: NO];
	}
}

static int findAvailableIndex(id list, Joystick* js) {
	BOOL available;
	Joystick* js2;
	for(int index=0;;index++) {
		available = YES;
		for(int i=0; i<[list count]; i++) {
			js2 = list[i];
			if([js2 vendorId] == [js vendorId] && [js2 productId] == [js productId] && [js index] == index) {
				available = NO;
				break;
			}
		}
		if(available)
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
    for (Joystick *js in joysticks)
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

- (void)setup {
    hidManager = IOHIDManagerCreate( kCFAllocatorDefault, kIOHIDOptionsTypeNone);
	NSArray *criteria = @[
        create_criterion(kHIDPage_GenericDesktop, kHIDUsage_GD_Joystick),
        create_criterion(kHIDPage_GenericDesktop, kHIDUsage_GD_GamePad),
        create_criterion(kHIDPage_GenericDesktop, kHIDUsage_GD_MultiAxisController)];
	
	IOHIDManagerSetDeviceMatchingMultiple(hidManager, (CFArrayRef)CFBridgingRetain(criteria));
    
	IOHIDManagerScheduleWithRunLoop( hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode );
	IOReturn tIOReturn = IOHIDManagerOpen( hidManager, kIOHIDOptionsTypeNone );
	(void)tIOReturn;
	
	IOHIDManagerRegisterDeviceMatchingCallback(hidManager, add_callback, (__bridge void *)self );
	IOHIDManagerRegisterDeviceRemovalCallback(hidManager, remove_callback, (__bridge void *)self);

    // Setup timer for continuous targets
    CFRunLoopTimerContext ctx = {
        0, (__bridge void*)self, NULL, NULL, NULL
    };
    CFRunLoopTimerRef timer = CFRunLoopTimerCreate(kCFAllocatorDefault,
                                                   CFAbsoluteTimeGetCurrent(), 1.0/80.0,
                                                   0, 0, timer_callback, &ctx);
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopDefaultMode);
}

- (JSAction *)selectedAction {
    id item = [outlineView itemAtRow:outlineView.selectedRow];
    return [item children] ? nil : item;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return item ? [[item children] count] : [joysticks count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return item ? [[item children] count] > 0: YES;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
    return item ? [item children][index] : joysticks[index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item  {
	if(item == nil)
		return @"root";
	return [item name];
}

- (void)outlineViewSelectionDidChange: (NSNotification*) notification {
	[targetController reset];
	[targetController load];
	if (programmaticallySelecting)
		[targetController focusKey];
	programmaticallySelecting = NO;
}
	
@end
