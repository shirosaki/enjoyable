//
//  NJKeyInputField.h
//  Enjoyable
//
//  Copyright 2013 Joe Wreschnig.
//

#import "NJKeyInputField.h"

#include <Carbon/Carbon.h>
    // Only used for kVK_... codes.

enum {
    kVK_RightCommand = kVK_Command - 1,
    kVK_Insert = 0x72,
    kVK_Power = 0x7f,
    kVK_ApplicationMenu = 0x6e,
    kVK_MAX = 0xFFFF,
};

const CGKeyCode NJKeyInputFieldEmpty = kVK_MAX;

@interface NJKeyInputField () <NSTextFieldDelegate>
@end

@implementation NJKeyInputField {
    NSTextField *field;
    NSImageView *warning;
}

- (id)initWithFrame:(NSRect)frameRect {
    if ((self = [super initWithFrame:frameRect])) {
        field = [[NSTextField alloc] initWithFrame:self.bounds];
        field.alignment = NSCenterTextAlignment;
        field.editable = NO;
        field.selectable = NO;
        field.delegate = self;
        [self addSubview:field];
        
        warning = [[NSImageView alloc] init];
        warning.image = [NSImage imageNamed:@"NSInvalidDataFreestanding"];
        CGSize imgSize = warning.image.size;
        CGRect bounds = self.bounds;
        warning.frame = CGRectMake(bounds.size.width - (imgSize.width + 4),
                                   (bounds.size.height - imgSize.height) / 2,
                                   imgSize.width, imgSize.height);
        
        warning.toolTip = NSLocalizedString(@"invalid key code",
                                            @"shown when the user types an invalid key code");
        warning.hidden = YES;
        [self addSubview:warning];
    }
    return self;
}

- (void)clear {
    self.keyCode = NJKeyInputFieldEmpty;
    [self.delegate keyInputFieldDidClear:self];
    [self resignIfFirstResponder];
}

- (BOOL)hasKeyCode {
    return self.keyCode != NJKeyInputFieldEmpty;
}

+ (NSString *)displayNameForKeyCode:(CGKeyCode)keyCode {
    switch (keyCode) {
        case kVK_F1: return @"F1";
        case kVK_F2: return @"F2";
        case kVK_F3: return @"F3";
        case kVK_F4: return @"F4";
        case kVK_F5: return @"F5";
        case kVK_F6: return @"F6";
        case kVK_F7: return @"F7";
        case kVK_F8: return @"F8";
        case kVK_F9: return @"F9";
        case kVK_F10: return @"F10";
        case kVK_F11: return @"F11";
        case kVK_F12: return @"F12";
        case kVK_F13: return @"F13";
        case kVK_F14: return @"F14";
        case kVK_F15: return @"F15";
        case kVK_F16: return @"F16";
        case kVK_F17: return @"F17";
        case kVK_F18: return @"F18";
        case kVK_F19: return @"F19";
        case kVK_F20: return @"F20";
            
        case kVK_Escape: return @"⎋";
        case kVK_ANSI_Grave: return @"`";
            
        case kVK_ANSI_1: return @"1";
        case kVK_ANSI_2: return @"2";
        case kVK_ANSI_3: return @"3";
        case kVK_ANSI_4: return @"4";
        case kVK_ANSI_5: return @"5";
        case kVK_ANSI_6: return @"6";
        case kVK_ANSI_7: return @"7";
        case kVK_ANSI_8: return @"8";
        case kVK_ANSI_9: return @"9";
        case kVK_ANSI_0: return @"0";
        case kVK_ANSI_Minus: return @"-";
        case kVK_ANSI_Equal: return @"=";
            
        case kVK_Function: return @"Fn";
        case kVK_CapsLock: return @"⇪";
        case kVK_Command: return NSLocalizedString(@"Left ⌘", @"keyboard key");
        case kVK_RightCommand: return NSLocalizedString(@"Right ⌘", @"keyboard key");
        case kVK_Option: return NSLocalizedString(@"Left ⌥", @"keyboard key");
        case kVK_RightOption: return NSLocalizedString(@"Right ⌥", @"keyboard key");
        case kVK_Control: return NSLocalizedString(@"Left ⌃", @"keyboard key");
        case kVK_RightControl: return NSLocalizedString(@"Right ⌃", @"keyboard key");
        case kVK_Shift: return NSLocalizedString(@"Left ⇧", @"keyboard key");
        case kVK_RightShift: return NSLocalizedString(@"Right ⇧", @"keyboard key");
            
        case kVK_Home: return @"↖";
        case kVK_PageUp: return @"⇞";
        case kVK_End: return @"↘";
        case kVK_PageDown: return @"⇟";

        case kVK_ForwardDelete: return @"⌦";
        case kVK_Delete: return @"⌫";
            
        case kVK_Tab: return @"⇥";
        case kVK_Return: return @"↩";
        case kVK_Space: return @"␣";
            
        case kVK_ANSI_A: return @"A";
        case kVK_ANSI_B: return @"B";
        case kVK_ANSI_C: return @"C";
        case kVK_ANSI_D: return @"D";
        case kVK_ANSI_E: return @"E";
        case kVK_ANSI_F: return @"F";
        case kVK_ANSI_G: return @"G";
        case kVK_ANSI_H: return @"H";
        case kVK_ANSI_I: return @"I";
        case kVK_ANSI_J: return @"J";
        case kVK_ANSI_K: return @"K";
        case kVK_ANSI_L: return @"L";
        case kVK_ANSI_M: return @"M";
        case kVK_ANSI_N: return @"N";
        case kVK_ANSI_O: return @"O";
        case kVK_ANSI_P: return @"P";
        case kVK_ANSI_Q: return @"Q";
        case kVK_ANSI_R: return @"R";
        case kVK_ANSI_S: return @"S";
        case kVK_ANSI_T: return @"T";
        case kVK_ANSI_U: return @"U";
        case kVK_ANSI_V: return @"V";
        case kVK_ANSI_W: return @"W";
        case kVK_ANSI_X: return @"X";
        case kVK_ANSI_Y: return @"Y";
        case kVK_ANSI_Z: return @"Z";
        case kVK_ANSI_LeftBracket: return @"[";
        case kVK_ANSI_RightBracket: return @"]";
        case kVK_ANSI_Backslash: return @"\\";
        case kVK_ANSI_Semicolon: return @";";
        case kVK_ANSI_Quote: return @"'";
        case kVK_ANSI_Comma: return @",";
        case kVK_ANSI_Period: return @".";
        case kVK_ANSI_Slash: return @"/";
            
        case kVK_ANSI_Keypad0: return NSLocalizedString(@"Key Pad 0", @"numeric pad key");
        case kVK_ANSI_Keypad1: return NSLocalizedString(@"Key Pad 1", @"numeric pad key");
        case kVK_ANSI_Keypad2: return NSLocalizedString(@"Key Pad 2", @"numeric pad key");
        case kVK_ANSI_Keypad3: return NSLocalizedString(@"Key Pad 3", @"numeric pad key");
        case kVK_ANSI_Keypad4: return NSLocalizedString(@"Key Pad 4", @"numeric pad key");
        case kVK_ANSI_Keypad5: return NSLocalizedString(@"Key Pad 5", @"numeric pad key");
        case kVK_ANSI_Keypad6: return NSLocalizedString(@"Key Pad 6", @"numeric pad key");
        case kVK_ANSI_Keypad7: return NSLocalizedString(@"Key Pad 7", @"numeric pad key");
        case kVK_ANSI_Keypad8: return NSLocalizedString(@"Key Pad 8", @"numeric pad key");
        case kVK_ANSI_Keypad9: return NSLocalizedString(@"Key Pad 9", @"numeric pad key");
        case kVK_ANSI_KeypadClear: return @"⌧";
        case kVK_ANSI_KeypadEnter: return @"⌤";

        case kVK_ANSI_KeypadEquals:
            return NSLocalizedString(@"Key Pad =", @"numeric pad key");
        case kVK_ANSI_KeypadDivide:
            return NSLocalizedString(@"Key Pad /", @"numeric pad key");
        case kVK_ANSI_KeypadMultiply:
            return NSLocalizedString(@"Key Pad *", @"numeric pad key");
        case kVK_ANSI_KeypadMinus:
            return NSLocalizedString(@"Key Pad -", @"numeric pad key");
        case kVK_ANSI_KeypadPlus:
            return NSLocalizedString(@"Key Pad +", @"numeric pad key");
        case kVK_ANSI_KeypadDecimal:
            return NSLocalizedString(@"Key Pad .", @"numeric pad key");
            
        case kVK_LeftArrow: return @"←";
        case kVK_RightArrow: return @"→";
        case kVK_UpArrow: return @"↑";
        case kVK_DownArrow: return @"↓";
            
        case kVK_JIS_Yen: return @"¥";
        case kVK_JIS_Underscore: return @"_";
        case kVK_JIS_KeypadComma:
            return NSLocalizedString(@"Key Pad ,", @"numeric pad key");
        case kVK_JIS_Eisu: return @"英数";
        case kVK_JIS_Kana: return @"かな";
            
        case kVK_Power: return @"⌽";
        case kVK_VolumeUp: return @"🔊";
        case kVK_VolumeDown: return @"🔉";
            
        case kVK_Insert:
            return NSLocalizedString(@"Insert", "keyboard key");
        case kVK_ApplicationMenu:
            return NSLocalizedString(@"Menu", "keyboard key");

        case kVK_MAX: // NJKeyInputFieldEmpty
            return @"";
        default:
            return [[NSString alloc] initWithFormat:
                    NSLocalizedString(@"key 0x%x", @"unknown key code"),
                    keyCode];
    }
}

- (BOOL)acceptsFirstResponder {
    return self.isEnabled;
}

- (BOOL)becomeFirstResponder {
    field.backgroundColor = NSColor.selectedTextBackgroundColor;
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    field.backgroundColor = NSColor.textBackgroundColor;
    return [super resignFirstResponder];
}

- (void)setKeyCode:(CGKeyCode)keyCode {
    _keyCode = keyCode;
    field.stringValue = [NJKeyInputField displayNameForKeyCode:keyCode];
}

- (void)keyDown:(NSEvent *)event {
    static const NSUInteger IGNORE = NSAlternateKeyMask | NSCommandKeyMask;
    if (!event.isARepeat) {
        if ((event.modifierFlags & IGNORE) && event.keyCode == kVK_Delete) {
            // Allow Alt/Command+Delete to clear the field.
            self.keyCode = NJKeyInputFieldEmpty;
            [self.delegate keyInputFieldDidClear:self];
        } else if (!(event.modifierFlags & IGNORE)) {
            self.keyCode = event.keyCode;
            [self.delegate keyInputField:self didChangeKey:self.keyCode];
        }
        [self resignIfFirstResponder];
    }
}

static BOOL isValidKeyCode(long code) {
    return code < 0xFFFF && code >= 0;
}

- (void)controlTextDidChange:(NSNotification *)obj {
    char *error = NULL;
    long code = strtol(field.stringValue.UTF8String, &error, 16);
    warning.hidden = (isValidKeyCode(code) && !*error) || !field.stringValue.length;
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    [field.cell setPlaceholderString:@""];
    field.editable = NO;
    field.selectable = NO;
    warning.hidden = YES;
    char *error = NULL;
    const char *s = field.stringValue.UTF8String;
    short code = (short)strtol(s, &error, 16);
    
    if (!*error && isValidKeyCode(code) && field.stringValue.length) {
        self.keyCode = code;
        [self.delegate keyInputField:self didChangeKey:self.keyCode];
    } else {
        self.keyCode = self.keyCode;
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.isEnabled) {
        if (theEvent.modifierFlags & NSCommandKeyMask) {
            field.editable = YES;
            field.selectable = YES;
            field.stringValue = @"";
            [field.cell setPlaceholderString:
             NSLocalizedString(@"enter key code",
                               @"shown when user must enter a key code to map to")];
            [self.window makeFirstResponder:field];
        } else {
            if (self.window.firstResponder == self)
                [self.window makeFirstResponder:nil];
            else if (self.acceptsFirstResponder)
                [self.window makeFirstResponder:self];
        }
    }
}

- (void)flagsChanged:(NSEvent *)theEvent {
    // Many keys are only available on MacBook keyboards by using the
    // Fn modifier key (e.g. Fn+Left for Home), so delay processing
    // modifiers until the up event is received in order to let the
    // user type these virtual keys. However, there is no actual event
    // for modifier key up - so detect it by checking to see if any
    // modifiers are still down.
    if (!field.isEditable
        && !(theEvent.modifierFlags & NSDeviceIndependentModifierFlagsMask)) {
        self.keyCode = theEvent.keyCode;
        [self.delegate keyInputField:self didChangeKey:_keyCode];
    }
}

@end
