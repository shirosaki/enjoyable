//
//  KeyInputTextView.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class TargetController;

@interface KeyInputTextView : NSTextField {
	IBOutlet NSWindow *window;
	IBOutlet TargetController *targetController;
}

@property (assign) int vk;
@property (readonly) BOOL hasKey;
@property (assign) BOOL enabled;

+ (NSString *)stringForKeyCode:(int)keycode;

- (void)clear;

@end
