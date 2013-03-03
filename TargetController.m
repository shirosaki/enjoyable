//
//  TargetController.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "TargetController.h"

#import "NJMappingsController.h"
#import "NJMapping.h"
#import "NJInput.h"
#import "NJInputController.h"
#import "NJKeyInputField.h"
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
        keyInput.keyCode = -1;
        [keyInput resignIfFirstResponder];
    }
    
    if (row != 2) {
        [mappingPopup selectItemAtIndex:-1];
        [mappingPopup resignIfFirstResponder];
    } else if (!mappingPopup.selectedItem)
        [mappingPopup selectItemAtIndex:0];
    
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

- (void)keyInputField:(NJKeyInputField *)keyInput didChangeKey:(CGKeyCode)keyCode {
    [radioButtons selectCellAtRow:1 column:0];
    [radioButtons.window makeFirstResponder:radioButtons];
    [self commit];
}

- (void)keyInputFieldDidClear:(NJKeyInputField *)keyInput {
    [radioButtons selectCellAtRow:0 column:0];
    [self commit];
}

- (void)mappingChosen:(id)sender {
    [radioButtons selectCellAtRow:2 column:0];
    [mappingPopup.window makeFirstResponder:mappingPopup];
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
    return mappingsController.currentMapping[joystickController.selectedInput];
}

- (Target *)makeTarget {
    switch (radioButtons.selectedRow) {
        case 0:
            return nil;
        case 1:
            if (keyInput.hasKeyCode) {
                TargetKeyboard *k = [[TargetKeyboard alloc] init];
                k.vk = keyInput.keyCode;
                return k;
            } else {
                return nil;
            }
            break;
        case 2: {
            TargetConfig *c = [[TargetConfig alloc] init];
            c.mapping = mappingsController.mappings[mappingPopup.indexOfSelectedItem];
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
    mappingsController.currentMapping[joystickController.selectedInput] = [self makeTarget];
    [mappingsController save];
}

- (BOOL)enabled {
    return [radioButtons isEnabled];
}

- (void)setEnabled:(BOOL)enabled {
    [radioButtons setEnabled:enabled];
    [keyInput setEnabled:enabled];
    [mappingPopup setEnabled:enabled];
    [mouseDirSelect setEnabled:enabled];
    [mouseBtnSelect setEnabled:enabled];
    [scrollDirSelect setEnabled:enabled];
}

- (void)loadTarget:(Target *)target forInput:(NJInput *)input {
    if (!input) {
        self.enabled = NO;
        title.stringValue = @"";
    } else {
        self.enabled = YES;
        NSString *inpFullName = input.name;
        for (id <NJInputPathElement> cur = input.base; cur; cur = cur.base) {
            inpFullName = [[NSString alloc] initWithFormat:@"%@ > %@", cur.name, inpFullName];
        }
        title.stringValue = [[NSString alloc] initWithFormat:@"%@ > %@", mappingsController.currentMapping.name, inpFullName];
    }

    if ([target isKindOfClass:TargetKeyboard.class]) {
        [radioButtons selectCellAtRow:1 column:0];
        keyInput.keyCode = [(TargetKeyboard*)target vk];
    } else if ([target isKindOfClass:TargetConfig.class]) {
        [radioButtons selectCellAtRow:2 column:0];
        NSUInteger idx = [mappingsController.mappings
                          indexOfObject:[(TargetConfig *)target mapping]];
        if (idx == NSNotFound) {
            [radioButtons selectCellAtRow:self.enabled ? 0 : -1 column:0];
            [mappingPopup selectItemAtIndex:-1];
        } else
            [mappingPopup selectItemAtIndex:idx];
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
    [self loadTarget:self.currentTarget forInput:joystickController.selectedInput];
}

- (void)focusKey {
    if (radioButtons.selectedRow <= 1)
        [keyInput.window makeFirstResponder:keyInput];
    else
        [keyInput resignIfFirstResponder];
}

- (void)refreshMappings {
    NSInteger initialIndex = mappingPopup.indexOfSelectedItem;
    [mappingPopup.menu removeAllItems];
    for (NJMapping *mapping in mappingsController.mappings) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:mapping.name
                                                      action:@selector(mappingChosen:)
                                               keyEquivalent:@""];
        item.target = self;
        [mappingPopup.menu addItem:item];
    }
    [mappingPopup selectItemAtIndex:initialIndex];
}

@end
