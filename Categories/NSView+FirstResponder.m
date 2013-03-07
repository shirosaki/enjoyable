#import "NSView+FirstResponder.h"

@implementation NSView (FirstResponder)

- (BOOL)resignIfFirstResponder {
    NSWindow *window = self.window;
    return window.firstResponder == self
        ? [window makeFirstResponder:nil]
        : NO;
}

@end
