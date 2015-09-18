//
//  NJOutputController.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "NJOutputViewController.h"

#import "NJMapping.h"
#import "NJInput.h"
#import "NJEvents.h"
#import "NJInputController.h"
#import "NJKeyInputField.h"
#import "NJOutputMapping.h"
#import "NJOutputViewController.h"
#import "NJOutputKeyPress.h"
#import "NJOutputMouseButton.h"
#import "NJOutputMouseMove.h"
#import "NJOutputMouseScroll.h"

@implementation NJOutputViewController {
    NJInput *_input;
}

- (id)init {
    if ((self = [super init])) {
        [NSNotificationCenter.defaultCenter
            addObserver:self
            selector:@selector(mappingListDidChange:)
            name:NJEventMappingListChanged
            object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)cleanUpInterface {
    NSInteger row = self.radioButtons.selectedRow;
    
    if (row != 1) {
        self.keyInput.keyCode = NJKeyInputFieldEmpty;
        [self.keyInput resignIfFirstResponder];
    }
    
    if (row != 2) {
        [self.mappingPopup selectItemAtIndex:-1];
        [self.mappingPopup resignIfFirstResponder];
        self.unknownMapping.hidden = YES;
    }
    
    if (row != 3) {
        self.mouseDirSelect.selectedSegment = -1;
        self.mouseSpeedSlider.doubleValue = self.mouseSpeedSlider.minValue;
        [self.mouseDirSelect resignIfFirstResponder];
    } else {
        if (self.mouseDirSelect.selectedSegment == -1)
            self.mouseDirSelect.selectedSegment = 0;
        if (self.mouseSpeedSlider.floatValue == 0)
            self.mouseSpeedSlider.floatValue = 10;
    }
    
    if (row != 4) {
        self.mouseBtnSelect.selectedSegment = -1;
        [self.mouseBtnSelect resignIfFirstResponder];
    } else if (self.mouseBtnSelect.selectedSegment == -1)
        self.mouseBtnSelect.selectedSegment = 0;
    
    if (row != 5) {
        self.scrollDirSelect.selectedSegment = -1;
        self.scrollSpeedSlider.doubleValue = self.scrollSpeedSlider.minValue;
        self.smoothCheck.state = NSOffState;
        [self.scrollDirSelect resignIfFirstResponder];
        [self.scrollSpeedSlider resignIfFirstResponder];
        [self.smoothCheck resignIfFirstResponder];
    } else {
        if (self.scrollDirSelect.selectedSegment == -1)
            self.scrollDirSelect.selectedSegment = 0;
    }
        
}

- (IBAction)outputTypeChanged:(NSView *)sender {
    [sender.window makeFirstResponder:sender];
    if (self.radioButtons.selectedRow == 1)
        [self.keyInput.window makeFirstResponder:self.keyInput];
    [self commit];
}

- (void)keyInputField:(NJKeyInputField *)keyInput didChangeKey:(CGKeyCode)keyCode {
    [self.radioButtons selectCellAtRow:1 column:0];
    [self.radioButtons.window makeFirstResponder:self.radioButtons];
    [self commit];
}

- (void)keyInputFieldDidClear:(NJKeyInputField *)keyInput {
    [self.radioButtons selectCellAtRow:0 column:0];
    [self commit];
}

- (void)mappingChosen:(id)sender {
    [self.radioButtons selectCellAtRow:2 column:0];
    [self.mappingPopup.window makeFirstResponder:self.mappingPopup];
    self.unknownMapping.hidden = YES;
    [self commit];
}

- (void)mouseDirectionChanged:(NSView *)sender {
    [self.radioButtons selectCellAtRow:3 column:0];
    [sender.window makeFirstResponder:sender];
    [self commit];
}

- (void)mouseSpeedChanged:(NSSlider *)sender {
    [self.radioButtons selectCellAtRow:3 column:0];
    [sender.window makeFirstResponder:sender];
    [self commit];
}

- (void)mouseButtonChanged:(NSView *)sender {
    [self.radioButtons selectCellAtRow:4 column:0];
    [sender.window makeFirstResponder:sender];
    [self commit];
}

- (void)scrollDirectionChanged:(NSView *)sender {
    [self.radioButtons selectCellAtRow:5 column:0];
    [sender.window makeFirstResponder:sender];
    [self commit];
}

- (void)scrollSpeedChanged:(NSSlider *)sender {
    [self.radioButtons selectCellAtRow:5 column:0];
    [sender.window makeFirstResponder:sender];
    [self commit];
}

- (IBAction)scrollTypeChanged:(NSButton *)sender {
    [self.radioButtons selectCellAtRow:5 column:0];
    [sender.window makeFirstResponder:sender];
    if (sender.state == NSOnState) {
        self.scrollSpeedSlider.doubleValue =
            self.scrollSpeedSlider.minValue
            + (self.scrollSpeedSlider.maxValue - self.scrollSpeedSlider.minValue) / 2;
        self.scrollSpeedSlider.enabled = YES;
    } else {
        self.scrollSpeedSlider.doubleValue = self.scrollSpeedSlider.minValue;
        self.scrollSpeedSlider.enabled = NO;
    }
    [self commit];
}

- (NJOutput *)makeOutput {
    switch (self.radioButtons.selectedRow) {
        case 0:
            return nil;
        case 1:
            if (self.keyInput.hasKeyCode) {
                NJOutputKeyPress *k = [[NJOutputKeyPress alloc] init];
                k.keyCode = self.keyInput.keyCode;
                return k;
            } else {
                return nil;
            }
            break;
        case 2: {
            NJOutputMapping *c = [[NJOutputMapping alloc] init];
            c.mapping = [self.delegate outputViewController:self
                                            mappingForIndex:self.mappingPopup.indexOfSelectedItem];
            return c;
        }
        case 3: {
            NJOutputMouseMove *mm = [[NJOutputMouseMove alloc] init];
            mm.axis = (int)self.mouseDirSelect.selectedSegment;
            mm.speed = self.mouseSpeedSlider.floatValue;
            return mm;
        }
        case 4: {
            NJOutputMouseButton *mb = [[NJOutputMouseButton alloc] init];
            mb.button = (int)[self.mouseBtnSelect.cell tagForSegment:self.mouseBtnSelect.selectedSegment];
            return mb;
        }
        case 5: {
            NJOutputMouseScroll *ms = [[NJOutputMouseScroll alloc] init];
            ms.direction = (int)[self.scrollDirSelect.cell tagForSegment:self.scrollDirSelect.selectedSegment];
            ms.speed = self.scrollSpeedSlider.floatValue;
            ms.smooth = self.smoothCheck.state == NSOnState;
            return ms;
        }
        default:
            return nil;
    }
}

- (void)commit {
    [self cleanUpInterface];
    [self.delegate outputViewController:self
                              setOutput:[self makeOutput]
                               forInput:_input];
}

- (BOOL)enabled {
    return self.radioButtons.isEnabled;
}

- (void)setEnabled:(BOOL)enabled {
    self.radioButtons.enabled = enabled;
    self.keyInput.enabled = enabled;
    self.mappingPopup.enabled = enabled;
    self.mouseDirSelect.enabled = enabled;
    self.mouseSpeedSlider.enabled = enabled;
    self.mouseBtnSelect.enabled = enabled;
    self.scrollDirSelect.enabled = enabled;
    self.smoothCheck.enabled = enabled;
    self.scrollSpeedSlider.enabled = enabled && self.smoothCheck.state;
    if (!enabled)
        self.unknownMapping.hidden = YES;
}

- (void)loadOutput:(NJOutput *)output forInput:(NJInput *)input {
    _input = input;
    if (!input) {
        [self setEnabled:NO];
        self.title.stringValue = @"";
    } else {
        [self setEnabled:YES];
        NSString *inpFullName = input.name;
        for (NJInputPathElement *cur = input.parent; cur; cur = cur.parent) {
            inpFullName = [[NSString alloc] initWithFormat:@"%@ ▸ %@", cur.name, inpFullName];
        }
        self.title.stringValue = inpFullName;
    }

    if ([output isKindOfClass:NJOutputKeyPress.class]) {
        [self.radioButtons selectCellAtRow:1 column:0];
        self.keyInput.keyCode = [(NJOutputKeyPress*)output keyCode];
    } else if ([output isKindOfClass:NJOutputMapping.class]) {
        [self.radioButtons selectCellAtRow:2 column:0];
        NSMenuItem *item = [self.mappingPopup itemWithIdenticalRepresentedObject:
                            [(NJOutputMapping *)output mapping]];
        [self.mappingPopup selectItem:item];
        self.unknownMapping.hidden = !!item;
        self.unknownMapping.title = [(NJOutputMapping *)output mappingName];
    }
    else if ([output isKindOfClass:NJOutputMouseMove.class]) {
        [self.radioButtons selectCellAtRow:3 column:0];
        self.mouseDirSelect.selectedSegment = [(NJOutputMouseMove *)output axis];
        self.mouseSpeedSlider.floatValue = [(NJOutputMouseMove *)output speed];
    }
    else if ([output isKindOfClass:NJOutputMouseButton.class]) {
        [self.radioButtons selectCellAtRow:4 column:0];
        [self.mouseBtnSelect selectSegmentWithTag:[(NJOutputMouseButton *)output button]];
    }
    else if ([output isKindOfClass:NJOutputMouseScroll.class]) {
        [self.radioButtons selectCellAtRow:5 column:0];
        int direction = [(NJOutputMouseScroll *)output direction];
        float speed = [(NJOutputMouseScroll *)output speed];
        BOOL smooth = [(NJOutputMouseScroll *)output smooth];
        [self.scrollDirSelect selectSegmentWithTag:direction];
        self.scrollSpeedSlider.floatValue = speed;
        self.smoothCheck.state = smooth ? NSOnState : NSOffState;
        self.scrollSpeedSlider.enabled = smooth;
    } else {
        [self.radioButtons selectCellAtRow:self.enabled ? 0 : -1 column:0];
    }
    [self cleanUpInterface];
}

- (void)focusKey {
    if (self.radioButtons.selectedRow <= 1)
        [self.keyInput.window makeFirstResponder:self.keyInput];
    else
        [self.keyInput resignIfFirstResponder];
}

- (void)mappingListDidChange:(NSNotification *)note {
    NSArray *mappings = note.userInfo[NJMappingListKey];
    NJMapping *current = self.mappingPopup.selectedItem.representedObject;
    [self.mappingPopup.menu removeAllItems];
    for (NJMapping *mapping in mappings) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:mapping.name
                                                      action:@selector(mappingChosen:)
                                               keyEquivalent:@""];
        item.target = self;
        item.representedObject = mapping;
        [self.mappingPopup.menu addItem:item];
    }
    [self.mappingPopup selectItemWithIdenticalRepresentedObject:current];
}

@end
