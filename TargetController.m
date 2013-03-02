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

- (void)cleanUpInterface {
    NSInteger row = radioButtons.selectedRow;
    
    if (row != 1) {
        keyInput.vk = -1;
        [keyInput resignIfFirstResponder];
    }
    
    if (row != 2) {
        [configPopup selectItemAtIndex:-1];
        [configPopup resignIfFirstResponder];
    } else if (!configPopup.selectedItem)
        [configPopup selectItemAtIndex:0];
    
    if (row != 3) {
        mouseDirSelect.selectedSegment = -1;
        [mouseDirSelect resignIfFirstResponder];
    } else if (mouseDirSelect.selectedSegment == -1)
        mouseDirSelect.selectedSegment = 0;
    
    if (row != 4) {
        mouseBtnSelect.selectedSegment = -1;
        [mouseBtnSelect resignIfFirstResponder];
    } else if (mouseBtnSelect.selectedSegment == -1)
        mouseBtnSelect.selectedSegment = 0;
    
    if (row != 5) {
        scrollDirSelect.selectedSegment = -1;
        [scrollDirSelect resignIfFirstResponder];
    } else if (scrollDirSelect.selectedSegment == -1)
        scrollDirSelect.selectedSegment = 0;    
}

- (IBAction)radioChanged:(NSView *)sender {
    [sender.window makeFirstResponder:sender];
    if (radioButtons.selectedRow == 1)
        [keyInput.window makeFirstResponder:keyInput];
    [self commit];
}

- (void)keyChanged {
    [radioButtons selectCellAtRow:1 column:0];
    [radioButtons.window makeFirstResponder:radioButtons];
    [self commit];
}

- (void)configChosen:(id)sender {
    [radioButtons selectCellAtRow:2 column:0];
    [configPopup.window makeFirstResponder:configPopup];
    [self commit];
}

- (void)mdirChanged:(NSView *)sender {
    [radioButtons selectCellAtRow:3 column:0];
    [sender.window makeFirstResponder:sender];
    [self commit];
}

- (void)mbtnChanged:(NSView *)sender {
    [radioButtons selectCellAtRow:4 column:0];
    [sender.window makeFirstResponder:sender];
    [self commit];
}

- (void)sdirChanged:(NSView *)sender {
    [radioButtons selectCellAtRow:5 column:0];
    [sender.window makeFirstResponder:sender];
    [self commit];
}

- (Target *)currentTarget {
    return configsController.currentConfig[joystickController.selectedAction];
}

- (Target *)makeTarget {
    switch (radioButtons.selectedRow) {
        case 0:
            return nil;
        case 1:
            if (keyInput.hasKey) {
                TargetKeyboard *k = [[TargetKeyboard alloc] init];
                k.vk = keyInput.vk;
                return k;
            } else {
                return nil;
            }
            break;
        case 2: {
            TargetConfig *c = [[TargetConfig alloc] init];
            c.config = configsController.configs[configPopup.indexOfSelectedItem];
            return c;
        }
        case 3: {
            TargetMouseMove *mm = [[TargetMouseMove alloc] init];
            mm.axis = mouseDirSelect.selectedSegment;
            return mm;
        }
        case 4: {
            TargetMouseBtn *mb = [[TargetMouseBtn alloc] init];
            mb.button = mouseBtnSelect.selectedSegment == 0 ? kCGMouseButtonLeft : kCGMouseButtonRight;
            return mb;
        }
        case 5: {
            TargetMouseScroll *ms = [[TargetMouseScroll alloc] init];
            ms.amount = scrollDirSelect.selectedSegment ? 1 : -1;
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

- (void)commit {
    [self cleanUpInterface];
    configsController.currentConfig[joystickController.selectedAction] = [self makeTarget];
    [configsController save];
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

- (void)loadTarget:(Target *)target forAction:(JSAction *)action {
    if (!action) {
        self.enabled = NO;
        title.stringValue = @"";
    } else {
        self.enabled = YES;
        NSString *actFullName = action.name;
        for (id <NJActionPathElement> cur = action.base; cur; cur = cur.base) {
            actFullName = [[NSString alloc] initWithFormat:@"%@ > %@", cur.name, actFullName];
        }
        title.stringValue = [[NSString alloc] initWithFormat:@"%@ > %@", configsController.currentConfig.name, actFullName];
    }

    if ([target isKindOfClass:TargetKeyboard.class]) {
        [radioButtons selectCellAtRow:1 column:0];
        keyInput.vk = [(TargetKeyboard*)target vk];
    } else if ([target isKindOfClass:TargetConfig.class]) {
        [radioButtons selectCellAtRow:2 column:0];
        NSUInteger idx = [configsController.configs
                          indexOfObject:[(TargetConfig *)target config]];
        if (idx == NSNotFound) {
            [radioButtons selectCellAtRow:self.enabled ? 0 : -1 column:0];
            [configPopup selectItemAtIndex:-1];
        } else
            [configPopup selectItemAtIndex:idx];
    }
    else if ([target isKindOfClass:TargetMouseMove.class]) {
        [radioButtons selectCellAtRow:3 column:0];
        [mouseDirSelect setSelectedSegment:[(TargetMouseMove *)target axis]];
    }
    else if ([target isKindOfClass:TargetMouseBtn.class]) {
        [radioButtons selectCellAtRow:4 column:0];
        mouseBtnSelect.selectedSegment = [(TargetMouseBtn *)target button] == kCGMouseButtonLeft ? 0 : 1;
    }
    else if ([target isKindOfClass:TargetMouseScroll.class]) {
        [radioButtons selectCellAtRow:5 column:0];
        scrollDirSelect.selectedSegment = [(TargetMouseScroll *)target amount] > 0;
    }
    else if ([target isKindOfClass:TargetToggleMouseScope.class]) {
        [radioButtons selectCellAtRow:6 column:0];
    } else {
        [radioButtons selectCellAtRow:self.enabled ? 0 : -1 column:0];
    }
    [self cleanUpInterface];
}

- (void)loadCurrent {
    [self loadTarget:self.currentTarget forAction:joystickController.selectedAction];
}

- (void)focusKey {
    if (radioButtons.selectedRow <= 1)
        [keyInput.window makeFirstResponder:keyInput];
    else
        [keyInput resignIfFirstResponder];
}

- (void)refreshConfigs {
    NSInteger initialIndex = configPopup.indexOfSelectedItem;
    [configPopup.menu removeAllItems];
    for (Config *config in configsController.configs) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:config.name
                                                      action:@selector(configChosen:)
                                               keyEquivalent:@""];
        item.target = self;
        [configPopup.menu addItem:item];
    }
    [configPopup selectItemAtIndex:initialIndex];
}

@end
