//
//  NSView+FirstResponder.m
//  Enjoy
//
//  Created by Joe Wreschnig on 3/1/13.
//
//

#import "NSView+FirstResponder.h"

@implementation NSView (FirstResponder)

- (BOOL)resignIfFirstResponder {
    if (self.window.firstResponder == self)
        return [self.window makeFirstResponder:nil];
    return NO;
}

@end
