//
//  TargetController.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "TargetController.h"

#import "ConfigsController.h"
#import "Config.h"
#import "JSAction.h"
#import "JoystickController.h"
#import "KeyInputTextView.h"
#import "TargetConfig.h"
#import "TargetController.h"
#import "TargetKeyboard.h"
#import "TargetMouseBtn.h"
#import "TargetMouseMove.h"
#import "TargetMouseScroll.h"
#import "TargetToggleMouseScope.h"

@implementation TargetController

- (void)keyChanged {
	[radioButtons setState:1 atRow:1 column:0 ];
	[self commit];
}

- (IBAction)radioChanged:(id)sender {
    NSInteger row, col;
    [radioButtons getRow:&row column:&col ofCell:sender];
	[[NSApplication sharedApplication].mainWindow makeFirstResponder:sender];

    if (row != 1)
        keyInput.vk = -1;

    if (row != 2)
        [configPopup selectItemAtIndex:-1];
    else if (!configPopup.selectedItem)
        [configPopup selectItemAtIndex:0];

    if (row != 3)
        mouseDirSelect.selectedSegment = -1;
    else if (mouseDirSelect.selectedSegment == -1)
        mouseDirSelect.selectedSegment = 0;

    if (row != 4)
        mouseBtnSelect.selectedSegment = -1;
    else if (mouseBtnSelect.selectedSegment == -1)
        mouseBtnSelect.selectedSegment = 0;
    
    if (row != 5)
        scrollDirSelect.selectedSegment = -1;
    else if (scrollDirSelect.selectedSegment == -1)
        scrollDirSelect.selectedSegment = 0;
    
	[self commit];
}

- (IBAction)mdirChanged:(id)sender {
    [radioButtons setState:1 atRow:3 column:0];
	[[NSApplication sharedApplication].mainWindow makeFirstResponder:sender];
	[self commit];
}

- (IBAction)mbtnChanged:(id)sender {
    [radioButtons setState:1 atRow:4 column:0];
	[[NSApplication sharedApplication].mainWindow makeFirstResponder:sender];
	[self commit];
}

- (IBAction)sdirChanged:(id)sender {
    [radioButtons setState:1 atRow:5 column:0];
	[[NSApplication sharedApplication].mainWindow makeFirstResponder:sender];
	[self commit];
}

- (Target *)makeTarget {
	switch (radioButtons.selectedRow) {
		case 0:
			return nil;
		case 1:
			if (keyInput.hasKey) {
				TargetKeyboard* k = [[TargetKeyboard alloc] init];
                k.vk = keyInput.vk;
				return k;
			} else {
                return nil;
            }
			break;
		case 2: {
			TargetConfig *c = [[TargetConfig alloc] init];
            if (!configPopup.selectedItem)
                [configPopup selectItemAtIndex:0];
            c.config = configsController.configs[configPopup.indexOfSelectedItem];
			return c;
		}
        case 3: {
            TargetMouseMove *mm = [[TargetMouseMove alloc] init];
            mm.dir = mouseDirSelect.selectedSegment;
            return mm;
        }
        case 4: {
            TargetMouseBtn *mb = [[TargetMouseBtn alloc] init];
            mb.which = mouseBtnSelect.selectedSegment == 0 ? kCGMouseButtonLeft : kCGMouseButtonRight;
            return mb;
        }
        case 5: {
            TargetMouseScroll *ms = [[TargetMouseScroll alloc] init];
            ms.howMuch = scrollDirSelect.selectedSegment ? 1 : -1;
            return ms;
        }
        case 6: {
            TargetToggleMouseScope *tms = [[TargetToggleMouseScope alloc] init];
            return tms;
        }
        default:
            return nil;
	}
}

-(void)configChosen:(id)sender {
	[radioButtons setState:1 atRow:2 column:0];
	[self commit];
}

- (void)commit {
    configsController.currentConfig[joystickController.selectedAction] = [self makeTarget];
}

- (void)reset {
	[keyInput clear];
	[radioButtons setState:1 atRow:0 column:0];
	[self refreshConfigsPreservingSelection:NO];
}

- (BOOL)enabled {
	return [radioButtons isEnabled];
}

- (void)setEnabled:(BOOL)enabled {
	[radioButtons setEnabled:enabled];
	[keyInput setEnabled:enabled];
	[configPopup setEnabled:enabled];
    [mouseDirSelect setEnabled:enabled];
    [mouseBtnSelect setEnabled:enabled];
    [scrollDirSelect setEnabled:enabled];
}
-(void) load {
	id jsaction = joystickController.selectedAction;
	currentJsaction = jsaction;
	if(!jsaction) {
        self.enabled = NO;
        title.stringValue = @"";
		return;
	} else {
        self.enabled = YES;
	}
	Target *target = configsController.currentConfig[jsaction];
	
	id act = jsaction;
	NSString* actFullName = [act name];
	while([act base]) {
		act = [act base];
		actFullName = [[NSString alloc] initWithFormat:@"%@ > %@", [act name], actFullName];
	}
    title.stringValue = [[NSString alloc] initWithFormat:@"%@ > %@", configsController.currentConfig.name, actFullName];
	
	if(!target) {
		[radioButtons setState:1 atRow:0 column:0];
	} else if([target isKindOfClass:[TargetKeyboard class]]) {
		[radioButtons setState:1 atRow:1 column:0];
        keyInput.vk = [(TargetKeyboard*)target vk];
	} else if([target isKindOfClass:[TargetConfig class]]) {
		[radioButtons setState:1 atRow:2 column:0];
		[configPopup selectItemAtIndex:[configsController.configs
                                        indexOfObject:[(TargetConfig *)target config]]];
    }
    else if ([target isKindOfClass:[TargetMouseMove class]]) {
        [radioButtons setState:1 atRow:3 column:0];
        [mouseDirSelect setSelectedSegment:[(TargetMouseMove *)target dir]];
	}
    else if ([target isKindOfClass:[TargetMouseBtn class]]) {
        [radioButtons setState:1 atRow:4 column:0];
        mouseBtnSelect.selectedSegment = [(TargetMouseBtn *)target which] == kCGMouseButtonLeft ? 0 : 1;
    }
    else if ([target isKindOfClass:[TargetMouseScroll class]]) {
        [radioButtons setState:1 atRow:5 column:0];
        scrollDirSelect.selectedSegment = [(TargetMouseScroll *)target howMuch] > 0;
    }
    else if ([target isKindOfClass:[TargetToggleMouseScope class]]) {
        [radioButtons setState:1 atRow:6 column:0];
    } else {
        NSLog(@"Unknown target type %@.", target.description);
	}
}

-(void) focusKey {
    Target *currentTarget = configsController.currentConfig[currentJsaction];
    if (!currentTarget || [currentTarget isKindOfClass:[TargetKeyboard class]])
        [[[NSApplication sharedApplication] mainWindow] makeFirstResponder:keyInput];
    else
        [keyInput resignFirstResponder];
}

- (void)refreshConfigsPreservingSelection:(BOOL)preserve  {
	int initialIndex = [configPopup indexOfSelectedItem];
	[configPopup removeAllItems];
	for (Config *config in configsController.configs)
		[configPopup addItemWithTitle:config.name];
    [configPopup selectItemAtIndex:preserve ? initialIndex : -1];
}

@end
