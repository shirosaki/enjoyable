//
//  NJKeyInputField.h
//  Enjoyable
//
//  Copyright 2013 Joe Wreschnig.
//

#import "NJKeyInputField.h"

CGKeyCode NJKeyInputFieldEmpty = 0xFFFF;

@implementation NJKeyInputField

- (id)initWithFrame:(NSRect)frameRect {
    if ((self = [super initWithFrame:frameRect])) {
        self.alignment = NSCenterTextAlignment;
        [self setEditable:NO];
        [self setSelectable:NO];
    }
    return self;
}

- (void)clear {
    self.keyCode = NJKeyInputFieldEmpty;
    [self.keyDelegate keyInputFieldDidClear:self];
    [self resignIfFirstResponder];
}

- (BOOL)hasKeyCode {
    return self.keyCode != NJKeyInputFieldEmpty;
}

+ (NSString *)stringForKeyCode:(CGKeyCode)keyCode {
    switch (keyCode) {
        case 0xffff: return @"";
        case 0x7a: return @"F1";
        case 0x78: return @"F2";
        case 0x63: return @"F3";
        case 0x76: return @"F4";
        case 0x60: return @"F5";
        case 0x61: return @"F6";
        case 0x62: return @"F7";
        case 0x64: return @"F8";
        case 0x65: return @"F9";
        case 0x6d: return @"F10";
        case 0x67: return @"F11";
        case 0x6f: return @"F12";
        case 0x69: return @"F13";
        case 0x6b: return @"F14";
        case 0x71: return @"F15";
        case 0x6a: return @"F16";
        case 0x40: return @"F17";
        case 0x4f: return @"F18";
        case 0x50: return @"F19";
            
        case 0x35: return @"Esc";
        case 0x32: return @"`";
            
        case 0x12: return @"1";
        case 0x13: return @"2";
        case 0x14: return @"3";
        case 0x15: return @"4";
        case 0x17: return @"5";
        case 0x16: return @"6";
        case 0x1a: return @"7";
        case 0x1c: return @"8";
        case 0x19: return @"9";
        case 0x1d: return @"0";
        case 0x1b: return @"-";
        case 0x18: return @"=";
            
        case 0x3f: return @"Fn";
        case 0x36: return @"Right Command";
        case 0x37: return @"Left Command";
        case 0x38: return @"Left Shift";
        case 0x39: return @"Caps Lock";
        case 0x3a: return @"Left Option";
        case 0x3b: return @"Left Control";
        case 0x3c: return @"Right Shift";
        case 0x3d: return @"Right Option";
        case 0x3e: return @"Right Control";
            
        case 0x73: return @"Home";
        case 0x74: return @"Page Up";
        case 0x75: return @"Delete";
        case 0x77: return @"End";
        case 0x79: return @"Page Down";
            
        case 0x30: return @"Tab";
        case 0x33: return @"Backspace";
        case 0x24: return @"Return";
        case 0x31: return @"Space";
            
        case 0x0c: return @"Q";
        case 0x0d: return @"W";
        case 0x0e: return @"E";
        case 0x0f: return @"R";
        case 0x11: return @"T";
        case 0x10: return @"Y";
        case 0x20: return @"U";
        case 0x22: return @"I";
        case 0x1f: return @"O";
        case 0x23: return @"P";
        case 0x21: return @"[";
        case 0x1e: return @"]";
        case 0x2a: return @"\\";
        case 0x00: return @"A";
        case 0x01: return @"S";
        case 0x02: return @"D";
        case 0x03: return @"F";
        case 0x05: return @"G";
        case 0x04: return @"H";
        case 0x26: return @"J";
        case 0x28: return @"K";
        case 0x25: return @"L";
        case 0x29: return @";";
        case 0x27: return @"'";
        case 0x06: return @"Z";
        case 0x07: return @"X";
        case 0x08: return @"C";
        case 0x09: return @"V";
        case 0x0b: return @"B";
        case 0x2d: return @"N";
        case 0x2e: return @"M";
        case 0x2b: return @",";
        case 0x2f: return @".";
        case 0x2c: return @"/";
            
        case 0x47: return @"Clear";
        case 0x51: return @"Keypad =";
        case 0x4b: return @"Keypad /";
        case 0x43: return @"Keypad *";
        case 0x59: return @"Keypad 7";
        case 0x5b: return @"Keypad 8";
        case 0x5c: return @"Keypad 9";
        case 0x4e: return @"Keypad -";
        case 0x56: return @"Keypad 4";
        case 0x57: return @"Keypad 5";
        case 0x58: return @"Keypad 6";
        case 0x45: return @"Keypad +";
        case 0x53: return @"Keypad 1";
        case 0x54: return @"Keypad 2";
        case 0x55: return @"Keypad 3";
        case 0x52: return @"Keypad 0";
        case 0x41: return @"Keypad .";
        case 0x4c: return @"Enter";
            
        case 0x7e: return @"Up";
        case 0x7d: return @"Down";
        case 0x7b: return @"Left";
        case 0x7c: return @"Right";
        default:
            return [[NSString alloc] initWithFormat:@"Key 0x%x", keyCode];
    }
}

- (BOOL)acceptsFirstResponder {
    return self.isEnabled;
}

- (BOOL)becomeFirstResponder {
    self.backgroundColor = NSColor.selectedTextBackgroundColor;
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    self.backgroundColor = NSColor.textBackgroundColor;
    return [super resignFirstResponder];
}

- (void)setKeyCode:(CGKeyCode)keyCode {
    _keyCode = keyCode;
    self.stringValue = [NJKeyInputField stringForKeyCode:keyCode];
}

- (void)keyDown:(NSEvent *)theEvent {
    if (!theEvent.isARepeat) {
        if ((theEvent.modifierFlags & NSAlternateKeyMask)
            && theEvent.keyCode == 0x33) {
            // Allow Alt+Backspace to clear the field.
            self.keyCode = NJKeyInputFieldEmpty;
            [self.keyDelegate keyInputFieldDidClear:self];
        } else if ((theEvent.modifierFlags & NSAlternateKeyMask)
                && theEvent.keyCode == 0x35) {
                // Allow Alt+Escape to cancel.
            ;
        } else {
            self.keyCode = theEvent.keyCode;
            [self.keyDelegate keyInputField:self didChangeKey:_keyCode];
        }
        [self resignIfFirstResponder];
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.acceptsFirstResponder)
        [self.window makeFirstResponder:self];
}

- (void)flagsChanged:(NSEvent *)theEvent {
    // Many keys are only available on MacBook keyboards by using the
    // Fn modifier key (e.g. Fn+Left for Home), so delay processing
    // modifiers until the up event is received in order to let the
    // user type these virtual keys. However, there is no actual event
    // for modifier key up - so detect it by checking to see if any
    // modifiers are still down.
    if (!(theEvent.modifierFlags & NSDeviceIndependentModifierFlagsMask)) {
        self.keyCode = theEvent.keyCode;
        [self.keyDelegate keyInputField:self didChangeKey:_keyCode];
    }
}

@end
