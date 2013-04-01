//
//  NJKeyInputField.h
//  Enjoyable
//
//  Copyright 2013 Joe Wreschnig.
//

#import <Cocoa/Cocoa.h>

extern const CGKeyCode NJKeyInputFieldEmpty;

@protocol NJKeyInputFieldDelegate;

@interface NJKeyInputField : NSControl
    // An NJKeyInputField is a NSTextField-like widget that receives
    // exactly one key press, and displays the name of that key, then
    // resigns its first responder status. It can also inform a
    // special delegate when its content changes.

+ (NSString *)displayNameForKeyCode:(CGKeyCode)keyCode;

@property (nonatomic, weak) IBOutlet id <NJKeyInputFieldDelegate> delegate;

@property (nonatomic, assign) CGKeyCode keyCode;
    // The currently displayed key code, or NJKeyInputFieldEmpty if no
    // key is active.  Changing this will update the display but not
    // inform the delegate.

@property (nonatomic, readonly) BOOL hasKeyCode;
    // YES if any key is set, NO otherwise.

- (void)clear;
    // Clear the currently active key and call the delegate.

@end

@protocol NJKeyInputFieldDelegate

- (void)keyInputField:(NJKeyInputField *)keyInput
         didChangeKey:(CGKeyCode)keyCode;
- (void)keyInputFieldDidClear:(NJKeyInputField *)keyInput;

@end

