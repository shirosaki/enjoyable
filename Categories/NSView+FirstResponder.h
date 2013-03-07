#import <Cocoa/Cocoa.h>

@interface NSView (FirstResponder)

- (BOOL)resignIfFirstResponder;
    // Resign first responder status if this view is the active first
    // responder in its window. Returns whether first responder status
    // was resigned; YES if it was and NO if refused or the view was
    // not the first responder.

@end
