//
//  NJOutputController.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "NJOutputController.h"

#import "NJMappingsController.h"
#import "NJMapping.h"
#import "NJInput.h"
#import "NJEvents.h"
#import "NJDeviceController.h"
#import "NJKeyInputField.h"
#import "NJOutputMapping.h"
#import "NJOutputController.h"
#import "NJOutputKeyPress.h"
#import "NJOutputMouseButton.h"
#import "NJOutputMouseMove.h"
#import "NJOutputMouseScroll.h"

@implementation NJOutputController

- (id)init {
    if ((self = [super init])) {
        [NSNotificationCenter.defaultCenter
            addObserver:self
            selector:@selector(mappingListDidChange:)
            name:NJEventMappingListChanged
            object:nil];
        [NSNotificationCenter.defaultCenter
             addObserver:self
             selector:@selector(mappingDidChange:)
             name:NJEventMappingChanged
             object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)cleanUpInterface {
    NSInteger row = radioButtons.selectedRow;
    
    if (row != 1) {
        keyInput.keyCode = NJKeyInputFieldEmpty;
        [keyInput resignIfFirstResponder];
    }
    
    if (row != 2) {
        [mappingPopup selectItemAtIndex:-1];
        [mappingPopup resignIfFirstResponder];
    } else if (!mappingPopup.selectedItem)
        [mappingPopup selectItemAtIndex:0];
    
    if (row != 3) {
        mouseDirSelect.selectedSegment = -1;
        mouseSpeedSlider.floatValue = mouseSpeedSlider.minValue;
        [mouseDirSelect resignIfFirstResponder];
    } else {
        if (mouseDirSelect.selectedSegment == -1)
            mouseDirSelect.selectedSegment = 0;
        if (!mouseSpeedSlider.floatValue)
            mouseSpeedSlider.floatValue = 10;
    }
    
    if (row != 4) {
        mouseBtnSelect.selectedSegment = -1;
        [mouseBtnSelect resignIfFirstResponder];
    } else if (mouseBtnSelect.selectedSegment == -1)
        mouseBtnSelect.selectedSegment = 0;
    
    if (row != 5) {
        scrollDirSelect.selectedSegment = -1;
        scrollSpeedSlider.floatValue = scrollSpeedSlider.minValue;
        smoothCheck.state = NSOffState;
        [scrollDirSelect resignIfFirstResponder];
        [scrollSpeedSlider resignIfFirstResponder];
        [smoothCheck resignIfFirstResponder];
    } else {
        if (scrollDirSelect.selectedSegment == -1)
            scrollDirSelect.selectedSegment = 0;
    }
        
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

- (void)mouseSpeedChanged:(NSSlider *)sender {
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

- (void)scrollSpeedChanged:(NSSlider *)sender {
    [radioButtons selectCellAtRow:5 column:0];
    [sender.window makeFirstResponder:sender];
    [self commit];
}

- (IBAction)scrollTypeChanged:(NSButton *)sender {
    [radioButtons selectCellAtRow:5 column:0];
    [sender.window makeFirstResponder:sender];
    if (sender.state == NSOnState) {
        scrollSpeedSlider.floatValue = (scrollSpeedSlider.maxValue - scrollSpeedSlider.minValue) / 2;
        [scrollSpeedSlider setEnabled:YES];
    } else {
        scrollSpeedSlider.floatValue = scrollSpeedSlider.minValue;
        [scrollSpeedSlider setEnabled:NO];
    }
    [self commit];
}

- (NJOutput *)currentOutput {
    return mappingsController.currentMapping[inputController.selectedInput];
}

- (NJOutput *)makeOutput {
    switch (radioButtons.selectedRow) {
        case 0:
            return nil;
        case 1:
            if (keyInput.hasKeyCode) {
                NJOutputKeyPress *k = [[NJOutputKeyPress alloc] init];
                k.vk = keyInput.keyCode;
                return k;
            } else {
                return nil;
            }
            break;
        case 2: {
            NJOutputMapping *c = [[NJOutputMapping alloc] init];
            c.mapping = mappingsController[mappingPopup.indexOfSelectedItem];
            return c;
        }
        case 3: {
            NJOutputMouseMove *mm = [[NJOutputMouseMove alloc] init];
            mm.axis = mouseDirSelect.selectedSegment;
            mm.speed = mouseSpeedSlider.floatValue;
            return mm;
        }
        case 4: {
            NJOutputMouseButton *mb = [[NJOutputMouseButton alloc] init];
            mb.button = [mouseBtnSelect.cell tagForSegment:mouseBtnSelect.selectedSegment];
            return mb;
        }
        case 5: {
            NJOutputMouseScroll *ms = [[NJOutputMouseScroll alloc] init];
            ms.direction = [scrollDirSelect.cell tagForSegment:scrollDirSelect.selectedSegment];
            ms.speed = scrollSpeedSlider.floatValue;
            ms.smooth = smoothCheck.state == NSOnState;
            return ms;
        }
        default:
            return nil;
    }
}

- (void)commit {
    [self cleanUpInterface];
    mappingsController.currentMapping[inputController.selectedInput] = [self makeOutput];
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
    [mouseSpeedSlider setEnabled:enabled];
    [mouseBtnSelect setEnabled:enabled];
    [scrollDirSelect setEnabled:enabled];
    [smoothCheck setEnabled:enabled];
    [scrollSpeedSlider setEnabled:enabled && smoothCheck.isEnabled];
}

- (void)loadOutput:(NJOutput *)output forInput:(NJInput *)input {
    if (!input) {
        self.enabled = NO;
        title.stringValue = @"";
    } else {
        self.enabled = YES;
        NSString *inpFullName = input.name;
        for (id <NJInputPathElement> cur = input.base; cur; cur = cur.base) {
            inpFullName = [[NSString alloc] initWithFormat:@"%@ > %@", cur.name, inpFullName];
        }
        title.stringValue = inpFullName;
    }

    if ([output isKindOfClass:NJOutputKeyPress.class]) {
        [radioButtons selectCellAtRow:1 column:0];
        keyInput.keyCode = [(NJOutputKeyPress*)output vk];
    } else if ([output isKindOfClass:NJOutputMapping.class]) {
        [radioButtons selectCellAtRow:2 column:0];
        NSMenuItem *item = [mappingPopup itemWithRepresentedObject:[(NJOutputMapping *)output mapping]];
        [mappingPopup selectItem:item];
        if (!item)
            [radioButtons selectCellAtRow:self.enabled ? 0 : -1 column:0];
    }
    else if ([output isKindOfClass:NJOutputMouseMove.class]) {
        [radioButtons selectCellAtRow:3 column:0];
        mouseDirSelect.selectedSegment = [(NJOutputMouseMove *)output axis];
        mouseSpeedSlider.floatValue = [(NJOutputMouseMove *)output speed];
    }
    else if ([output isKindOfClass:NJOutputMouseButton.class]) {
        [radioButtons selectCellAtRow:4 column:0];
        [mouseBtnSelect selectSegmentWithTag:[(NJOutputMouseButton *)output button]];
    }
    else if ([output isKindOfClass:NJOutputMouseScroll.class]) {
        [radioButtons selectCellAtRow:5 column:0];
        int direction = [(NJOutputMouseScroll *)output direction];
        float speed = [(NJOutputMouseScroll *)output speed];
        BOOL smooth = [(NJOutputMouseScroll *)output smooth];
        [scrollDirSelect selectSegmentWithTag:direction];
        scrollSpeedSlider.floatValue = speed;
        smoothCheck.state = smooth ? NSOnState : NSOffState;
        [scrollSpeedSlider setEnabled:smooth];
    } else {
        [radioButtons selectCellAtRow:self.enabled ? 0 : -1 column:0];
    }
    [self cleanUpInterface];
}

- (void)loadCurrent {
    [self loadOutput:self.currentOutput forInput:inputController.selectedInput];
}

- (void)focusKey {
    if (radioButtons.selectedRow <= 1)
        [keyInput.window makeFirstResponder:keyInput];
    else
        [keyInput resignIfFirstResponder];
}

- (void)mappingListDidChange:(NSNotification *)note {
    NSArray *mappings = note.object;
    NJMapping *current = mappingPopup.selectedItem.representedObject;
    [mappingPopup.menu removeAllItems];
    for (NJMapping *mapping in mappings) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:mapping.name
                                                      action:@selector(mappingChosen:)
                                               keyEquivalent:@""];
        item.target = self;
        item.representedObject = mapping;
        [mappingPopup.menu addItem:item];
    }
    [mappingPopup selectItemWithRepresentedObject:current];
}

- (void)mappingDidChange:(NSNotification *)note {
    [self loadCurrent];
}

@end
